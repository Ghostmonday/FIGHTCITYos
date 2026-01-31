# FightCityTickets 🚗📋

**A comprehensive iOS application for validating, managing, and appealing parking citations across multiple cities.**

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)

---

## 📖 Table of Contents

1. [Overview](#overview)
2. [Problem Statement](#problem-statement)
3. [Solution](#solution)
4. [Key Features](#key-features)
5. [Architecture](#architecture)
6. [Technology Stack](#technology-stack)
7. [Project Structure](#project-structure)
8. [Apple Intelligence Integration](#apple-intelligence-integration)
9. [API Integration](#api-integration)
10. [Setup & Installation](#setup--installation)
11. [Development Workflow](#development-workflow)
12. [Testing](#testing)
13. [Current Status](#current-status)
14. [Recent Changes](#recent-changes)
15. [Roadmap](#roadmap)
16. [Contributing](#contributing)
17. [Documentation](#documentation)
18. [License](#license)

---

## 🎯 Overview

**FightCityTickets** is a native iOS application designed to help citizens validate, track, and appeal parking citations across multiple municipalities. The app leverages Apple Intelligence features including VisionKit Document Scanner, Core ML classification, and NaturalLanguage processing to provide an intelligent, privacy-focused solution for citation management.

### What Makes This App Unique

- **Multi-City Support**: Handles citations from San Francisco, Los Angeles, New York City, Denver, and more
- **Apple Intelligence Powered**: Uses on-device ML for citation classification and appeal writing assistance
- **Privacy First**: All processing happens on-device; no data sent to third parties
- **Offline Capable**: Queue operations when offline, sync when connected
- **Intelligent Capture**: VisionKit Document Scanner with automatic enhancement
- **AI Appeal Writer**: NaturalLanguage-powered appeal letter generation with tone analysis

---

## 🎯 Problem Statement

Parking citations are issued by hundreds of municipalities, each with:
- **Unique citation number formats** (e.g., SFMTA12345678 vs NYC-2024-001234)
- **Different validation rules** and patterns
- **Varying appeal processes** and deadlines
- **Distinct deadline calculations** (some count business days, others calendar days)
- **Different payment systems** and portals

**Citizens struggle with:**
- Validating if a citation is legitimate
- Understanding deadline urgency
- Navigating complex appeal processes
- Tracking multiple citations across cities
- Writing effective appeal letters

---

## 💡 Solution

FightCityTickets provides a unified platform that:

1. **Captures** parking ticket images via camera or VisionKit Document Scanner
2. **Extracts** citation numbers using manual entry (OCR module removed in recent refactor)
3. **Validates** citations against city-specific patterns and backend APIs
4. **Classifies** citations using Core ML for city and type detection
5. **Tracks** citation history with deadline monitoring
6. **Assists** with appeal writing using AI-powered NaturalLanguage processing
7. **Stores** everything locally with offline queue support
8. **Works** seamlessly across multiple cities

---

## ✨ Key Features

### 📸 Image Capture & Processing

- **VisionKit Document Scanner** (iOS 16+)
  - Automatic document detection and cropping
  - Perspective correction
  - Glare reduction
  - Multi-page support
  - High-quality image enhancement

- **Traditional Camera Capture**
  - AVFoundation-based camera control
  - Real-time preview with quality analysis
  - Manual focus and exposure control
  - Torch/flashlight support
  - Camera switching (front/back)

- **Frame Quality Analysis**
  - Blur detection
  - Lighting assessment
  - Focus quality scoring
  - Real-time feedback to user

### 🧠 Apple Intelligence Features

#### Core ML Citation Classification
- **On-device ML model** for citation type detection
- **City identification** from citation text patterns
- **Confidence scoring** for classification results
- **Fallback to regex** when ML confidence is low
- **NaturalLanguage embeddings** for text analysis

**Location**: `Sources/FightCityFoundation/AI/CitationClassifier.swift`

#### AI-Powered Appeal Writer
- **NaturalLanguage framework** integration
- **Tone analysis** (professional, respectful, assertive)
- **Sentiment scoring** for appeal quality
- **Clarity improvements** suggestions
- **Grammar and style** recommendations
- **Sentence ranking** by impact

**Location**: `Sources/FightCityFoundation/AI/AppealWriter.swift`

#### VisionKit Document Scanner
- **Automatic document detection**
- **Intelligent cropping** to document boundaries
- **Perspective correction**
- **Glare reduction**
- **Multi-page scanning** support

**Location**: `Sources/FightCityiOS/Scanning/DocumentScanCoordinator.swift`

#### Live Text Integration (Planned)
- Real-time text recognition from camera
- Text selection and extraction
- Barcode/QR code detection

### 🏙️ Multi-City Support

Currently supports:
- **San Francisco** (SFMTA) - `us-ca-san_francisco`
- **Los Angeles** (LADOT) - `us-ca-los_angeles`
- **New York City** (DOF) - `us-ny-new_york`
- **Denver** - `us-co-denver`

Each city has:
- Custom citation number patterns
- Validation rules
- Appeal process configuration
- Deadline calculation logic

**Location**: `Sources/FightCityFoundation/Models/CityConfig.swift`

### 📊 Citation Management

- **Citation History**: Track all citations in one place
- **Deadline Tracking**: Automatic urgency calculation
- **Status Monitoring**: Track appeal status
- **Evidence Collection**: Attach photos and documents
- **Offline Storage**: Local persistence with Core Data

### 🔄 Offline Support

- **Persistent Queue**: Operations queued when offline
- **Automatic Sync**: Syncs when connection restored
- **Exponential Backoff**: Smart retry logic
- **Background Tasks**: Uploads in background

**Location**: `Sources/FightCityFoundation/Offline/OfflineQueueManager.swift`

### 📡 API Integration

- **Citation Validation**: `/api/v1/citations/validate`
- **Appeal Submission**: `/api/v1/appeals`
- **Status Lookup**: `/api/v1/status/lookup`
- **Telemetry Upload**: `/mobile/ocr/telemetry`

**Location**: `Sources/FightCityFoundation/Networking/APIClient.swift`

### 🎨 Design System

- **Comprehensive Theme System**: Light/Dark mode support
- **Typography Scale**: Display, Headline, Title, Body, Label styles
- **Color Palette**: Semantic colors for deadlines, confidence, status
- **Reusable Components**: Buttons, cards, indicators

**Location**: `Sources/FightCity/DesignSystem/`

---

## 🏗️ Architecture

### Three-Module Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    FightCity (App)                      │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Features (UI/ViewModels)                       │  │
│  │ ├── CaptureView + CaptureViewModel             │  │
│  │ ├── ConfirmationView                            │  │
│  │ ├── HistoryView                                 │  │
│  │ └── OnboardingView                               │  │
│  │                                                  │  │
│  │ DesignSystem (Theme/Typography/Components)      │  │
│  │ Configuration (AppConfig)                        │  │
│  │ Coordination (AppCoordinator)                    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ depends on
┌─────────────────────────────────────────────────────────┐
│                 FightCityiOS (iOS-Specific)               │
│  ┌──────────────────────────────────────────────────┐  │
│  │ Camera (CameraManager, CameraPreviewView)       │  │
│  │ Scanning (DocumentScanCoordinator)               │  │
│  │ Vision (SceneAnalyzer)                          │  │
│  │ Location (LocationVerifier)                     │  │
│  │ Voice (VoiceAppealRecorder)                      │  │
│  │ Telemetry (TelemetryService, TelemetryUploader) │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓ depends on
┌─────────────────────────────────────────────────────────┐
│            FightCityFoundation (Shared Logic)           │
│  ┌──────────────────────────────────────────────────┐  │
│  │ AI (CitationClassifier, AppealWriter)         │  │
│  │ Networking (APIClient, OfflineManager)          │  │
│  │ Models (Citation, CaptureResult, etc.)          │  │
│  │ Protocols (ServiceProtocols)                    │  │
│  │ Logging (Logger)                                │  │
│  │ Configuration (FeatureFlags)                     │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Module Responsibilities

#### FightCity (App Layer)
- **Purpose**: Main application entry point and UI
- **Responsibilities**:
  - SwiftUI views and view models
  - Navigation coordination
  - App configuration
  - Design system components
- **Dependencies**: FightCityiOS, FightCityFoundation

#### FightCityiOS (Platform Layer)
- **Purpose**: iOS-specific implementations
- **Responsibilities**:
  - Camera management (AVFoundation)
  - Document scanning (VisionKit)
  - Vision processing (Vision framework)
  - Location services (MapKit)
  - Voice recording (Speech)
  - Telemetry collection
- **Dependencies**: FightCityFoundation

#### FightCityFoundation (Business Logic)
- **Purpose**: Shared business logic and models
- **Responsibilities**:
  - AI/ML processing (Core ML, NaturalLanguage)
  - Network communication
  - Data models
  - Offline queue management
  - Logging
  - Feature flags
- **Dependencies**: None (pure Foundation)

### Design Patterns

- **MVVM**: ViewModels manage state and business logic
- **Actor Isolation**: CameraManager uses Swift actors for thread safety
- **Protocol-Oriented**: Service protocols enable testing and mocking
- **Dependency Injection**: Configurable dependencies via initializers
- **Feature Flags**: Gradual rollout of Apple Intelligence features

---

## 🛠️ Technology Stack

### Core Technologies

- **Language**: Swift 5.9
- **UI Framework**: SwiftUI + UIKit (for camera previews)
- **Minimum iOS**: 17.0 (with fallbacks for iOS 16+)
- **Build System**: XcodeGen (project.yml)
- **Package Manager**: None (all code in repo)

### Apple Frameworks

#### Core Frameworks
- **Foundation**: Core data structures and networking
- **SwiftUI**: Modern declarative UI
- **UIKit**: Camera previews and legacy components
- **Combine**: Reactive programming (where used)

#### Media & Vision
- **AVFoundation**: Camera capture and video processing
- **VisionKit**: Document Scanner (iOS 16+)
- **Vision**: Image analysis and text recognition
- **CoreImage**: Image processing

#### Apple Intelligence
- **CoreML**: On-device machine learning
- **NaturalLanguage**: Text analysis and classification
- **Speech**: Voice recognition for dictation

#### Platform Features
- **MapKit**: Location services and Look Around (iOS 17+)
- **BackgroundTasks**: Background uploads
- **AppIntents**: Siri Shortcuts integration (iOS 16+)
- **WidgetKit**: Home screen widgets (planned)
- **ActivityKit**: Live Activities (planned)

#### Security & Storage
- **Security**: Keychain access (planned)
- **UserDefaults**: Feature flag storage
- **FileManager**: Local file storage

### Development Tools

- **XcodeGen**: Project generation from YAML
- **SwiftLint**: Code quality enforcement
- **os.log**: Structured logging
- **Git**: Version control

---

## 📁 Project Structure

```
FIGHTCITYos/
├── Sources/
│   ├── FightCity/                    # Main App Layer
│   │   ├── App/
│   │   │   ├── FightCityApp.swift    # App entry point
│   │   │   └── SceneDelegate.swift   # Scene lifecycle
│   │   ├── Features/                 # Feature modules
│   │   │   ├── Capture/             # Camera & capture
│   │   │   ├── Confirmation/        # Citation confirmation
│   │   │   ├── History/             # Citation history
│   │   │   ├── Onboarding/          # First-run experience
│   │   │   └── Root/                # Main content view
│   │   ├── DesignSystem/            # UI components
│   │   │   ├── Colors.swift         # Color palette
│   │   │   ├── Components.swift     # Reusable components
│   │   │   ├── Theme.swift          # Theme system
│   │   │   └── Typography.swift     # Font system
│   │   ├── Configuration/           # App configuration
│   │   │   └── AppConfig.swift      # City configs, URLs
│   │   ├── Coordination/            # Navigation
│   │   │   └── AppCoordinator.swift # Navigation state
│   │   └── Intents/                 # Siri Shortcuts
│   │       └── AppIntents.swift     # App Intent definitions
│   │
│   ├── FightCityiOS/                 # iOS-Specific Layer
│   │   ├── Camera/
│   │   │   ├── CameraManager.swift  # AVFoundation camera control
│   │   │   ├── CameraPreviewView.swift # Camera preview UI
│   │   │   └── FrameQualityAnalyzer.swift # Image quality analysis
│   │   ├── Scanning/
│   │   │   └── DocumentScanCoordinator.swift # VisionKit scanner
│   │   ├── Vision/
│   │   │   └── SceneAnalyzer.swift  # Scene analysis for evidence
│   │   ├── Location/
│   │   │   └── LocationVerifier.swift # MapKit Look Around
│   │   ├── Voice/
│   │   │   └── VoiceAppealRecorder.swift # Speech recognition
│   │   ├── Telemetry/
│   │   │   ├── TelemetryService.swift # Telemetry collection
│   │   │   └── TelemetryUploader.swift # Background uploads
│   │   └── Models/
│   │       └── CaptureResult.swift  # Capture result model
│   │
│   └── FightCityFoundation/          # Shared Business Logic
│       ├── AI/
│       │   ├── CitationClassifier.swift # Core ML classifier
│       │   └── AppealWriter.swift   # NaturalLanguage writer
│       ├── Networking/
│       │   ├── APIClient.swift      # HTTP client
│       │   ├── APIEndpoints.swift   # Endpoint definitions
│       │   ├── AuthManager.swift    # Authentication
│       │   └── OfflineManager.swift # Offline queue
│       ├── Offline/
│       │   └── OfflineQueueManager.swift # Persistent queue
│       ├── Models/
│       │   ├── Citation.swift      # Citation data model
│       │   ├── CitationTypes.swift # Shared types
│       │   ├── CityConfig.swift    # City configuration
│       │   ├── TelemetryRecord.swift # Telemetry model
│       │   ├── TelemetryStorage.swift # Telemetry persistence
│       │   └── ValidationResult.swift # Validation response
│       ├── Configuration/
│       │   └── FeatureFlags.swift  # Feature flag system
│       ├── Logging/
│       │   └── Logger.swift        # Structured logging
│       └── Protocols/
│           └── ServiceProtocols.swift # Service interfaces
│
├── Resources/                        # App Resources
│   ├── Assets.xcassets/            # Images, colors, icons
│   ├── Info.plist                  # App metadata
│   └── Localizable.strings         # Localized strings
│
├── Tests/                           # Test Suite
│   ├── UnitTests/
│   │   ├── FoundationTests/       # Foundation layer tests
│   │   │   ├── AppleIntelligence/ # AI feature tests
│   │   │   └── Mocks/             # Mock implementations
│   │   └── iOSTests/              # iOS layer tests
│   │       ├── AppleIntelligence/ # iOS AI tests
│   │       └── Mocks/             # Mock services
│   └── UITests/                    # UI automation tests
│       └── FightCityUITests.swift
│
├── Scripts/                         # Development Scripts
│   ├── generate-and-open.sh       # Generate Xcode project
│   ├── build.sh                   # Build script
│   ├── test.sh                    # Run tests
│   └── lint.sh                    # Code linting
│
├── Support/                         # Supporting Files
│   ├── FightCityFoundation-Info.plist
│   ├── FightCityiOS-Info.plist
│   └── PrivacyInfo.xcprivacy      # Privacy manifest
│
├── project.yml                     # XcodeGen configuration
├── .swiftlint.yml                  # SwiftLint rules
├── CODE_AUDIT_REPORT.md            # Code audit findings
├── APP_SPECIFICATION.md            # Complete app spec
├── APPLE_INTELLIGENCE_PLAN.md      # AI integration plan
└── README.md                       # This file
```

---

## 🤖 Apple Intelligence Integration

### Implemented Features ✅

#### 1. VisionKit Document Scanner
- **Status**: ✅ Fully Implemented
- **Location**: `Sources/FightCityiOS/Scanning/DocumentScanCoordinator.swift`
- **Features**:
  - Automatic document detection
  - Multi-page scanning
  - Perspective correction
  - Glare reduction
  - Auto-cropping
- **iOS Requirement**: iOS 16.0+
- **Fallback**: Traditional camera capture

#### 2. Core ML Citation Classifier
- **Status**: ✅ Fully Implemented
- **Location**: `Sources/FightCityFoundation/AI/CitationClassifier.swift`
- **Features**:
  - On-device citation type classification
  - City identification from text patterns
  - Confidence scoring
  - NaturalLanguage embeddings
  - Regex fallback when ML confidence is low
- **iOS Requirement**: iOS 16.0+
- **Model**: Uses NaturalLanguage framework (no custom Core ML model yet)

#### 3. AI Appeal Writer
- **Status**: ✅ Fully Implemented
- **Location**: `Sources/FightCityFoundation/AI/AppealWriter.swift`
- **Features**:
  - NaturalLanguage-based text generation
  - Tone analysis (professional, respectful, assertive)
  - Sentiment scoring
  - Clarity improvements
  - Grammar suggestions
  - Sentence ranking by impact
- **iOS Requirement**: iOS 16.0+

### Planned Features 🚧

#### 4. Speech Recognition
- **Status**: 🚧 Partially Implemented
- **Location**: `Sources/FightCityiOS/Voice/VoiceAppealRecorder.swift`
- **Features**:
  - Voice dictation for appeal writing
  - Real-time transcription
  - Partial results support
- **iOS Requirement**: iOS 16.0+
- **Feature Flag**: `FeatureFlags.speechRecognition` (currently `false`)

#### 5. MapKit Look Around
- **Status**: 🚧 Partially Implemented
- **Location**: `Sources/FightCityiOS/Location/LocationVerifier.swift`
- **Features**:
  - Street-level evidence collection
  - Location verification
  - Nearby POI discovery
- **iOS Requirement**: iOS 17.0+
- **Feature Flag**: `FeatureFlags.lookAroundEvidence` (currently `false`)

#### 6. Vision Scene Analysis
- **Status**: 🚧 Partially Implemented
- **Location**: `Sources/FightCityiOS/Vision/SceneAnalyzer.swift`
- **Features**:
  - Parking sign detection
  - Meter identification
  - Evidence quality assessment
- **Feature Flag**: `FeatureFlags.visionSignDetection` (currently `false`)

#### 7. App Intents (Siri Shortcuts)
- **Status**: 🚧 Partially Implemented
- **Location**: `Sources/FightCity/Intents/AppIntents.swift`
- **Features**:
  - "Scan ticket" shortcut
  - "Contest last ticket" shortcut
- **iOS Requirement**: iOS 16.0+
- **Feature Flag**: `FeatureFlags.appIntents` (currently `false`)

### Feature Flags

All Apple Intelligence features are controlled via `FeatureFlags`:

```swift
// Currently Enabled
FeatureFlags.visionKitDocumentScanner = true
FeatureFlags.liveTextAnalysis = true
FeatureFlags.mlClassification = true

// Coming Soon
FeatureFlags.naturalLanguageProcessing = false
FeatureFlags.speechRecognition = false
FeatureFlags.lookAroundEvidence = false
FeatureFlags.visionSignDetection = false
FeatureFlags.appIntents = false
```

**Location**: `Sources/FightCityFoundation/Configuration/FeatureFlags.swift`

---

## 🔌 API Integration

### Backend API

The app integrates with a FastAPI backend (not included in this repo). API endpoints are defined in `APIEndpoints.swift`.

### Endpoints

#### Citation Validation
```
POST /api/v1/citations/validate
Body: {
  "citation_number": "SFMTA12345678",
  "city_id": "us-ca-san_francisco" (optional)
}
Response: {
  "is_valid": true,
  "citation": { ... },
  "confidence": 0.95
}
```

#### Appeal Submission
```
POST /api/v1/appeals
Body: {
  "citation_id": "uuid",
  "reason": "I was not parked there",
  "evidence": [...]
}
```

#### Status Lookup
```
POST /api/v1/status/lookup
Body: {
  "email": "user@example.com",
  "citation_number": "SFMTA12345678"
}
```

#### Telemetry Upload
```
POST /mobile/ocr/telemetry
Body: {
  "records": [...]
}
```

### API Client

- **Location**: `Sources/FightCityFoundation/Networking/APIClient.swift`
- **Features**:
  - Async/await based
  - Automatic retry logic
  - Error handling
  - Request/response logging
  - Offline queue integration

### Authentication

- **Location**: `Sources/FightCityFoundation/Networking/AuthManager.swift`
- **Status**: Basic implementation (JWT tokens planned)
- **Current**: No authentication required (public API)

---

## 🚀 Setup & Installation

### Prerequisites

- **macOS**: 13.0+ (Ventura or later)
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **iOS Simulator**: iOS 17.0+ (or physical device)
- **XcodeGen**: For project generation

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ghostmonday/FIGHTCITYos.git
   cd FIGHTCITYos
   ```

2. **Install dependencies**
   ```bash
   # Install XcodeGen (if not installed)
   brew install xcodegen
   
   # Or using Mint (if Mintfile exists)
   mint bootstrap
   ```

3. **Generate Xcode project**
   ```bash
   ./Scripts/generate-and-open.sh
   ```
   
   Or manually:
   ```bash
   xcodegen generate
   open FightCityTickets.xcodeproj
   ```

4. **Build and run**
   - Select the `FightCity` scheme
   - Choose a simulator (iPhone 15 Pro recommended)
   - Press `Cmd+R` to build and run

### Manual Setup

If scripts don't work:

```bash
# Generate project
xcodegen generate

# Open in Xcode
open FightCityTickets.xcodeproj

# In Xcode:
# 1. Select FightCity scheme
# 2. Select iPhone 15 Pro simulator
# 3. Press Cmd+B to build
# 4. Press Cmd+R to run
```

### Configuration

#### API Endpoints

Edit `Sources/FightCity/Configuration/AppConfig.swift` to configure:
- Base API URL (default: development URLs)
- City configurations
- Feature toggles

#### Feature Flags

Edit `Sources/FightCityFoundation/Configuration/FeatureFlags.swift` to enable/disable features.

---

## 💻 Development Workflow

### Project Generation

The project uses **XcodeGen** to generate the Xcode project from `project.yml`. This ensures:
- Consistent project structure
- Version-controlled build settings
- Easy dependency management

**Generate project:**
```bash
xcodegen generate
```

**Generate and open:**
```bash
./Scripts/generate-and-open.sh
```

### Building

**Debug build:**
```bash
xcodebuild -project FightCityTickets.xcodeproj \
  -scheme FightCity \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

**Release build:**
```bash
xcodebuild -project FightCityTickets.xcodeproj \
  -scheme FightCity \
  -configuration Release \
  -sdk iphonesimulator \
  build
```

### Code Quality

**Lint code:**
```bash
./Scripts/lint.sh
```

**SwiftLint configuration**: `.swiftlint.yml`

### Testing

**Run all tests:**
```bash
./Scripts/test.sh
```

**Run specific test suite:**
```bash
xcodebuild test \
  -project FightCityTickets.xcodeproj \
  -scheme FightCity \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:FightCityTests/FoundationTests
```

### Debugging

- **Logging**: Uses `os.log` for structured logging
- **Logger**: Custom `Logger` class in `FightCityFoundation/Logging/Logger.swift`
- **Debug builds**: Include debug logging (controlled by `FeatureFlags.debugLogging`)

---

## 🧪 Testing

### Test Structure

```
Tests/
├── UnitTests/
│   ├── FoundationTests/          # Foundation layer tests
│   │   ├── AppleIntelligence/    # AI feature tests
│   │   │   ├── AppealWriterTests.swift
│   │   │   └── CitationClassifierTests.swift
│   │   └── Mocks/                # Mock implementations
│   └── iOSTests/                 # iOS layer tests
│       ├── AppleIntelligence/    # iOS AI tests
│       └── Mocks/                # Mock services
└── UITests/                      # UI automation
    └── FightCityUITests.swift
```

### Test Coverage

- **Citation Classifier**: ✅ Comprehensive tests
- **Appeal Writer**: ✅ Comprehensive tests
- **Document Scanner**: ⚠️ Needs tests
- **Camera Manager**: ⚠️ Needs tests
- **API Client**: ⚠️ Needs tests

### Running Tests

```bash
# All tests
xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCity

# Specific target
xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCity \
  -only-testing:FightCityTests/FoundationTests/AppleIntelligence/CitationClassifierTests
```

---

## 📊 Current Status

### ✅ Completed

- [x] Three-module architecture (FightCity, FightCityiOS, FightCityFoundation)
- [x] VisionKit Document Scanner integration
- [x] Core ML Citation Classifier (using NaturalLanguage)
- [x] AI Appeal Writer (NaturalLanguage)
- [x] Camera capture with AVFoundation
- [x] Offline queue system
- [x] Telemetry collection and upload
- [x] Multi-city citation support
- [x] Design system (Theme, Typography, Components)
- [x] Feature flag system
- [x] Comprehensive logging

### 🚧 In Progress

- [ ] Fix remaining build errors (CameraManager visibility, async/await)
- [ ] Complete Document Scanner integration
- [ ] Add comprehensive test coverage
- [ ] Implement certificate pinning
- [ ] Add Keychain storage for sensitive data

### ❌ Removed (Recent Changes)

- [x] **OCR Module Removed** (2026-01-30)
  - `OCREngine.swift` - Deleted
  - `LiveTextHelper.swift` - Deleted
  - `ConfidenceScorer.swift` - Deleted
  - `OCRPreprocessor.swift` - Deleted
  - `OCRParsingEngine.swift` - Deleted
  - **Impact**: App now relies on manual entry and Document Scanner only

### 🔴 Known Issues

1. **Build Errors**: Some type visibility and async/await issues remain
2. **Missing OCR**: Core OCR functionality removed; manual entry only
3. **Incomplete Tests**: Many components lack test coverage
4. **API Integration**: Backend API not yet deployed

---

## 📝 Recent Changes

### 2026-01-30: OCR Module Removal

**Major Refactoring**: Removed entire OCR module to simplify codebase.

**Deleted Files**:
- `Sources/FightCityiOS/OCR/OCREngine.swift`
- `Sources/FightCityiOS/OCR/LiveTextHelper.swift`
- `Sources/FightCityiOS/OCR/ConfidenceScorer.swift`
- `Sources/FightCityFoundation/Networking/OCRParsingEngine.swift`
- `Tests/UnitTests/iOSTests/OCRPerformanceTests.swift`
- `Tests/UnitTests/FoundationTests/OCRParsingEngineTests.swift`

**Updated Files**:
- `CaptureViewModel.swift`: Removed OCR processing, simplified to manual entry
- `ServiceProtocols.swift`: Removed OCR protocols
- `Theme.swift`, `Components.swift`: Removed OCR dependencies

**Impact**:
- Users must manually enter citation numbers
- Document Scanner still available for image capture
- Core ML classifier still works for classification after manual entry

**Commit**: `1704ad4` - "Remove OCR module and fix build errors"

---

## 🗺️ Roadmap

### Phase 1: Core Functionality (Current)
- [x] Basic app structure
- [x] Camera capture
- [x] Citation validation
- [x] Multi-city support
- [ ] Fix build errors
- [ ] Deploy backend API

### Phase 2: Apple Intelligence (In Progress)
- [x] VisionKit Document Scanner
- [x] Core ML Citation Classifier
- [x] AI Appeal Writer
- [ ] Speech Recognition
- [ ] MapKit Look Around
- [ ] Vision Scene Analysis

### Phase 3: Platform Features
- [ ] App Intents (Siri Shortcuts)
- [ ] WidgetKit widgets
- [ ] Live Activities
- [ ] Smart Notifications

### Phase 4: Production Readiness
- [ ] Comprehensive testing
- [ ] Performance optimization
- [ ] Security hardening
- [ ] App Store submission

See `ROADMAP.md` for detailed roadmap.

---

## 🤝 Contributing

### Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `./Scripts/test.sh`
5. Run linter: `./Scripts/lint.sh`
6. Commit: `git commit -m "Add amazing feature"`
7. Push: `git push origin feature/amazing-feature`
8. Open a Pull Request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint rules (`.swiftlint.yml`)
- Write tests for new features
- Document public APIs
- Use meaningful variable names

### Commit Messages

Follow conventional commits:
```
feat: Add new feature
fix: Fix bug
docs: Update documentation
refactor: Code refactoring
test: Add tests
chore: Maintenance tasks
```

See `CONTRIBUTING.md` for detailed guidelines.

---

## 📚 Documentation

### Available Documentation

- **APP_SPECIFICATION.md**: Complete application specification
- **ARCHITECTURE_BLUEPRINT.md**: Architecture analysis
- **APPLE_INTELLIGENCE_PLAN.md**: Apple Intelligence integration plan
- **CODE_AUDIT_REPORT.md**: Code audit findings
- **ROADMAP.md**: Development roadmap
- **CHANGELOG.md**: Version history
- **DEVELOPER.md**: Developer guide
- **README_IOS_BUILD.md**: iOS build instructions

### Code Documentation

- Inline comments for complex logic
- Doc comments for public APIs
- Architecture comments in key files

---

## 🔒 Security & Privacy

### Privacy

- **On-Device Processing**: All AI/ML processing happens on-device
- **No Third-Party SDKs**: No analytics or tracking SDKs
- **Opt-In Telemetry**: User-controlled telemetry collection
- **Privacy Manifest**: `Support/PrivacyInfo.xcprivacy` for iOS 17+

### Security

- **HTTPS Only**: All API communication over HTTPS
- **Certificate Pinning**: Planned (not yet implemented)
- **Keychain Storage**: Planned for sensitive data
- **Input Validation**: Client and server-side validation

### Data Storage

- **Local Storage**: UserDefaults and FileManager
- **Offline Queue**: Encrypted queue (planned)
- **Citation History**: Stored locally, not synced to cloud

---

## 🌍 Supported Cities

### Currently Supported

1. **San Francisco (SFMTA)**
   - City ID: `us-ca-san_francisco`
   - Pattern: `SFMTA[0-9]{8}`
   - Agency: San Francisco Municipal Transportation Agency

2. **Los Angeles (LADOT)**
   - City ID: `us-ca-los_angeles`
   - Pattern: `LA[0-9]{8}`
   - Agency: Los Angeles Department of Transportation

3. **New York City (DOF)**
   - City ID: `us-ny-new_york`
   - Pattern: `NYC-[0-9]{4}-[0-9]{6}`
   - Agency: Department of Finance

4. **Denver**
   - City ID: `us-co-denver`
   - Pattern: `DEN[0-9]{8}`
   - Agency: Denver Parking Services

### Adding New Cities

Edit `Sources/FightCity/Configuration/AppConfig.swift`:

```swift
CityConfig(
    id: "us-tx-austin",
    name: "Austin",
    citationPattern: "AUS[0-9]{8}",
    // ... other config
)
```

---

## 🐛 Troubleshooting

### Build Issues

**Issue**: "Cannot find type 'CameraManager'"
- **Fix**: Ensure `FightCityiOS` module is imported
- **Location**: `Sources/FightCity/Features/Capture/CaptureViewModel.swift`

**Issue**: "Traditional headermap style warning"
- **Fix**: Already fixed in `project.pbxproj` with `ALWAYS_SEARCH_USER_PATHS = NO`

**Issue**: XcodeGen not found
- **Fix**: `brew install xcodegen` or `mint install xcodegen`

### Runtime Issues

**Issue**: Document Scanner not available
- **Check**: iOS 16.0+ required
- **Check**: `VNDocumentCameraViewController.isSupported`
- **Fallback**: Traditional camera capture

**Issue**: ML Classification not working
- **Check**: iOS 16.0+ required
- **Check**: `FeatureFlags.mlClassification` is `true`
- **Check**: NaturalLanguage framework available

---

## 📈 Performance

### Targets

- **Cold Start**: < 5 seconds
- **Memory Usage**: < 100 MB
- **Battery Impact**: < 5% per hour
- **Network Requests**: Batched where possible

### Optimizations

- **Actor Isolation**: CameraManager uses actors for thread safety
- **Async/Await**: Non-blocking operations
- **Image Compression**: Before processing (planned)
- **Lazy Loading**: Views load on demand

---

## 🎨 Design System

### Colors

- **Primary**: `#0066CC` (Blue)
- **Secondary**: `#34C759` (Green)
- **Error**: `#FF3B30` (Red)
- **Warning**: `#FF9500` (Orange)

**Location**: `Sources/FightCity/DesignSystem/Colors.swift`

### Typography

- **Display**: 57pt, 45pt, 36pt (Bold)
- **Headline**: 32pt, 28pt, 24pt (Semibold)
- **Title**: 22pt, 16pt, 14pt (Semibold/Medium)
- **Body**: 16pt, 14pt, 12pt (Regular)
- **Label**: 14pt, 12pt, 11pt (Medium)

**Location**: `Sources/FightCity/DesignSystem/Typography.swift`

### Components

- **PrimaryButton**: Main action button
- **SecondaryButton**: Secondary action
- **CitationCard**: Citation display card
- **ConfidenceIndicator**: Confidence score display

**Location**: `Sources/FightCity/DesignSystem/Components.swift`

---

## 🔄 Offline Support

### How It Works

1. **Queue Operations**: When offline, operations are queued locally
2. **Persistent Storage**: Queue survives app restarts
3. **Automatic Sync**: When connection restored, queue processes automatically
4. **Exponential Backoff**: Smart retry logic prevents battery drain

### Supported Operations

- Citation validation requests
- Appeal submissions
- Telemetry uploads
- Status lookups

**Location**: `Sources/FightCityFoundation/Offline/OfflineQueueManager.swift`

---

## 📱 App Features Deep Dive

### 1. Citation Capture

**Flow**:
1. User opens app → Onboarding (first time)
2. Tap "Capture Citation" → Camera view
3. Choose: Document Scanner or Traditional Camera
4. Capture image → Process (currently manual entry)
5. Enter citation number manually
6. Validate → Confirmation screen

**Components**:
- `CaptureView.swift`: UI
- `CaptureViewModel.swift`: Logic
- `CameraManager.swift`: Camera control
- `DocumentScanCoordinator.swift`: Document Scanner

### 2. Citation Validation

**Flow**:
1. Citation number entered
2. Core ML classifier identifies city (if enabled)
3. Regex pattern matching
4. API validation request
5. Display results with confidence

**Components**:
- `CitationClassifier.swift`: ML classification
- `OCRParsingEngine.swift`: Pattern matching (still exists for parsing)
- `APIClient.swift`: API communication
- `ValidationResult.swift`: Result model

### 3. Appeal Writing

**Flow**:
1. User selects citation
2. Tap "Write Appeal"
3. AI Appeal Writer generates draft
4. User edits and refines
5. Submit appeal

**Components**:
- `AppealWriter.swift`: AI generation
- NaturalLanguage framework: Text analysis
- Appeal submission via API

### 4. Citation History

**Flow**:
1. View all citations
2. Filter by status, city, date
3. Tap citation → Details
4. View appeal status
5. Add evidence

**Components**:
- `HistoryView.swift`: UI
- Local storage: Citation persistence

---

## 🧩 Key Components Explained

### CameraManager

**Purpose**: Manages camera capture with full control

**Features**:
- AVFoundation integration
- Focus and exposure control
- Torch/flashlight
- Camera switching
- Video stabilization
- Document Scanner integration

**Thread Safety**: Uses Swift `actor` for thread-safe operations

**Location**: `Sources/FightCityiOS/Camera/CameraManager.swift`

### CitationClassifier

**Purpose**: On-device ML classification of citations

**How It Works**:
1. Takes citation text as input
2. Uses NaturalLanguage embeddings
3. Classifies citation type (parking, moving violation, etc.)
4. Identifies city from patterns
5. Returns confidence scores
6. Falls back to regex if ML confidence low

**Location**: `Sources/FightCityFoundation/AI/CitationClassifier.swift`

### AppealWriter

**Purpose**: AI-powered appeal letter generation

**How It Works**:
1. Takes user input (reason, details)
2. Uses NaturalLanguage for analysis
3. Generates professional appeal text
4. Analyzes tone and sentiment
5. Provides clarity suggestions
6. Ranks sentences by impact

**Location**: `Sources/FightCityFoundation/AI/AppealWriter.swift`

### OfflineQueueManager

**Purpose**: Persistent queue for offline operations

**How It Works**:
1. Operations added to queue
2. Stored to disk (Codable)
3. Processed when online
4. Exponential backoff retry
5. Background task support

**Location**: `Sources/FightCityFoundation/Offline/OfflineQueueManager.swift`

---

## 🔍 Code Examples

### Using CameraManager

```swift
let cameraManager = CameraManager()

// Request authorization
let authorized = await cameraManager.requestAuthorization()

if authorized {
    // Setup session
    try await cameraManager.setupSession()
    
    // Start camera
    await cameraManager.startSession()
    
    // Capture photo
    if let imageData = try await cameraManager.capturePhoto() {
        // Process image
    }
}
```

### Using CitationClassifier

```swift
let classifier = CitationClassifier.shared
let result = classifier.classify("SFMTA12345678")

print("City: \(result.cityName ?? "Unknown")")
print("Type: \(result.citationType)")
print("Confidence: \(result.confidence)")
```

### Using AppealWriter

```swift
let writer = AppealWriter()
let result = try await writer.generateAppeal(
    reason: "I was not parked there",
    details: "My car was in the shop",
    tone: .professional
)

print("Appeal: \(result.appealText)")
print("Tone: \(result.tone)")
print("Clarity: \(result.clarityScore)")
```

### Using Offline Queue

```swift
let queue = OfflineQueueManager.shared

// Add operation (works offline)
await queue.enqueue(.validateCitation(request))

// Queue processes automatically when online
// Or manually trigger:
await queue.processQueue()
```

---

## 🌐 API Integration Details

### Request/Response Flow

```
App → APIClient → URLSession → Backend API
                ↓
         OfflineQueue (if offline)
                ↓
         Retry Logic (exponential backoff)
                ↓
         Response Parsing
                ↓
         Models (Citation, ValidationResult)
```

### Error Handling

- **Network Errors**: Retry with exponential backoff
- **Validation Errors**: Display user-friendly messages
- **Server Errors**: Queue for retry
- **Offline**: Queue operations automatically

### Authentication

Currently: No authentication (public API)
Planned: JWT token-based authentication

---

## 🎯 Feature Flags System

### Purpose

Control gradual rollout of Apple Intelligence features and enable/disable features without code changes.

### Usage

```swift
if FeatureFlags.isVisionKitDocumentScannerEnabled {
    // Use Document Scanner
} else {
    // Use traditional camera
}
```

### Configuration

Edit `Sources/FightCityFoundation/Configuration/FeatureFlags.swift`:

```swift
public static let visionKitDocumentScanner = true
public static let mlClassification = true
public static let naturalLanguageProcessing = false
```

### Remote Configuration (Planned)

Feature flags can be loaded from UserDefaults or remote config:

```swift
let config = FeatureFlags.Configuration.loadFromUserDefaults()
```

---

## 📊 Data Models

### Citation

```swift
public struct Citation: Identifiable, Codable, Equatable {
    public let id: UUID
    public let citationNumber: String
    public let cityId: String
    public let violationDate: Date
    public let amount: Double
    public let deadlineStatus: DeadlineStatus
    // ... more fields
}
```

### CaptureResult

```swift
public struct CaptureResult: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public let originalImageData: Data?
    public let rawText: String
    public let extractedCitationNumber: String?
    public let confidence: Double
    // ... more fields
}
```

### ValidationResult

```swift
public struct ValidationResult {
    public let classification: ClassificationResult
    public let isValid: Bool
    public let errorMessage: String?
}
```

---

## 🛡️ Error Handling

### Error Types

- **CameraError**: Camera-related errors
- **OCRError**: OCR processing errors (deprecated)
- **APIError**: Network/API errors
- **DocumentScanError**: Document Scanner errors

### Error Handling Strategy

1. **Try-Catch**: Wrap async operations
2. **Result Types**: Use Result<T, Error> where appropriate
3. **User Feedback**: Display friendly error messages
4. **Logging**: Log errors for debugging
5. **Recovery**: Provide recovery options

---

## 🔐 Security Considerations

### Current Implementation

- ✅ HTTPS for all API calls
- ✅ Input validation
- ✅ Error message sanitization
- ⚠️ Certificate pinning (planned)
- ⚠️ Keychain storage (planned)
- ⚠️ Data encryption at rest (planned)

### Best Practices

- Never log sensitive data
- Validate all user input
- Use secure storage for tokens
- Implement rate limiting
- Regular security audits

---

## 📱 Platform Requirements

### Minimum Requirements

- **iOS**: 17.0+ (with fallbacks for iOS 16+)
- **Device**: iPhone or iPad
- **Camera**: Required for capture features
- **Storage**: ~50 MB for app + data

### Recommended

- **iOS**: 17.0+ for full Apple Intelligence features
- **Device**: iPhone 12 or later (for best ML performance)
- **Storage**: 100+ MB for citation history

### Feature Availability

| Feature | iOS Requirement | Device Requirement |
|---------|----------------|-------------------|
| Document Scanner | 16.0+ | Any iOS device |
| Core ML Classification | 16.0+ | Any iOS device |
| NaturalLanguage | 16.0+ | Any iOS device |
| MapKit Look Around | 17.0+ | Any iOS device |
| Speech Recognition | 16.0+ | Any iOS device |

---

## 🧪 Testing Strategy

### Unit Tests

- **Foundation Layer**: Business logic tests
- **AI Features**: CitationClassifier, AppealWriter
- **Networking**: API client, offline queue
- **Models**: Data model validation

### Integration Tests

- **API Integration**: Real API calls (with mocks)
- **Offline Queue**: Queue processing
- **Camera Flow**: End-to-end capture flow

### UI Tests

- **Navigation**: Screen transitions
- **User Flows**: Complete user journeys
- **Accessibility**: VoiceOver support

### Test Coverage Goals

- **Business Logic**: 90%+
- **AI Features**: 85%+
- **Networking**: 80%+
- **Overall**: 80%+

---

## 🚢 Deployment

### App Store Submission

See `APP_STORE_SUBMISSION_CHECKLIST.md` for complete checklist.

**Key Requirements**:
- Apple Developer Account ($99/year)
- App Store Connect setup
- Privacy policy URL
- App icons and screenshots
- Privacy manifest (already included)

### Build Configuration

**Debug**:
- Optimizations: None (`-Onone`)
- Debug symbols: Yes
- Testability: Enabled

**Release**:
- Optimizations: Speed (`-O`)
- Debug symbols: Stripped
- Bitcode: Disabled

---

## 📞 Support & Contact

### Issues

Report issues on GitHub: https://github.com/Ghostmonday/FIGHTCITYos/issues

### Questions

- Check documentation in `/docs` folder
- Review `APP_SPECIFICATION.md` for detailed specs
- See `DEVELOPER.md` for developer guide

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Apple for VisionKit, Core ML, and NaturalLanguage frameworks
- FastAPI for backend API framework
- XcodeGen for project generation
- SwiftLint for code quality

---

## 📚 Additional Resources

### Documentation Files

- **APP_SPECIFICATION.md**: Complete app specification (900+ lines)
- **ARCHITECTURE_BLUEPRINT.md**: Architecture analysis
- **APPLE_INTELLIGENCE_PLAN.md**: AI integration roadmap
- **CODE_AUDIT_REPORT.md**: Code quality audit
- **ROADMAP.md**: Development roadmap
- **CHANGELOG.md**: Version history
- **DEVELOPER.md**: Developer guide
- **CONTRIBUTING.md**: Contribution guidelines

### Scripts

- `Scripts/generate-and-open.sh`: Generate and open Xcode project
- `Scripts/build.sh`: Build script
- `Scripts/test.sh`: Test runner
- `Scripts/lint.sh`: Code linting

---

## 🎓 Learning Resources

### Swift & iOS Development

- [Swift Documentation](https://swift.org/documentation/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### Apple Intelligence

- [VisionKit Documentation](https://developer.apple.com/documentation/visionkit)
- [Core ML Documentation](https://developer.apple.com/documentation/coreml)
- [NaturalLanguage Documentation](https://developer.apple.com/documentation/naturallanguage)

### Architecture

- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Actor Model](https://developer.apple.com/documentation/swift/actor)
- [MVVM Pattern](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)

---

## 🔮 Future Enhancements

### Planned Features

1. **Payment Integration**: Pay citations directly from app
2. **Push Notifications**: Deadline reminders
3. **Multi-Language**: Support for Spanish, Chinese, etc.
4. **Apple Watch App**: Quick citation lookup
5. **iPad Optimization**: Better tablet experience
6. **Widgets**: Home screen widgets for deadlines
7. **Live Activities**: Lock screen deadline tracking

### Technical Improvements

1. **Custom Core ML Model**: Train dedicated citation classifier
2. **Certificate Pinning**: Enhanced security
3. **CloudKit Sync**: Citation history sync across devices
4. **Share Extension**: Import citations from Photos
5. **App Clips**: Quick citation validation

---

## 📈 Metrics & Analytics

### Telemetry Collection

The app collects anonymous telemetry (opt-in):

- **OCR Performance**: Recognition accuracy, processing time
- **Feature Usage**: Which features are used most
- **Error Rates**: Crash and error tracking
- **User Flows**: Navigation patterns

**Location**: `Sources/FightCityiOS/Telemetry/TelemetryService.swift`

**Privacy**: All telemetry is anonymized and opt-in only.

---

## 🎨 UI/UX Highlights

### Design Principles

- **Clarity**: Clear, readable text and icons
- **Consistency**: Consistent design language throughout
- **Feedback**: Immediate feedback for user actions
- **Accessibility**: VoiceOver support, high contrast

### User Flows

1. **First Launch**: Onboarding → Capture → Manual Entry → Validation
2. **Returning User**: History → Select Citation → View Details → Appeal
3. **Offline**: Capture → Queue → Sync when online

---

## 🔧 Development Tools

### Required Tools

- **Xcode**: 15.0+
- **XcodeGen**: Project generation
- **SwiftLint**: Code quality (optional but recommended)

### Optional Tools

- **Mint**: Dependency management
- **fastlane**: CI/CD automation (planned)
- **Instruments**: Performance profiling

---

## 📝 Code Style Guide

### Swift Style

- Use Swift API Design Guidelines
- Prefer `let` over `var`
- Use guard statements for early returns
- Prefer structs over classes for value types
- Use async/await for asynchronous code

### Naming Conventions

- **Types**: PascalCase (`CameraManager`)
- **Variables**: camelCase (`cameraManager`)
- **Constants**: camelCase (`maxRetries`)
- **Enums**: PascalCase with lowercase cases (`DeadlineStatus.safe`)

### File Organization

- One type per file (when possible)
- Group related functionality
- Use extensions for protocol conformance
- Mark public APIs with `public`

---

## 🐛 Known Issues & Limitations

### Current Limitations

1. **No OCR**: OCR module removed; manual entry required
2. **Build Errors**: Some type visibility issues remain
3. **Incomplete Tests**: Many components lack coverage
4. **No Backend**: Backend API not yet deployed
5. **No Authentication**: Public API (no user accounts)

### Planned Fixes

- Restore OCR functionality or implement alternative
- Fix all build errors
- Add comprehensive test coverage
- Deploy backend API
- Implement user authentication

---

## 🎯 Success Metrics

### Key Performance Indicators

- **Citation Validation Accuracy**: Target 95%+
- **Appeal Success Rate**: Track user appeals
- **User Retention**: Daily/Monthly active users
- **Crash Rate**: Target < 0.1%
- **App Store Rating**: Target 4.5+ stars

---

## 🌟 Highlights & Achievements

- ✅ **Modular Architecture**: Clean three-module separation
- ✅ **Apple Intelligence**: Core ML and NaturalLanguage integration
- ✅ **Privacy First**: On-device processing, opt-in telemetry
- ✅ **Offline Support**: Persistent queue system
- ✅ **Multi-City**: Support for 4+ cities
- ✅ **Modern Swift**: Swift 5.9, async/await, actors

---

## 📞 Getting Help

### Documentation

- Check this README first
- Review `APP_SPECIFICATION.md` for detailed specs
- See `DEVELOPER.md` for development guide
- Check `CODE_AUDIT_REPORT.md` for known issues

### Community

- GitHub Issues: Report bugs and request features
- GitHub Discussions: Ask questions
- Pull Requests: Contribute improvements

---

## 🎉 Conclusion

FightCityTickets is a comprehensive iOS application leveraging Apple Intelligence to help citizens manage parking citations. With VisionKit Document Scanner, Core ML classification, and AI-powered appeal writing, it provides an intelligent, privacy-focused solution for citation management.

**Current Status**: In active development, with core features implemented and Apple Intelligence integration in progress.

**Next Steps**: Fix remaining build errors, restore OCR functionality, and prepare for App Store submission.

---

**Made with ❤️ using Swift and Apple Intelligence**

*Last Updated: 2026-01-30*
