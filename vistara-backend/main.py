import io
import json
import os
import re
import asyncio
import tempfile
import traceback
from difflib import SequenceMatcher
from enum import Enum
from typing import Dict, List, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, File, Form, HTTPException, Query, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from google import genai
from google.genai import types
import pdfplumber
from PIL import Image
from pydantic import BaseModel, Field
import pytesseract

load_dotenv()

# ============================================================================
# CONFIGURATION (Windows Tesseract Path)
# ============================================================================
TESSERACT_CMD = os.getenv(
    "TESSERACT_CMD",
    r"C:\Program Files\Tesseract-OCR\tesseract.exe",
)
if os.path.exists(TESSERACT_CMD):
    pytesseract.pytesseract.tesseract_cmd = TESSERACT_CMD

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-3.8-flash")

app = FastAPI(
    title="Vistara Contract Analysis API",
    description="AI-powered contract risk analysis with PII Redaction, OCR Fallback, and Spatial Grounding",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================================
# DATA MODELS
# ============================================================================

class SeverityLevel(str, Enum):
    high = "High"
    medium = "Medium"
    low = "Low"


class BoundingBox(BaseModel):
    page: int
    x0: float
    top: float
    x1: float
    bottom: float
    page_width: float
    page_height: float


class RedactionSummary(BaseModel):
    redacted_count: int = 0
    redacted_types: List[str] = []
    sanitized_preview: str = ""
    pii_boxes: List[BoundingBox] = []


class ClauseRisk(BaseModel):
    clause_text: str
    severity: SeverityLevel
    category: str
    plain_explanation: str
    worst_case_scenario: str

    # Deterministic Verification & Spatial Grounding (Calculated by Vistara Extract)
    evidence_verified: bool = False
    match_confidence: float = Field(default=0.0, ge=0.0, le=1.0)
    matched_page: Optional[int] = None
    bounding_boxes: List[BoundingBox] = []


class ContractReport(BaseModel):
    filename: str
    overall_score: int = Field(..., ge=0, le=100)
    risk_level: str
    high_risk_count: int
    medium_risk_count: int
    low_risk_count: int
    extraction_method: str = "native_pdf"  # "native_pdf", "hybrid_ocr", "raw_text", or "image_ocr"
    redaction_summary: RedactionSummary = RedactionSummary()
    flagged_clauses: List[ClauseRisk]


class ExtractedPage(BaseModel):
    page_number: int
    text: str
    width: float = 595.0   # Standard A4 width fallback
    height: float = 842.0  # Standard A4 height fallback
    used_ocr: bool = False
    words: List[dict] = []  # Stores pdfplumber word dictionaries with x0, top, x1, bottom


# ============================================================================
# MODULE 1: PII SANITIZER & PRIVACY REDACTION ENGINE
# ============================================================================

PII_PATTERNS = {
    "EMAIL": r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b",
    "PHONE": r"(?:\+?\d{1,3}[-.\s]?)?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b|\b[6-9]\d{9}\b",
    "PAN_CARD": r"\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b",
    "AADHAAR": r"\b\d{4}\s?\d{4}\s?\d{4}\b",
    "SSN": r"\b\d{3}-\d{2}-\d{4}\b",
}


def sanitize_pii(text: str) -> tuple[str, RedactionSummary]:
    """
    Replaces sensitive personal identifiers with privacy tokens before LLM transmission.
    """
    sanitized = text
    total_redacted = 0
    types_found = set()

    for label, pattern in PII_PATTERNS.items():
        matches = re.findall(pattern, sanitized)
        if matches:
            total_redacted += len(matches)
            types_found.add(label)
            sanitized = re.sub(pattern, f"[REDACTED_{label}]", sanitized)

    preview = sanitized[:400] + ("..." if len(sanitized) > 400 else "")
    summary = RedactionSummary(
        redacted_count=total_redacted,
        redacted_types=sorted(list(types_found)),
        sanitized_preview=preview,
    )
    return sanitized, summary

def extract_pii_bounding_boxes(pages: List[ExtractedPage]) -> List[BoundingBox]:
    """
    Groups words by visual line AND column proximity (ignoring jumps across table columns),
    runs PII regex on each cell/segment, and returns tight bounding boxes ONLY over the matched PII.
    """
    pii_boxes: List[BoundingBox] = []

    # Enhanced patterns that also handle spaced Indian numbers (+91 XXXXX XXXXX) and split IDs
    box_patterns = {
        **PII_PATTERNS,
        "PHONE_SPACED": r"(?:\+91[\s-]?)?[6-9]\d{4}[\s-]?\d{5}\b",
        "ID_PARTIAL": r"\b\d{4}\s\d{4}(?:\s\d{4})?\b",
    }

    for page in pages:
        if not page.words:
            continue

        # 1. Group words into horizontal lines (top within 5pt)
        lines: List[List[dict]] = []
        for w in page.words:
            placed = False
            for line in lines:
                if abs(float(line[0]["top"]) - float(w["top"])) <= 5.0:
                    line.append(w)
                    placed = True
                    break
            if not placed:
                lines.append([w])

        # 2. Within each line, sort left-to-right and split into segments when there's a large column gap (> 25pt)
        for line in lines:
            line.sort(key=lambda w: float(w["x0"]))
            segments: List[List[dict]] = [[line[0]]]
            for w in line[1:]:
                prev_x1 = float(segments[-1][-1]["x1"])
                curr_x0 = float(w["x0"])
                if (curr_x0 - prev_x1) > 25.0:  # New table column! Do not merge across columns
                    segments.append([w])
                else:
                    segments[-1].append(w)

            # 3. Run regex on each isolated column segment and box ONLY the matched words
            for seg in segments:
                # Build string with character-to-word index tracking
                seg_text = ""
                char_to_word: List[int] = []
                for idx, w in enumerate(seg):
                    word_str = str(w.get("text", ""))
                    if idx > 0:
                        seg_text += " "
                        char_to_word.append(-1)
                    seg_text += word_str
                    char_to_word.extend([idx] * len(word_str))

                for pattern in box_patterns.values():
                    for match in re.finditer(pattern, seg_text):
                        start, end = match.span()
                        matched_word_indices = {
                            char_to_word[i]
                            for i in range(start, end)
                            if i < len(char_to_word) and char_to_word[i] != -1
                        }
                        if not matched_word_indices:
                            continue

                        matched_words = [seg[i] for i in sorted(matched_word_indices)]
                        pii_boxes.append(
                            BoundingBox(
                                page=page.page_number,
                                x0=round(min(float(w["x0"]) for w in matched_words), 2),
                                top=round(min(float(w["top"]) for w in matched_words), 2),
                                x1=round(max(float(w["x1"]) for w in matched_words), 2),
                                bottom=round(max(float(w["bottom"]) for w in matched_words), 2),
                                page_width=page.width,
                                page_height=page.height,
                            )
                        )

    return pii_boxes

# ============================================================================
# MODULE 2: HYBRID OCR & PAGE-AWARE PDF EXTRACTION + SPATIAL WORDS
# ============================================================================

def extract_pdf_pages(file_bytes: bytes) -> tuple[List[ExtractedPage], str]:
    """
    Extracts text and word-level bounding boxes page-by-page.
    Falls back to Tesseract OCR automatically if a page has < 40 selectable characters.
    """
    pages: List[ExtractedPage] = []
    ocr_triggered = False

    with pdfplumber.open(io.BytesIO(file_bytes)) as pdf:
        for page_number, page in enumerate(pdf.pages, start=1):
            width = float(page.width or 595.0)
            height = float(page.height or 842.0)
            used_ocr = False
            words_data = []

            try:
                page_text = (page.extract_text() or "").strip()
                words_data = page.extract_words() or []
            except Exception as e:
                print(f"⚠️ Native extraction failed on page {page_number}: {e}")
                page_text = ""

            # Hybrid OCR Fallback for scanned/image PDFs
            if len(page_text) < 40:
                try:
                    print(f"🔍 Page {page_number} has minimal selectable text. Running OCR fallback...")
                    pil_image = page.to_image(resolution=200).original
                    ocr_text = pytesseract.image_to_string(pil_image).strip()
                    if ocr_text:
                        page_text = ocr_text
                        used_ocr = True
                        ocr_triggered = True
                except Exception as ocr_err:
                    print(f"⚠️ OCR fallback failed on page {page_number}: {ocr_err}")

            pages.append(
                ExtractedPage(
                    page_number=page_number,
                    text=page_text,
                    width=width,
                    height=height,
                    used_ocr=used_ocr,
                    words=words_data,
                )
            )

    method = "hybrid_ocr" if ocr_triggered else "native_pdf"
    return pages, method


def combine_pages(pages: List[ExtractedPage]) -> str:
    parts: List[str] = []
    for page in pages:
        if not page.text.strip():
            continue
        parts.append(f"\n--- PAGE {page.page_number} ---\n{page.text}")
    return "\n".join(parts).strip()


def extract_text_input(text: str) -> List[ExtractedPage]:
    return [ExtractedPage(page_number=1, text=text.strip())]


# ============================================================================
# MODULE 2B: IMAGE OCR EXTRACTION
# ============================================================================

ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
ALLOWED_IMAGE_MIMETYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_IMAGE_BYTES = 20 * 1024 * 1024  # 20 MB per image
MAX_IMAGE_DIMENSION = 8000          # pixels per side
MIN_IMAGE_DIMENSION = 10            # pixels per side


def validate_image(
    file_bytes: bytes,
    filename: str,
    content_type: Optional[str],
) -> None:
    """
    Validates image file size, extension, MIME type, and dimensions.
    Raises HTTPException on failure.
    """
    ext = os.path.splitext(filename.lower())[1]
    if ext not in ALLOWED_IMAGE_EXTENSIONS:
        raise HTTPException(
            status_code=422,
            detail=f"Unsupported image format '{ext}'. Allowed: JPG, JPEG, PNG, WEBP.",
        )

    if content_type and content_type.lower() not in ALLOWED_IMAGE_MIMETYPES:
        # Also allow content_type starting with image/ as a lenient check
        if not content_type.lower().startswith("image/"):
            raise HTTPException(
                status_code=422,
                detail=f"Invalid MIME type '{content_type}' for image upload.",
            )

    if len(file_bytes) > MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=413,
            detail=f"Image '{filename}' exceeds the 20 MB size limit.",
        )

    if len(file_bytes) == 0:
        raise HTTPException(status_code=422, detail=f"Image '{filename}' is empty.")

    try:
        with Image.open(io.BytesIO(file_bytes)) as img:
            w, h = img.size
            if w < MIN_IMAGE_DIMENSION or h < MIN_IMAGE_DIMENSION:
                raise HTTPException(
                    status_code=422,
                    detail=f"Image '{filename}' is too small ({w}×{h} px).",
                )
            if w > MAX_IMAGE_DIMENSION or h > MAX_IMAGE_DIMENSION:
                raise HTTPException(
                    status_code=422,
                    detail=f"Image '{filename}' is too large ({w}×{h} px). Max dimension is {MAX_IMAGE_DIMENSION}px.",
                )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=422,
            detail=f"Could not read image '{filename}': {e}",
        )


