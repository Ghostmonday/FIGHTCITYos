# FightCityTickets Architecture Blueprint

## Executive Summary

This document analyzes the optimal architecture for the FightCityTickets iOS application, focusing on testability, performance, and maintainability.

---

## 1. Current Architecture Analysis

```
┌─────────────────────────────────────────────────────────────┐
│                    Current Swift Architecture               │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (SwiftUI)                                         │
│  ├── ContentView.swift                                      │
│  ├── CaptureView.swift + CaptureViewModel.swift            │
│  ├── ConfirmationView.swift + ConfirmationViewModel.swift   │
│  ├── HistoryView.swift                                      │
│  └── OnboardingView.swift                                   │
├─────────────────────────────────────────────────────────────┤
│  Core Layer (Swift)                                         │
│  ├── CameraManager.swift (AVFoundation)                    │
│  ├── OCREngine.swift (Vision framework)                    │
│  ├── ConfidenceScorer.swift                                 │
│  ├── FrameQualityAnalyzer.swift                             │
│  ├── OCRParsingEngine.swift                                 │
│  └── OCRPreprocessor.swift                                  │
├─────────────────────────────────────────────────────────────┤
│  Domain Layer (Swift)                                       │
│  ├── Citation.swift                                         │
│  ├── CaptureResult.swift                                    │
│  └── ValidationResult.swift                                 │
├─────────────────────────────────────────────────────────────┤
│  Network Layer (Swift)                                      │
│  ├── APIClient.swift                                        │
│  ├── AuthManager.swift                                      │
│  ├── APIEndpoints.swift                                     │
│  └── OfflineManager.swift                                   │
└─────────────────────────────────────────────────────────────┘
```

### Component Dependencies

```
UI → Core → Domain → Network
          ↓
    (iOS frameworks)
    AVFoundation, Vision
```

---

## 2. Architecture Options Comparison

### Option A: Pure C Port

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│                    iOS Layer (Objective-C)                  │
├─────────────────────────────────────────────────────────────┤
│  UIKit/SwiftUI Wrappers                                     │
│  ├── CameraViewController+swift                             │
│  ├── OCRViewController+swift                                │
│  └── Bridge to C core                                       │
├─────────────────────────────────────────────────────────────┤
│                    C Core (Portable)                        │
├─────────────────────────────────────────────────────────────┤
│  fct_citation.c        - Citation model                    │
│  fct_confidence.c      - Confidence scoring                │
│  fct_pattern.c         - Pattern matching                  │
│  fct_network.c         - HTTP client                       │
│  fct_json.c            - JSON parsing                      │
│  fct_string.c          - String utilities                  │
├─────────────────────────────────────────────────────────────┤
│                    Linux Test Layer                         │
├─────────────────────────────────────────────────────────────┤
│  Unit tests (assert-based)                                  │
│  Mock implementations                                       │
│  CI/CD pipeline                                             │
└─────────────────────────────────────────────────────────────┘
```

**Pros:**
- Maximum portability
- No external dependencies
- Fine-grained memory control
- Can target any platform with C compiler

**Cons:**
- Significant development effort
- No ARC (memory management burden)
- iOS still needs Objective-C wrappers
- Slower development velocity
- No Vision framework (must use Tesseract or similar)

**Effort Estimate:** 3-4 months

---

### Option B: Swift Package (Recommended)

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│              FightCityTickets (Main App - iOS)              │
├─────────────────────────────────────────────────────────────┤
│  App/                                                       │
│  ├── FightCityTicketsApp.swift                              │
│  ├── AppCoordinator.swift                                    │
│  └── SceneDelegate.swift                                     │
├─────────────────────────────────────────────────────────────┤
│  UI/ (SwiftUI Views)                                        │
│  └── Screens/                                               │
│      ├── ContentView/                                       │
│      ├── Capture/                                           │
│      ├── Confirmation/                                      │
│      └── History/                                           │
└─────────────────────────────────────────────────────────────┘
                              ↓
                    (Swift Package Dependency)
                              ↓
┌─────────────────────────────────────────────────────────────┐
│           FightCityTicketsCore (Swift Package)              │
├─────────────────────────────────────────────────────────────┤
│  Sources/Core/                                              │
│  ├── Camera/CameraManager.swift (Protocol)                 │
│  ├── OCR/OCREngine.swift (Protocol)                        │
│  ├── Confidence/ConfidenceScorer.swift                      │
│  ├── Pattern/PatternMatcher.swift                           │
│  └── Validation/CitationValidator.swift                     │
├─────────────────────────────────────────────────────────────┤
│  Sources/Domain/                                            │
│  ├── Citation.swift                                         │
│  ├── CaptureResult.swift                                    │
│  └── ValidationResult.swift                                 │
├─────────────────────────────────────────────────────────────┤
│  Sources/Network/                                           │
│  ├── APIClient.swift                                        │
│  ├── AuthManager.swift                                      │
│  └── OfflineManager.swift                                   │
├─────────────────────────────────────────────────────────────┤
│  Tests/CoreTests/                                           │
│  ├── ConfidenceTests.swift                                  │
│  ├── PatternTests.swift                                     │
│  └── ValidationTests.swift                                  │
└─────────────────────────────────────────────────────────────┘
           ↓                           ↓
    iOS CI (Xcode)            Linux CI (Swift on Linux)
```

