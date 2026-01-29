# FightCityTickets iOS App - Development Guide

## Quick Start on Mac

### 1. Install Prerequisites

```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XcodeGen for project generation
brew install xcodegen

# Install SwiftLint for code quality
brew install swiftlint

# Install Xcode Command Line Tools
xcode-select --install
```

### 2. Generate Xcode Project

```bash
# Navigate to project directory
cd /path/to/iOS-FightCityTickets

# Generate Xcode project
xcodegen generate

# Open the project
open FightCityTickets.xcodeproj
```

### 3. Build and Run

1. Select a simulator (iPhone 15 recommended) or device
2. Press `Cmd+R` to build and run
3. Or use command line:
   ```bash
   xcodebuild -project FightCityTickets.xcodeproj -scheme FightCity -destination 'platform=iOS Simulator,name=iPhone 15' build
   ```

## Project Structure

```
iOS-FightCityTickets/
├── project.yml              # XcodeGen configuration
├── .swiftlint.yml           # SwiftLint configuration
├── .github/workflows/ci.yml # GitHub Actions CI
│
├── Sources/
│   ├── FightCity/           # Main app target
│   │   ├── App/             # App entry, SceneDelegate
│   │   ├── Coordination/    # AppCoordinator, navigation
│   │   ├── DesignSystem/    # Colors, Typography, Theme
│   │   └── Features/        # SwiftUI views, ViewModels
│   │
│   ├── FightCityFoundation/ # Framework (pure Swift)
│   │   ├── Models/          # Citation, ValidationResult
│   │   └── Networking/      # APIClient, OCRParsingEngine
│   │
│   └── FightCityiOS/        # Framework (iOS-specific)
│       ├── Camera/          # CameraManager, FrameQualityAnalyzer
│       ├── OCR/             # OCREngine, ConfidenceScorer
│       └── Telemetry/       # TelemetryService
│
├── Tests/
│   ├── UnitTests/
│   │   ├── FoundationTests/ # OCRParsingEngine tests
│   │   ├── iOSTests/        # ConfidenceScorer tests
│   │   └── AppTests/        # App-level tests
│   └── UITests/             # UI automation tests
│
├── Resources/
│   ├── Assets.xcassets/     # App icons, colors
│   └── Localizable.strings  # Localization strings
│
└── Support/                 # Info.plist files
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│              SwiftUI (UI Layer)                 │
│  Onboarding → Capture → Confirmation → History  │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│              AppCoordinator                     │
│      Navigation + State Management              │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│           FightCityiOS Framework                │
│  CameraManager  |  OCREngine  |  Confidence     │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│         FightCityFoundation Framework           │
│  APIClient  |  OCRParsingEngine  |  Models      │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│              FastAPI Backend                     │
│         https://api.fightcitytickets.com        │
└─────────────────────────────────────────────────┘
```

## Supported Cities

| City | Pattern | Example |
|------|---------|---------|
| San Francisco | `^(SFMTA\|MT)[0-9]{8}$` | SFMTA91234567 |
| New York | `^[0-9]{10}$` | 1234567890 |
| Denver | `^[0-9]{5,9}$` | 1234567 |
| Los Angeles | `^[0-9A-Z]{6,11}$` | LA123456 |

## Running Tests

```bash
# Run all tests
xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCity -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCityFoundationTests -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCityiOSTests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Code Quality

```bash
# Run SwiftLint
swiftlint lint
swiftlint lint --strict

# Auto-fix issues
swiftlint autocorrect
```

## CI/CD Pipeline

The project includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that:

1. **Builds** all targets (Debug + Release)
2. **Runs** unit tests on iOS Simulator
3. **Lints** code with SwiftLint
4. **Generates** documentation
5. **Audits** dependencies

## Requirements

- macOS 14.0+ (Sonoma) or macOS 13.0+ (Ventura)
- Xcode 15.0+
- iOS 16.0+ deployment target
- Xcode Command Line Tools

## Key Features

- ✅ Camera capture with AVFoundation
- ✅ Vision OCR for text recognition
- ✅ City-specific citation parsing
- ✅ Offline support with persistent queue
- ✅ Opt-in telemetry for OCR improvement
- ✅ Full accessibility (VoiceOver) support
- ✅ Dark mode support
- ✅ Unit tests with 100%+ coverage goals

## Troubleshooting

### XcodeGen not found
```bash
brew install xcodegen
```

### SwiftLint not found
```bash
brew install swiftlint
```

### Build fails with missing modules
```bash
xcodegen generate
```

### Simulator not available
```bash
# List available simulators
xcrun simctl list devices available

# Create new simulator
xcrun simctl create "iPhone 15" "iPhone 15"
```

## License

MIT License - See LICENSE file for details