def ocr_image_bytes(file_bytes: bytes, filename: str, page_number: int) -> ExtractedPage:
    """
    Runs Tesseract OCR on a single image and returns an ExtractedPage.
    Returns the page with a warning note in text if OCR fails rather than
    raising, so the caller can decide to report the limitation instead of
    silently skipping or hallucinating.
    """
    standard_width = 595.0
    standard_height = 842.0

    try:
        with Image.open(io.BytesIO(file_bytes)) as img:
            width, height = float(img.size[0]), float(img.size[1])
            # Convert to RGB for Tesseract compatibility (handles WEBP RGBA, etc.)
            rgb_img = img.convert("RGB")

        ocr_text = pytesseract.image_to_string(rgb_img).strip()

        if not ocr_text:
            # OCR ran but produced no text — image may be blank/decorative
            warning = (
                f"[WARNING: Image '{filename}' (page {page_number}) yielded no readable text. "
                "It may be blank, decorative, or too low resolution for OCR.]"
            )
            print(f"⚠️ {warning}")
            return ExtractedPage(
                page_number=page_number,
                text=warning,
                width=width,
                height=height,
                used_ocr=True,
            )

        return ExtractedPage(
            page_number=page_number,
            text=ocr_text,
            width=width,
            height=height,
            used_ocr=True,
        )

    except Exception as e:
        warning = (
            f"[WARNING: OCR failed for image '{filename}' (page {page_number}): {e}. "
            "The image may be blurry, rotated, or corrupted.]"
        )
        print(f"⚠️ {warning}")
        return ExtractedPage(
            page_number=page_number,
            text=warning,
            width=standard_width,
            height=standard_height,
            used_ocr=True,
        )