**Pros:**
- Native iOS development (no bridging)
- ARC memory management
- Swift Package Manager integration
- Linux-compatible (swift-corelibs-foundation)
- Protocol-based testing (mock dependencies)
- Faster development
- Maintainable code size

**Cons:**
- Still requires iOS-specific implementations
- Swift on Linux has some limitations
- Vision framework only available on iOS

**Effort Estimate:** 2-3 weeks

---

### Option C: Rust + Swift Hybrid

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│                    iOS Layer (Swift)                        │
├─────────────────────────────────────────────────────────────┤
│  UI (SwiftUI)                                               │
│  └── Bridges to Rust via FFI                                │
├─────────────────────────────────────────────────────────────┤
│              Rust Core (Cross-platform)                     │
├─────────────────────────────────────────────────────────────┤
│  src/citation.rs        - Citation model                   │
│  src/confidence.rs      - Confidence scoring               │
│  src/pattern.rs         - Pattern matching                 │
│  src/network.rs         - HTTP client (reqwest)            │
│  src/json.rs            - JSON parsing (serde)             │
├─────────────────────────────────────────────────────────────┤
│                    Linux Test Layer                         │
├─────────────────────────────────────────────────────────────┤
│  cargo test (native)                                        │
│  cargo bench (performance)                                  │
│  CI/CD (GitHub Actions)                                     │
└─────────────────────────────────────────────────────────────┘
```

**Pros:**
- Memory safety without garbage collection
- Excellent performance
- Modern language features
- Good FFI with C/Swift
- Strong package ecosystem (crates.io)

**Cons:**
- Learning curve for team
- Additional build complexity
- Swift-Rust bridging overhead
- Must handle Rust memory model

**Effort Estimate:** 2-3 months

---

## 3. Scoring Matrix

| Criteria | Weight | Option A (C) | Option B (Swift) | Option C (Rust) |
|----------|--------|--------------|------------------|-----------------|
| Testability | 20% | 9/10 | 9/10 | 9/10 |
| Linux CI | 15% | 10/10 | 8/10 | 10/10 |
| iOS Performance | 15% | 10/10 | 8/10 | 10/10 |
| Development Speed | 15% | 3/10 | 10/10 | 6/10 |
| Maintainability | 10% | 5/10 | 10/10 | 8/10 |
| Team Familiarity | 10% | 7/10 | 10/10 | 3/10 |
| Ecosystem | 10% | 6/10 | 9/10 | 8/10 |
| Future Portability | 5% | 10/10 | 6/10 | 10/10 |
| **Weighted Total** | 100% | **6.8/10** | **8.7/10** | **7.5/10** |

---

## 4. Recommendation

### Recommended: Option B (Swift Package)

**Rationale:**
1. **Best development velocity** - Team already knows Swift
2. **Native iOS performance** - No bridging overhead for camera/OCR
3. **Sufficient testability** - Protocol mocking covers 90% of test cases
4. **Linux CI feasible** - swift-corelibs-foundation covers core logic
5. **Incremental migration** - Can start with minimal extraction

### Implementation Steps:

1. **Phase 1: Extract Domain Layer** (Week 1)
   - Move Citation.swift, CaptureResult.swift, ValidationResult.swift
   - Create Swift Package structure
   - Add basic unit tests

2. **Phase 2: Extract Core Logic** (Week 2)
   - Move ConfidenceScorer.swift
   - Create CameraManager protocol (iOS impl + mock)
   - Create OCREngine protocol (iOS impl + mock)

3. **Phase 3: Extract Network Layer** (Week 2-3)
   - Move APIClient.swift
   - Add offline queue tests
   - Implement retry logic tests

4. **Phase 4: CI/CD Setup** (Week 3)
   - Configure GitHub Actions for Linux CI
   - Add iOS CI (Xcode Cloud or Fastlane)
   - Code coverage reporting

---

## 5. Decision Criteria Checklist

Before proceeding, confirm:

- [ ] Team is comfortable with Swift Package Manager
- [ ] Linux CI is a hard requirement (not "nice to have")
- [ ] Current test coverage is < 60%
- [ ] Performance bottlenecks are identified (not premature optimization)
- [ ] Team has bandwidth for 2-3 week refactor

If most are unchecked, consider maintaining current architecture with improved internal testing.

---

## 6. Next Steps

1. **Discuss** this blueprint with the team
2. **Decide** on architecture approach
3. **Create** technical specification for chosen path
4. **Estimate** sprint tasks
5. **Begin** incremental migration or C port implementation

---

*Document Version: 1.0*
*Last Updated: 2024-01-28*
