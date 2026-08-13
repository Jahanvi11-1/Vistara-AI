import io
import json
import os
import traceback
from enum import Enum
from typing import List, Optional

from dotenv import load_dotenv
from fastapi import FastAPI, File, Form, HTTPException, Query, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import google.generativeai as genai
import pdfplumber
from pydantic import BaseModel, Field

# Load environment variables from .env
load_dotenv()

app = FastAPI(
    title="Vistara Contract Analysis API",
    description="AI-powered contract risk analysis using Google Gemini API",
    version="1.0.0"
)

# ---------------------------------------------------------------------------
# CORS Middleware Configuration (Fixes Browser CORS Errors)
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,  # Set to False to allow wildcard origins in browsers
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Data Models (Pydantic & Enums)
# ---------------------------------------------------------------------------
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
    overall_score: int = Field(..., ge=0, le=100)  # 0-100 score
    risk_level: str
    high_risk_count: int
    medium_risk_count: int
    low_risk_count: int
    flagged_clauses: List[ClauseRisk]


# ---------------------------------------------------------------------------
# Mock Report Data
# ---------------------------------------------------------------------------
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
                "Your lease renews itself for another full year unless you send a formal "
                "written notice 90 days before it ends. Missing that window locks you in."
            ),
            worst_case_scenario=(
                "You forget to send notice in time, get automatically locked into another "
                "12-month lease, and owe a full year's rent even if you need to move out."
            ),
        ),
        ClauseRisk(
            clause_text=(
                "Tenant shall be solely responsible for any and all damages to the premises, "
                "including structural repairs, plumbing, electrical systems, and appliances, "
                "regardless of cause."
            ),
            severity=SeverityLevel.high,
            category="Liability",
            plain_explanation=(
                "You are on the hook for all repairs — even things that break through normal "
                "wear, pre-existing issues, or causes outside your control."
            ),
            worst_case_scenario=(
                "A pipe bursts due to building age, and you are billed thousands of dollars "
                "for structural repairs that are legally the landlord's responsibility."
            ),
        ),
        ClauseRisk(
            clause_text=(
                "Landlord may enter the premises at any time with or without notice for "
                "inspection, maintenance, or any other purpose deemed necessary."
            ),
            severity=SeverityLevel.medium,
            category="Privacy / Entry Rights",
            plain_explanation=(
                "The landlord can walk in whenever they want without telling you first, "
                "which violates standard tenant privacy rights in most jurisdictions."
            ),
            worst_case_scenario=(
                "Your landlord enters repeatedly without warning, disrupting your life and "
                "potentially violating local tenant protection laws."
            ),
        ),
        ClauseRisk(
            clause_text="Tenant agrees to keep noise levels to a minimum after 9:00 PM on weekdays.",
            severity=SeverityLevel.low,
            category="Noise / Conduct",
            plain_explanation="Standard quiet-hours clause, earlier than typical but not unusual.",
            worst_case_scenario=(
                "Landlord uses a minor noise complaint as grounds to initiate eviction proceedings."
            ),
        ),
    ],
)


# ---------------------------------------------------------------------------
# PDF Helper Function
# ---------------------------------------------------------------------------
def extract_text_from_pdf(file_bytes: bytes) -> str:
    """Extract all plain text from a PDF file using pdfplumber."""
    text_parts = []
    with pdfplumber.open(io.BytesIO(file_bytes)) as pdf:
        for page in pdf.pages:
            page_text = page.extract_text()
            if page_text:
                text_parts.append(page_text)
    return "\n".join(text_parts)