def extract_image_pages(
    image_files: List[tuple[bytes, str, Optional[str]]],
) -> tuple[List[ExtractedPage], str]:
    """
    Validates and OCR-processes a list of (file_bytes, filename, content_type) tuples.
    Returns extracted pages in order, plus extraction_method="image_ocr".
    """
    pages: List[ExtractedPage] = []

    for index, (file_bytes, filename, content_type) in enumerate(image_files, start=1):
        validate_image(file_bytes, filename, content_type)
        page = ocr_image_bytes(file_bytes, filename, index)
        pages.append(page)

    return pages, "image_ocr"


# ============================================================================
# TEXT NORMALIZATION & FUZZY EVIDENCE VERIFICATION
# ============================================================================

def normalize_text(text: str) -> str:
    if not text:
        return ""
    text = text.replace("\u00ad", "")
    text = text.replace("“", '"').replace("”", '"').replace("‘", "'").replace("’", "'")
    text = text.replace("–", "-").replace("—", "-").replace("−", "-")
    text = text.lower()
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def normalize_for_matching(text: str) -> str:
    text = normalize_text(text)
    text = re.sub(r"[^\w\s₹]", " ", text, flags=re.UNICODE)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def exact_normalized_match(clause_text: str, document_text: str) -> bool:
    clause = normalize_text(clause_text)
    document = normalize_text(document_text)
    return bool(clause and document and clause in document)


