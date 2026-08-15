# Vistara

AI-powered contract risk analysis tool that helps users understand legal documents in plain language and identify risky clauses before signing.

## Overview

Vistara is a cross-platform application built with Flutter (frontend) and FastAPI (backend). It uses Google Gemini AI to analyze contracts, break down complex legal language into plain English, and surface potential risks with worst-case scenario explanations — empowering users to make informed decisions before signing anything.

---

## Features

- **Document Upload** — supports PDF and plain text file uploads
- **AI Analysis** — Google Gemini-powered contract risk assessment
- **Risk Classification** — flags clauses by severity: High, Medium, or Low
- **Plain Language Explanations** — translates legal jargon into simple terms
- **Worst-Case Scenarios** — shows realistic consequences of risky clauses
- **Risk Scoring** — overall contract safety score from 0 (dangerous) to 100 (safe)
- **Recent Documents** — tracks previously analyzed contracts locally
- **PDF Viewer** — view the original contract inside the app
- **Mock Mode** — test the UI without an API key
- **Cross-Platform** — iOS, Android, macOS, Windows, Linux, and Web

---

## Tech Stack

### Frontend — `vistara/` (Flutter)

| | |
|---|---|
| Framework | Flutter 3.13+ / Dart SDK `>=3.0.0 <=4.0.0` |
| UI | Material Design 3, Google Fonts (Poppins) |
| State management | `StatefulWidget` |
| HTTP client | `http ^1.2.0` |
| File picker | `file_picker ^11.0.3` |
| PDF viewer | `pdfrx ^2.4.7` |
| Local storage | `shared_preferences ^2.2.2` |
| Typography | `google_fonts ^6.1.0` |

### Backend — `vistara-backend/` (Python)

| | |
|---|---|
| Framework | FastAPI `0.135.1` + Uvicorn |
| AI | Google Gemini via `google-genai` |
| Model | `gemini-3.6-flash` (configurable via `GEMINI_MODEL` env var) |
| PDF processing | `pdfplumber` |
| Validation | Pydantic |
| Env management | `python-dotenv` |

---

## Project Structure

```
Vistara/
├── .gitignore                         # Root-level gitignore
├── README.md
├── design.md                          # UI/UX design notes
│
├── vistara/                           # Flutter frontend
│   ├── lib/
│   │   ├── main.dart                  # App entry point
│   │   ├── models/
│   │   │   └── contract_report.dart   # Data models
│   │   ├── screens/
│   │   │   ├── home_screen_stateful.dart
│   │   │   ├── analyze_screen.dart    # Upload interface
│   │   │   ├── analyzing_screen.dart  # Processing state
│   │   │   ├── report_screen.dart     # Results display
│   │   │   ├── risk_detail_screen.dart
│   │   │   ├── recent_documents_screen.dart
│   │   │   ├── document_viewer_screen.dart
│   │   │   ├── reports_screen.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── main_navigation.dart
│   │   │   └── settings_screen.dart
│   │   ├── services/
│   │   │   ├── api_service.dart       # Backend communication
│   │   │   └── storage_service.dart   # Local persistence
│   │   ├── theme/
│   │   │   └── vistara_theme.dart     # App theme & colors
│   │   └── widgets/
│   │       └── vistara_bottom_nav.dart
│   ├── assets/
│   │   └── test/contract3.pdf         # Sample test contract
│   ├── pubspec.yaml
│   └── .gitignore
│
└── vistara-backend/                   # Python FastAPI backend
    ├── main.py                        # API server + Gemini integration
    ├── requirements.txt
    ├── .env                           # Local secrets (not committed)
    ├── .env.example                   # Template for env setup
    └── .gitignore
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.13+
- Python 3.10+
- A Google Gemini API key — [get one at Google AI Studio](https://aistudio.google.com/app/apikey)

---

### Backend Setup

```bash
cd vistara-backend

# Create and activate a virtual environment
python -m venv venv
source venv/bin/activate        # macOS/Linux
venv\Scripts\activate           # Windows

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Open .env and add your Gemini API key:
# GEMINI_API_KEY=your_key_here

# Start the server
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`.
Auto-generated docs at `http://localhost:8000/docs`.

---

### Frontend Setup

```bash
cd vistara
flutter pub get
flutter run
```

To run on a specific platform:

```bash
flutter run -d android
flutter run -d ios
flutter run -d macos
flutter run -d windows
flutter run -d linux
flutter run -d chrome
```

---

## API Reference

### `GET /`
Health check. Returns API status.

### `POST /analyze`
Analyzes a contract and returns a structured risk report.

**Query parameters:**
- `mock` _(bool, optional)_ — returns sample data without calling Gemini, useful for UI testing

**Body** `multipart/form-data`:
- `file` _(optional)_ — PDF or text file upload
- `text` _(optional)_ — raw contract text

**Response:**
```json
{
  "filename": "contract.pdf",
  "overall_score": 28,
  "risk_level": "High",
  "high_risk_count": 2,
  "medium_risk_count": 1,
  "low_risk_count": 1,
  "flagged_clauses": [
    {
      "clause_text": "...",
      "severity": "High",
      "category": "Automatic Renewal",
      "plain_explanation": "...",
      "worst_case_scenario": "..."
    }
  ]
}
```

> `overall_score`: 0 = extremely hazardous, 100 = very safe.

---

## Building for Production

```bash
# Android
flutter build apk
flutter build appbundle

# iOS
flutter build ios

# macOS
flutter build macos

# Windows
flutter build windows

# Web
flutter build web
```

---

## Design

- Primary color: Purple `#6B4FA0`
- Font: Poppins (via Google Fonts)
- Design system: Material Design 3

---

## Environment Variables

| Variable | Required | Description |
|---|---|---|
| `GEMINI_API_KEY` | Yes | Google AI Studio API key |
| `GEMINI_MODEL` | No | Gemini model name (default: `gemini-3.6-flash`) |

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Gemini API Documentation](https://ai.google.dev/gemini-api/docs)
- [Google AI Studio](https://aistudio.google.com/)
