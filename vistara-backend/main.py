import io
import json
import os
import traceback
from enum import Enum
from typing import List, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, File, Form, HTTPException, Query, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from google import genai
from google.genai import types
import pdfplumber
from pydantic import BaseModel, Field


# ============================================================================
# ENVIRONMENT
# ============================================================================

load_dotenv()


# ============================================================================
# GEMINI CONFIGURATION
# ============================================================================

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# You can change the model later without changing the code.
GEMINI_MODEL = os.getenv(
    "GEMINI_MODEL",
    "gemini-3.6-flash",
)


# ============================================================================
# FASTAPI APP
# ============================================================================

app = FastAPI(
    title="Vistara Contract Analysis API",
    description="AI-powered contract risk analysis using Google Gemini",
    version="1.0.0",
)


# ============================================================================
# CORS
# ============================================================================

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


class ClauseRisk(BaseModel):
    clause_text: str
    severity: SeverityLevel
    category: str
    plain_explanation: str
    worst_case_scenario: str


class ContractReport(BaseModel):
    filename: str
    overall_score: int = Field(..., ge=0, le=100)
    risk_level: str
    high_risk_count: int
    medium_risk_count: int
    low_risk_count: int
    flagged_clauses: List[ClauseRisk]


# ============================================================================
# MOCK REPORT
# ============================================================================

MOCK_REPORT = ContractReport(
    filename="apartment_lease_mock.pdf",
    overall_score=28,
    risk_level="High",
    high_risk_count=2,
    medium_risk_count=1,
    low_risk_count=1,
    flagged_clauses=[
        ClauseRisk(
            clause_text=(
                "This lease shall automatically renew for successive one-year terms "
                "unless Tenant provides written notice of non-renewal at least 90 days "
                "prior to the end of the then-current term."
            ),
            severity=SeverityLevel.high,
            category="Automatic Renewal",
            plain_explanation=(
                "Your lease renews itself for another full year unless you send a "
                "formal written notice 90 days before it ends. Missing that window "
                "locks you in."
            ),
            worst_case_scenario=(
                "You forget to send notice in time, get automatically locked into "
                "another 12-month lease, and owe a full year's rent even if you "
                "need to move out."
            ),
        ),
        ClauseRisk(
            clause_text=(
                "Tenant shall be solely responsible for any and all damages to the "
                "premises, including structural repairs, plumbing, electrical systems, "
                "and appliances, regardless of cause."
            ),
            severity=SeverityLevel.high,
            category="Liability",
            plain_explanation=(
                "You are on the hook for all repairs — even things that break through "
                "normal wear, pre-existing issues, or causes outside your control."
            ),
            worst_case_scenario=(
                "A pipe bursts due to building age, and you are billed thousands of "
                "dollars for structural repairs that are legally the landlord's "
                "responsibility."
            ),
        ),
        ClauseRisk(
            clause_text=(
                "Landlord may enter the premises at any time with or without notice "
                "for inspection, maintenance, or any other purpose deemed necessary."
            ),
            severity=SeverityLevel.medium,
            category="Privacy / Entry Rights",
            plain_explanation=(
                "The landlord can walk in whenever they want without telling you "
                "first, which violates standard tenant privacy rights in many "
                "jurisdictions."
            ),
            worst_case_scenario=(
                "Your landlord enters repeatedly without warning, disrupting your "
                "life and potentially violating local tenant protection laws."
            ),
        ),
        ClauseRisk(
            clause_text=(
                "Tenant agrees to keep noise levels to a minimum after 9:00 PM "
                "on weekdays."
            ),
            severity=SeverityLevel.low,
            category="Noise / Conduct",
            plain_explanation=(
                "Standard quiet-hours clause, earlier than typical but not unusual."
            ),
            worst_case_scenario=(
                "Landlord uses a minor noise complaint as grounds to initiate "
                "eviction proceedings."
            ),
        ),
    ],
)


# ============================================================================
# PDF TEXT EXTRACTION
# ============================================================================

def extract_text_from_pdf(file_bytes: bytes) -> str:
    """
    Extract readable text from a PDF using pdfplumber.
    """

    text_parts = []

    with pdfplumber.open(io.BytesIO(file_bytes)) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()

            if page_text:
                text_parts.append(page_text)

    return "\n".join(text_parts)