SYSTEM_PROMPT = """\
You are an expert contract risk analysis AI. Analyze the provided contract text and return a JSON object \
that strictly matches the following schema — no extra keys, no markdown fences, raw JSON only:

{
  "filename": "<string>",
  "overall_score": <integer 0-100, where 0 = extremely hazardous, 100 = completely safe>,
  "risk_level": "<High | Medium | Low>",
  "high_risk_count": <integer>,
  "medium_risk_count": <integer>,
  "low_risk_count": <integer>,
  "flagged_clauses": [
    {
      "clause_text": "<exact quote from contract>",
      "severity": "<High | Medium | Low>",
      "category": "<short category name>",
      "plain_explanation": "<plain English explanation>",
      "worst_case_scenario": "<worst realistic outcome for the signer>"
    }
  ]
}

CRITICAL:
1. Ensure "severity" values inside "flagged_clauses" are capitalized exactly as "High", "Medium", or "Low".
2. Be thorough and flag every clause that poses a potential risk, liability trap, or unfair burden on the user.
"""


# ---------------------------------------------------------------------------
# Gemini AI Analysis Function
# ---------------------------------------------------------------------------
async def analyze_with_gemini(contract_text: str, filename: str) -> ContractReport:
    """Send contract text to Google Gemini API and parse into ContractReport."""
    # Read Gemini key from environment
    api_key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="GEMINI_API_KEY is missing in your .env file.",
        )

    try:
        # Configure Gemini Client
        genai.configure(api_key=api_key)
        
        # Use gemini-2.5-flash model with forced JSON response output
        model = genai.GenerativeModel(
            model_name="gemini-2.5-flash",
            generation_config={"response_mime_type": "application/json"}
        )

        user_prompt = f"{SYSTEM_PROMPT}\n\nFilename: {filename}\n\nContract Text:\n{contract_text[:15000]}"

        response = model.generate_content(user_prompt)

        raw_json = response.text.strip()
        data = json.loads(raw_json)

        # Ensure filename is preserved correctly
        data["filename"] = filename

        # Normalize severity strings if Gemini produces lowercase values
        if "flagged_clauses" in data and isinstance(data["flagged_clauses"], list):
            for clause in data["flagged_clauses"]:
                if isinstance(clause, dict) and "severity" in clause:
                    clause["severity"] = str(clause["severity"]).capitalize()

        return ContractReport(**data)

    except json.JSONDecodeError as e:
        print(f"JSON Parsing Error: {e}")
        raise HTTPException(
            status_code=500,
            detail="Gemini API returned an invalid JSON response structure.",
        )
    except Exception as e:
        print(f"Server Error during Gemini analysis:\n{traceback.format_exc()}")
        raise HTTPException(
            status_code=500,
            detail=f"Gemini API analysis failed: {str(e)}",
        )


# ---------------------------------------------------------------------------
# API Endpoints
# ---------------------------------------------------------------------------
@app.get("/")
async def root():
    return {"status": "ok", "message": "Vistara Contract Analysis API (Gemini Powered) is running"}


@app.post("/analyze", response_model=ContractReport)
async def analyze_contract(
    mock: bool = Query(False),
    file: Optional[UploadFile] = File(None),
    text: Optional[str] = Form(None),
):
    """
    Analyzes a contract for risky clauses using Google Gemini AI.

    - Set `mock=true` to get a sample response instantly without making an API request.
    - Provide either `file` (PDF/text upload) or `text` (raw pasted string).
    """
    if mock:
        return MOCK_REPORT

    filename = "contract.txt"
    contract_text = ""

    # Process uploaded file or form text
    if file is not None:
        filename = file.filename or "upload.pdf"
        file_bytes = await file.read()

        if filename.lower().endswith(".pdf"):
            contract_text = extract_text_from_pdf(file_bytes)
        else:
            contract_text = file_bytes.decode("utf-8", errors="replace")

    elif text:
        contract_text = text

    else:
        raise HTTPException(
            status_code=422,
            detail="Provide either a file upload or text in the request body.",
        )

    if not contract_text.strip():
        raise HTTPException(
            status_code=422,
            detail="Could not extract any readable text from the provided input.",
        )

    return await analyze_with_gemini(contract_text, filename)