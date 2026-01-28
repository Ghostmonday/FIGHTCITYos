# FightCityTickets iOS App - Windows Build Setup

## Quick Start for Windows Users

Since iOS apps require macOS to build, you have these options:

### Option 1: GitHub Actions (Free - Recommended)

1. Push this project to a GitHub repository:
   ```powershell
   git init
   git add .
   git commit -m "Initial iOS app"
   git remote add origin https://github.com/YOUR_USERNAME/FightCityTickets-iOS
   git push -u origin main
   ```

2. Go to your repository's "Actions" tab
3. The iOS Build workflow will run automatically
4. Download .ipa files from the Actions tab

### Option 2: Codemagic (Free Tier)

1. Go to https://codemagic.io/start/
2. Connect your GitHub account
3. Select this repository
4. Codemagic auto-detects iOS project
5. Build and download .ipa

### Option 3: Transfer to Mac

Copy the project folder to a Mac and run:
```bash
brew install xcodegen
xcodegen generate
open FightCityTickets.xcodeproj
```

## Project Files

| File | Purpose |
|------|---------|
| `project.yml` | XcodeGen configuration (edit on Windows) |
| `App/*.swift` | App entry and navigation |
| `Core/Camera/*.swift` | Camera capture layer |
| `Core/OCR/*.swift` | Vision OCR pipeline |
| `Domain/Models/*.swift` | Data models |
| `Network/*.swift` | API client, offline queue |
| `UI/Screens/*.swift` | SwiftUI screens |

## Architecture

```
┌─────────────────────────────────────┐
│         SwiftUI (UI Layer)          │
│  Onboarding → Capture → Confirm     │
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│     UIKit + AVFoundation (Camera)   │
│  CameraManager, FrameQualityAnalyzer│
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│        Vision Framework (OCR)       │
│  OCREngine, OCRParsingEngine        │
└─────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────┐
│         FastAPI Backend             │
│  /api/citations/validate            │
└─────────────────────────────────────┘
```

## Key Features

- Camera capture with AVFoundation
- Vision OCR for text recognition
- City-specific citation parsing (SF, LA, NYC, Denver)
- Offline support with persistent queue
- Opt-in telemetry for OCR improvement
- Accessibility (VoiceOver) support

## Build Status

| Status | Badge |
|--------|-------|
| CI/CD | GitHub Actions |
| Code Quality | SwiftLint Ready |
| Tests | Unit Tests Ready |

## Requirements

- iOS 16.0+
- No third-party dependencies
- Native frameworks only:
  - AVFoundation
  - Vision
  - Security
  - CoreImage