# ============================================================================
# GEMINI SYSTEM PROMPT
# ============================================================================

SYSTEM_PROMPT = """
You are Vistara, an expert contract risk analysis AI.

Analyze the provided contract and identify clauses that may create:

- financial risks
- liabilities
- unfair obligations
- termination penalties
- automatic renewals
- privacy concerns
- unusual restrictions
- excessive responsibilities
- potentially unfavorable conditions

For every materially relevant risky clause:

1. Quote or closely reproduce the relevant clause.
2. Assign exactly one severity:
   High, Medium, or Low.
3. Give a clear risk category.
4. Explain the clause in simple plain English.
5. Explain a realistic worst-case scenario.

Scoring:

- overall_score must be an integer from 0 to 100.
- 0 = extremely hazardous.
- 100 = very safe.

Risk level must be:

High, Medium, or Low.

Important:

- Do not invent clauses.
- Base the analysis only on the supplied contract.
- Severity values must strictly be High, Medium, or Low.
- Return ONLY valid JSON matching the requested schema.
"""


# ============================================================================
# GEMINI ANALYSIS
# ============================================================================

async def analyze_with_gemini(
    contract_text: str,
    filename: str,
) -> ContractReport:

    # ------------------------------------------------------------------------
    # Check API key
    # ------------------------------------------------------------------------

    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail=(
                "GEMINI_API_KEY is missing. "
                "Add your Google AI Studio API key to the .env file."
            ),
        )

    try:

        # --------------------------------------------------------------------
        # Initialize Google GenAI client using API KEY
        # --------------------------------------------------------------------

        client = genai.Client(
            api_key=api_key,
        )

        # --------------------------------------------------------------------
        # Prompt
        # --------------------------------------------------------------------

        user_prompt = (
            f"Filename: {filename}\n\n"
            f"Contract Text:\n{contract_text[:15000]}"
        )

        # --------------------------------------------------------------------
        # Structured output schema
        # --------------------------------------------------------------------

        response_schema = {
            "type": "OBJECT",
            "properties": {
                "filename": {
                    "type": "STRING",
                },
                "overall_score": {
                    "type": "INTEGER",
                },
                "risk_level": {
                    "type": "STRING",
                    "enum": [
                        "High",
                        "Medium",
                        "Low",
                    ],
                },
                "high_risk_count": {
                    "type": "INTEGER",
                },
                "medium_risk_count": {
                    "type": "INTEGER",
                },
                "low_risk_count": {
                    "type": "INTEGER",
                },
                "flagged_clauses": {
                    "type": "ARRAY",
                    "items": {
                        "type": "OBJECT",
                        "properties": {
                            "clause_text": {
                                "type": "STRING",
                            },
                            "severity": {
                                "type": "STRING",
                                "enum": [
                                    "High",
                                    "Medium",
                                    "Low",
                                ],
                            },
                            "category": {
                                "type": "STRING",
                            },
                            "plain_explanation": {
                                "type": "STRING",
                            },
                            "worst_case_scenario": {
                                "type": "STRING",
                            },
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

        # --------------------------------------------------------------------
        # Gemini request
        # --------------------------------------------------------------------

        response = client.models.generate_content(
            model=GEMINI_MODEL,
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=SYSTEM_PROMPT,
                temperature=0.2,
                response_mime_type="application/json",
                response_schema=response_schema,
            ),
        )

        # --------------------------------------------------------------------
        # Get response text
        # --------------------------------------------------------------------

        if not response.text:
            raise HTTPException(
                status_code=500,
                detail="Gemini returned an empty response.",
            )

        # --------------------------------------------------------------------
        # Parse JSON
        # --------------------------------------------------------------------

        try:
            report_data = json.loads(response.text)

        except json.JSONDecodeError as e:
            print("JSON Parsing Error:", e)
            print("Gemini response:", response.text)

            raise HTTPException(
                status_code=500,
                detail="Gemini returned invalid JSON.",
            )

        # --------------------------------------------------------------------
        # Always trust the actual uploaded filename
        # --------------------------------------------------------------------

        report_data["filename"] = filename

        # --------------------------------------------------------------------
        # Validate using Pydantic
        # --------------------------------------------------------------------

        report = ContractReport(**report_data)

        return report

    # ------------------------------------------------------------------------
    # HTTP errors from our API
    # ------------------------------------------------------------------------

    except HTTPException:
        raise

    # ------------------------------------------------------------------------
    # Gemini/API errors
    # ------------------------------------------------------------------------

    except Exception as e:

        error_text = str(e)

        print(
            "Gemini API Error:\n"
            f"{traceback.format_exc()}"
        )

        # ------------------------------------------------------------
        # Handle quota / rate limit specifically
        # ------------------------------------------------------------

        if (
            "429" in error_text
            or "RESOURCE_EXHAUSTED" in error_text
            or "quota" in error_text.lower()
        ):
            raise HTTPException(
                status_code=429,
                detail=(
                    "Gemini API quota has been exceeded. "
                    "Please check your Google AI Studio project quota "
                    "or try again later."
                ),
            )

        # ------------------------------------------------------------
        # Handle authentication errors specifically
        # ------------------------------------------------------------

        if (
            "401" in error_text
            or "UNAUTHENTICATED" in error_text
            or "authentication" in error_text.lower()
        ):
            raise HTTPException(
                status_code=401,
                detail=(
                    "Gemini API authentication failed. "
                    "Check that GEMINI_API_KEY in .env contains "
                    "a valid Google AI Studio API key."
                ),
            )

        # ------------------------------------------------------------
        # General error
        # ------------------------------------------------------------

        raise HTTPException(
            status_code=500,
            detail=f"Gemini API analysis failed: {error_text}",
        )


# ============================================================================
# ROOT ENDPOINT
# ============================================================================

@app.get("/")
async def root():
    return {
        "status": "ok",
        "message": (
            "Vistara Contract Analysis API "
            "(Gemini API Key Powered) is running"
        ),
    }


# ============================================================================
# ANALYZE ENDPOINT
# ============================================================================

@app.post(
    "/analyze",
    response_model=ContractReport,
)
async def analyze_contract(
    mock: bool = Query(False),
    file: Optional[UploadFile] = File(None),
    text: Optional[str] = Form(None),
):

    # ------------------------------------------------------------------------
    # Mock mode
    # ------------------------------------------------------------------------

    if mock:
        return MOCK_REPORT

    filename = "contract.txt"
    contract_text = ""

    # ------------------------------------------------------------------------
    # File upload
    # ------------------------------------------------------------------------

    if file is not None:

        filename = file.filename or "upload.pdf"

        file_bytes = await file.read()

        if not file_bytes:
            raise HTTPException(
                status_code=422,
                detail="Uploaded file is empty.",
            )

        # ------------------------------------------------------------
        # PDF
        # ------------------------------------------------------------

        if filename.lower().endswith(".pdf"):

            try:
                contract_text = extract_text_from_pdf(
                    file_bytes,
                )

            except Exception as e:

                raise HTTPException(
                    status_code=422,
                    detail=f"Could not read PDF: {str(e)}",
                )

        # ------------------------------------------------------------
        # Other readable files
        # ------------------------------------------------------------

        else:

            contract_text = file_bytes.decode(
                "utf-8",
                errors="replace",
            )

    # ------------------------------------------------------------------------
    # Raw text
    # ------------------------------------------------------------------------

    elif text:

        filename = "contract.txt"
        contract_text = text

    # ------------------------------------------------------------------------
    # Nothing supplied
    # ------------------------------------------------------------------------

    else:

        raise HTTPException(
            status_code=422,
            detail=(
                "Provide either a file upload "
                "or text in the request body."
            ),
        )

    # ------------------------------------------------------------------------
    # Validate extracted text
    # ------------------------------------------------------------------------

    if not contract_text.strip():

        raise HTTPException(
            status_code=422,
            detail=(
                "Could not extract any readable text "
                "from the provided input."
            ),
        )

    # ------------------------------------------------------------------------
    # Gemini analysis
    # ------------------------------------------------------------------------

    return await analyze_with_gemini(
        contract_text=contract_text,
        filename=filename,
    )