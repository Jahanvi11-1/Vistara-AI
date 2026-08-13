# Vistara

AI-powered contract analysis tool that helps users understand legal documents in plain language and identify risky clauses before signing.

## Overview

Vistara is a cross-platform mobile and desktop application built with Flutter that analyzes contracts and legal documents to identify potential risks. It uses AI to break down complex legal language into plain English explanations and worst-case scenarios, empowering users to make informed decisions.

## Features

- **Document Upload**: Support for PDF and text file uploads
- **AI Analysis**: OpenAI-powered contract risk assessment
- **Risk Classification**: Categorizes clauses by severity (High, Medium, Low)
- **Plain Language Explanations**: Translates legalese into understandable terms
- **Worst-Case Scenarios**: Shows potential consequences of risky clauses
- **Recent Documents**: Track previously analyzed contracts
- **Risk Scoring**: Overall contract safety score (0-100)
- **Cross-Platform**: Works on iOS, Android, macOS, Linux, Windows, and Web

## Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.13+
- **Language**: Dart
- **UI**: Material Design 3
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **File Handling**: file_picker package
- **Storage**: shared_preferences
- **Typography**: Google Fonts

### Backend (Python)
- **Framework**: FastAPI
- **AI Integration**: GEMINI API KEY
- **PDF Processing**: pdfplumber
- **API Documentation**: Auto-generated with FastAPI
- **CORS**: Enabled for local development

## Project Structure

```
vistara/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── contract_report.dart  # Data models
│   ├── screens/
│   │   ├── home_screen.dart      # Home dashboard
│   │   ├── analyze_screen.dart   # Upload interface
│   │   ├── analyzing_screen.dart # Processing state
│   │   ├── report_screen.dart    # Results display
│   │   ├── risk_detail_screen.dart # Clause details
│   │   └── recent_documents_screen.dart # History
│   └── services/
│       ├── api_service.dart      # Backend communication
│       └── storage_service.dart  # Local persistence
└── design_assets/                # UI mockups and specs

vistara-backend/
└── main.py                       # FastAPI server
```

## Getting Started

### Prerequisites

- Flutter SDK 3.13 or higher
- Python 3.10+ (for backend)
- OpenAI API key

### Frontend Setup

```bash
cd vistara
flutter pub get
flutter run
```

### Backend Setup

```bash
cd vistara-backend
pip install fastapi uvicorn openai pdfplumber python-multipart
export OPENAI_API_KEY=your_api_key_here
uvicorn main:app --reload
```

### Running on Different Platforms

```bash
# Mobile
flutter run -d android
flutter run -d ios

# Desktop
flutter run -d macos
flutter run -d windows
flutter run -d linux

# Web
flutter run -d chrome
```

## API Endpoints

### POST `/analyze`

Analyzes a contract document and returns risk assessment.

**Parameters:**
- `file` (optional): PDF or text file upload
- `text` (optional): Raw contract text
- `mock` (optional): Boolean to return mock data

**Response:**
```json
{
  "filename": "string",
  "overall_score": 0-100,
  "risk_level": "High|Medium|Low",
  "high_risk_count": 0,
  "medium_risk_count": 0,
  "low_risk_count": 0,
  "flagged_clauses": [
    {
      "clause_text": "string",
      "severity": "High|Medium|Low",
      "category": "string",
      "plain_explanation": "string",
      "worst_case_scenario": "string"
    }
  ]
}
```

## Development

### Building for Production

```bash
# Android APK
flutter build apk

# iOS
flutter build ios

# macOS
flutter build macos

# Windows
flutter build windows

# Web
flutter build web
```

## Color Scheme

- Primary: Purple (#6B4FA0)
- Design tokens support Lilac and Ochre variations

## Dependencies

### Flutter Packages
- `cupertino_icons: ^1.0.8` - iOS-style icons
- `http: ^1.2.0` - HTTP client
- `file_picker: ^8.0.0` - File selection
- `shared_preferences: ^2.2.2` - Local storage
- `google_fonts: ^6.1.0` - Typography

### Python Packages
- `fastapi` - Web framework
- `uvicorn` - ASGI server
- `openai` - AI integration
- `pdfplumber` - PDF text extraction
- `pydantic` - Data validation

## License

This project is private and not published to pub.dev.

## Contributing

This is a private project. For questions or issues, contact the development team.

## Support

For help with Flutter development:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter API Reference](https://api.flutter.dev/)
- [Dart Language Tour](https://dart.dev/language)