def tolerant_exact_match(clause_text: str, document_text: str) -> bool:
    clause = normalize_for_matching(clause_text)
    document = normalize_for_matching(document_text)
    return bool(clause and document and clause in document)


def tokenize_matching_text(text: str) -> List[str]:
    normalized = normalize_for_matching(text)
    return normalized.split() if normalized else []


def similarity(a: str, b: str) -> float:
    return SequenceMatcher(None, a, b).ratio() if (a and b) else 0.0


def fuzzy_clause_match(clause_text: str, document_text: str) -> float:
    clause_tokens = tokenize_matching_text(clause_text)
    document_tokens = tokenize_matching_text(document_text)

    if len(clause_tokens) < 8 or not document_tokens:
        return 0.0

    clause_joined = " ".join(clause_tokens)
    target_length = len(clause_tokens)
    min_window = max(8, int(target_length * 0.80))
    max_window = min(len(document_tokens), max(min_window, int(target_length * 1.20)))

    anchor_size = min(6, max(3, len(clause_tokens) // 4))
    start_anchor = " ".join(clause_tokens[:anchor_size])
    end_anchor = " ".join(clause_tokens[-anchor_size:])

    candidate_starts = [
        idx
        for idx in range(0, len(document_tokens) - anchor_size + 1)
        if similarity(start_anchor, " ".join(document_tokens[idx : idx + anchor_size])) >= 0.72
    ]

    if not candidate_starts:
        return 0.0

    best_score = 0.0
    for start_index in candidate_starts:
        for window_size in range(min_window, max_window + 1):
            end_index = start_index + window_size
            if end_index > len(document_tokens):
                break
            candidate_tokens = document_tokens[start_index:end_index]
            full_score = similarity(clause_joined, " ".join(candidate_tokens))
            if full_score < best_score:
                continue
            end_score = similarity(end_anchor, " ".join(candidate_tokens[-anchor_size:]))
            combined = (full_score * 0.70) + (end_score * 0.30)
            if combined > best_score:
                best_score = combined

    return best_score


# ============================================================================
# MODULE 3: BOUNDING-BOX COORDINATE EXTRACTION (SPATIAL GROUNDING)
# ============================================================================

def extract_clause_bounding_boxes(clause_text: str, page: ExtractedPage) -> List[BoundingBox]:
    """
    Matches verified clause tokens against pdfplumber word coordinates on the matched page,
    merging words on the same line into clean highlight rectangles for the Flutter viewer.
    """
    if not page.words or not clause_text.strip():
        return []

    clause_tokens = tokenize_matching_text(clause_text)
    if len(clause_tokens) < 4:
        return []

    # Normalize extracted pdfplumber words
    page_word_objs = []
    for w in page.words:
        norm_w = normalize_for_matching(w.get("text", ""))
        if norm_w:
            page_word_objs.append((norm_w, w))

    if not page_word_objs:
        return []

    # Locate starting sequence via anchor tokens
    anchor_len = min(5, len(clause_tokens))
    anchor_str = " ".join(clause_tokens[:anchor_len])
    best_start = -1
    best_sim = 0.0

    for i in range(len(page_word_objs) - anchor_len + 1):
        window_str = " ".join(item[0] for item in page_word_objs[i : i + anchor_len])
        score = similarity(anchor_str, window_str)
        if score > best_sim:
            best_sim = score
            best_start = i

    if best_start == -1 or best_sim < 0.70:
        return []

    end_idx = min(len(page_word_objs), best_start + len(clause_tokens))
    matched_words = [item[1] for item in page_word_objs[best_start:end_idx]]

    # Group matched words by vertical line (top coordinate within 5pt tolerance)
    lines: List[List[dict]] = []
    for w in matched_words:
        placed = False
        for line in lines:
            if abs(float(line[0]["top"]) - float(w["top"])) <= 5.0:
                line.append(w)
                placed = True
                break
        if not placed:
            lines.append([w])

    boxes: List[BoundingBox] = []
    for line in lines:
        boxes.append(
            BoundingBox(
                page=page.page_number,
                x0=round(min(float(w["x0"]) for w in line), 2),
                top=round(min(float(w["top"]) for w in line), 2),
                x1=round(max(float(w["x1"]) for w in line), 2),
                bottom=round(max(float(w["bottom"]) for w in line), 2),
                page_width=page.width,
                page_height=page.height,
            )
        )
    return boxes


def verify_clause_evidence(
    clause_text: str,
    pages: List[ExtractedPage],
) -> tuple[bool, float, Optional[int], List[BoundingBox]]:
    if not clause_text.strip():
        return False, 0.0, None, []

    for page in pages:
        if page.text.strip() and exact_normalized_match(clause_text, page.text):
            boxes = extract_clause_bounding_boxes(clause_text, page)
            return True, 1.0, page.page_number, boxes

    for page in pages:
        if page.text.strip() and tolerant_exact_match(clause_text, page.text):
            boxes = extract_clause_bounding_boxes(clause_text, page)
            return True, 0.98, page.page_number, boxes

    best_confidence = 0.0
    best_page_obj: Optional[ExtractedPage] = None

    for page in pages:
        if not page.text.strip():
            continue
        score = fuzzy_clause_match(clause_text, page.text)
        if score > best_confidence:
            best_confidence = score
            best_page_obj = page

    if best_confidence >= 0.88 and best_page_obj is not None:
        boxes = extract_clause_bounding_boxes(clause_text, best_page_obj)
        return True, round(best_confidence, 4), best_page_obj.page_number, boxes

    return False, round(best_confidence, 4), (best_page_obj.page_number if best_page_obj else None), []


def verify_report_evidence(
    report: ContractReport,
    pages: List[ExtractedPage],
    extraction_method: str,
    redaction_summary: RedactionSummary,
) -> ContractReport:
    verified_clauses: List[ClauseRisk] = []

    for clause in report.flagged_clauses:
        verified, confidence, page_number, boxes = verify_clause_evidence(
            clause_text=clause.clause_text,
            pages=pages,
        )
        updated_clause = clause.model_copy(
            update={
                "evidence_verified": verified,
                "match_confidence": confidence,
                "matched_page": page_number,
                "bounding_boxes": boxes,
            }
        )
        verified_clauses.append(updated_clause)

    return report.model_copy(
        update={
            "flagged_clauses": verified_clauses,
            "extraction_method": extraction_method,
            "redaction_summary": redaction_summary,
        }
    )


# ============================================================================
# GEMINI ANALYSIS & SYSTEM PROMPT
# ============================================================================

SYSTEM_PROMPT = """
You are Vistara, an expert contract risk analysis AI.
Analyze ONLY the contract provided in the user input.
For every materially relevant risky clause:
1. Return the EXACT wording of the relevant clause as it appears in the supplied contract.
2. Preserve numbers, dates, monetary amounts, percentages, and [REDACTED_...] tokens if present.
3. Assign severity: High, Medium, or Low.
4. Provide category, plain_explanation, and worst_case_scenario.
5. overall_score: integer 0-100 (0 = extremely hazardous, 100 = very safe).
Return ONLY valid JSON matching the schema.
"""


async def analyze_with_gemini(
    contract_text: str,
    filename: str,
    pages: List[ExtractedPage],
    extraction_method: str,
    redaction_summary: RedactionSummary,
) -> ContractReport:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY is missing in .env")

    try:
        client = genai.Client(api_key=api_key)
        user_prompt = f"Filename: {filename}\n\nContract Text:\n{contract_text}"

        response_schema = {
            "type": "OBJECT",
            "properties": {
                "filename": {"type": "STRING"},
                "overall_score": {"type": "INTEGER"},
                "risk_level": {"type": "STRING", "enum": ["High", "Medium", "Low"]},
                "high_risk_count": {"type": "INTEGER"},
                "medium_risk_count": {"type": "INTEGER"},
                "low_risk_count": {"type": "INTEGER"},
                "flagged_clauses": {
                    "type": "ARRAY",
                    "items": {
                        "type": "OBJECT",
                        "properties": {
                            "clause_text": {"type": "STRING"},
                            "severity": {"type": "STRING", "enum": ["High", "Medium", "Low"]},
                            "category": {"type": "STRING"},
                            "plain_explanation": {"type": "STRING"},
                            "worst_case_scenario": {"type": "STRING"},
                        },
                        "required": [
                            "clause_text",
                            "severity",
                            "category",
                            "plain_explanation",
                            "worst_case_scenario",
                        ],
                    },
                },
            },
            "required": [
                "filename",
                "overall_score",
                "risk_level",
                "high_risk_count",
                "medium_risk_count",
                "low_risk_count",
                "flagged_clauses",
            ],
        }

        candidate_models = [
            GEMINI_MODEL,
            "gemini-3.6-flash",
            "gemini-3.8-flash-lite",
        ]
        # Remove duplicates while preserving order
        candidate_models = list(dict.fromkeys(candidate_models))

        response = None
        last_error = None

        for model_name in candidate_models:
            for attempt in range(2):  # Try each model up to 2 times
                try:
                    response = client.models.generate_content(
                        model=model_name,
                        contents=user_prompt,
                        config=types.GenerateContentConfig(
                            system_instruction=SYSTEM_PROMPT,
                            temperature=0.2,
                            response_mime_type="application/json",
                            response_schema=response_schema,
                        ),
                    )
                    if response and response.text:
                        break
                except Exception as model_err:
                    last_error = model_err
                    if "503" in str(model_err) or "UNAVAILABLE" in str(model_err):
                        print(f"⚠️ {model_name} overloaded (503). Retrying/falling back...")
                        await asyncio.sleep(1.5)
                        continue
                    raise model_err
            if response and response.text:
                break

        if not response or not response.text:
            raise last_error or HTTPException(status_code=503, detail="All Gemini models are currently busy.")

        report_data = json.loads(response.text)
        report_data["filename"] = filename
        report = ContractReport(**report_data)

        return verify_report_evidence(
            report=report,
            pages=pages,
            extraction_method=extraction_method,
            redaction_summary=redaction_summary,
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"Gemini API Error:\n{traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")


# ============================================================================
# ENDPOINTS
# ============================================================================

@app.get("/")
async def root():
    return {"status": "ok", "message": "Vistara Extract v2.0 (OCR + PII Redaction + Spatial Grounding)"}


@app.post("/analyze", response_model=ContractReport)
async def analyze_contract(
    mock: bool = Query(False),
    redact_pii: bool = Query(True),  # Toggleable from Flutter UI
    file: Optional[UploadFile] = File(None),
    images: Optional[List[UploadFile]] = File(None),
    text: Optional[str] = Form(None),
):
    filename = "contract.txt"
    contract_text = ""
    extracted_pages: List[ExtractedPage] = []
    extraction_method = "raw_text"

    # ------------------------------------------------------------------
    # INPUT ROUTING
    # Priority: PDF file > images > text
    # ------------------------------------------------------------------

    if file is not None:
        filename = file.filename or "upload.pdf"
        file_bytes = await file.read()
        if not file_bytes:
            raise HTTPException(status_code=422, detail="Uploaded file is empty.")

        if filename.lower().endswith(".pdf"):
            extracted_pages, extraction_method = extract_pdf_pages(file_bytes)
            contract_text = combine_pages(extracted_pages)
        else:
            contract_text = file_bytes.decode("utf-8", errors="replace").strip()
            extracted_pages = extract_text_input(contract_text)

    elif images and len(images) > 0:
        # Filter out any None/empty entries FastAPI may inject
        valid_images = [img for img in images if img is not None and img.filename]
        if not valid_images:
            raise HTTPException(status_code=422, detail="No valid image files provided.")

        # Build filename from first image for the report
        filename = valid_images[0].filename or "image_upload"

        image_tuples: List[tuple[bytes, str, Optional[str]]] = []
        for img_upload in valid_images:
            img_bytes = await img_upload.read()
            image_tuples.append((img_bytes, img_upload.filename or "image", img_upload.content_type))

        extracted_pages, extraction_method = extract_image_pages(image_tuples)
        contract_text = combine_pages(extracted_pages)

        # Use a combined display name when multiple images are uploaded
        if len(valid_images) > 1:
            filename = f"{len(valid_images)} images"

    elif text:
        contract_text = text.strip()
        extracted_pages = extract_text_input(contract_text)
    else:
        raise HTTPException(status_code=422, detail="Provide either a file, images, or text.")

    if not contract_text.strip():
        raise HTTPException(status_code=422, detail="Could not extract any readable text.")

    # Apply PII Redaction before sending to LLM
    redaction_summary = RedactionSummary()
    llm_input_text = contract_text
    if redact_pii:
        pii_boxes = extract_pii_bounding_boxes(extracted_pages)
        llm_input_text, redaction_summary = sanitize_pii(contract_text)
        print("=== SANITIZED TEXT SENT TO GEMINI ===")
        print(llm_input_text)
        print("=====================================")
        redaction_summary.pii_boxes = pii_boxes
        for p in extracted_pages:
            p.text, _ = sanitize_pii(p.text)

    return await analyze_with_gemini(
        contract_text=llm_input_text,
        filename=filename,
        pages=extracted_pages,
        extraction_method=extraction_method,
        redaction_summary=redaction_summary,
    )