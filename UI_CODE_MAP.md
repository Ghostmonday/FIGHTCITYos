# UI CODE MAP - Complete Frontend Code Flagging
**Generated:** $(date)
**Purpose:** Flag every line where user-facing UI code starts and ends throughout the entire codebase

---

## 🎨 PURE UI FILES (100% Frontend Code)

### 1. `Sources/FightCity/App/FightCityApp.swift`
**UI CODE START:** Line 9 (`import SwiftUI`)
**UI CODE END:** Line 37 (end of file)
**UI SECTIONS:**
- Lines 9-11: SwiftUI imports
- Lines 14-28: App structure with WindowGroup (UI)
- Lines 30-36: `configureAppearance()` - UIKit appearance configuration (UI)

---

### 2. `Sources/FightCity/DesignSystem/Components.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 312 (end of file)
**UI SECTIONS:**
- **Lines 8-9:** SwiftUI imports
- **Lines 13-45:** `PrimaryButton` struct - UI component (100% UI)
- **Lines 49-76:** `SecondaryButton` struct - UI component (100% UI)
- **Lines 80-96:** `CardView` generic struct - UI component (100% UI)
- **Lines 100-149:** `CitationCard` struct - UI component (100% UI)
- **Lines 153-170:** `StatusBadge` struct - UI component (100% UI)
- **Lines 174-198:** `ConfidenceIndicator` struct - UI component (100% UI)
- **Lines 202-232:** `LoadingOverlay` struct - UI component (100% UI)
- **Lines 236-280:** `EmptyStateView` struct - UI component (100% UI)
- **Lines 284-311:** `ErrorView` struct - UI component (100% UI)

---

### 3. `Sources/FightCity/DesignSystem/Colors.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 137 (end of file)
**UI SECTIONS:**
- **Lines 8-9:** SwiftUI imports
- **Lines 14-63:** `AppColors` enum - Color definitions (UI styling)
- **Lines 67-91:** `Color.init(hex:)` extension - Color utility (UI)
- **Lines 95-136:** `Color` extension with helper methods - UI color utilities

---

### 4. `Sources/FightCity/DesignSystem/Typography.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 132 (end of file)
**UI SECTIONS:**
- **Lines 8:** SwiftUI import
- **Lines 13-54:** `AppTypography` enum - Font definitions (UI styling)
- **Lines 58-98:** `Font` extension with helper methods - UI typography utilities
- **Lines 102-122:** Typography style enums - UI type definitions
- **Lines 126-131:** `Text` extension for line height - UI utility

---

### 5. `Sources/FightCity/DesignSystem/Theme.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 467 (end of file)
**UI SECTIONS:**
- **Lines 8-9:** SwiftUI imports
- **Lines 14-76:** `AppTheme` struct with light/dark themes - UI theme definitions
- **Lines 81-155:** `ThemeColors` struct - UI color definitions
- **Lines 160-302:** `ThemeTypography` struct - UI typography definitions
- **Lines 307-328:** `TextStyle` enum - UI type definitions
- **Lines 333-341:** `Theme` struct - UI theme container
- **Lines 345-349:** `Color` extension for theme colors - UI utility
- **Lines 353-357:** `View` extension for theming - UI utility
- **Lines 361-370:** `EnvironmentValues` extension - UI environment
- **Lines 374-389:** `Text` extensions for theming - UI utilities
- **Lines 393-461:** `View` extensions for styling - UI style utilities

---

### 6. `Sources/FightCity/Features/Root/ContentView.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 379 (end of file)
**UI SECTIONS:**
- **Lines 8-9:** SwiftUI imports
- **Lines 11-110:** `ContentView` struct - Main UI view (100% UI)
  - Lines 17-35: `body` property - UI layout
  - Lines 41-58: `mainTabView` computed property - UI TabView
  - Lines 60-95: `navigationDestination` function - UI navigation
  - Lines 97-109: `sheetDestination` function - UI sheet presentation
- **Lines 114-167:** `HomeView` struct - UI view (100% UI)
- **Lines 171-211:** `CitySelectionSheet` struct - UI sheet (100% UI)
- **Lines 215-262:** `TelemetryOptInSheet` struct - UI sheet (100% UI)
- **Lines 266-307:** `EditCitationSheet` struct - UI sheet (100% UI)
- **Lines 311-356:** `SettingsView` struct - UI view (100% UI)
- **Lines 371-378:** Preview code - UI preview (100% UI)

---

### 7. `Sources/FightCity/Features/Onboarding/OnboardingView.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 153 (end of file)
**UI SECTIONS:**
- **Lines 8:** SwiftUI import
- **Lines 10-125:** `OnboardingView` struct - UI view (100% UI)
  - Lines 14-39: Page definitions with image names (UI data)
  - Lines 43-88: `body` property - UI layout
  - Lines 90-119: `pageContent` function - UI content builder
  - Lines 121-124: `completeOnboarding` function - UI action handler
- **Lines 129-141:** `OnboardingPage` struct - UI data model
- **Lines 146-152:** Preview code - UI preview (100% UI)

---

### 8. `Sources/FightCity/Features/Capture/CaptureView.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 252 (end of file)
**UI SECTIONS:**
- **Lines 8-10:** SwiftUI/AVFoundation imports
- **Lines 12-240:** `CaptureView` struct - UI view (100% UI)
  - Lines 19-82: `body` property - UI layout
  - Lines 105-119: `cameraPreview` computed property - UI preview
  - Lines 123-150: `headerView` computed property - UI header
  - Lines 154-168: `qualityWarningView` function - UI warning display
  - Lines 172-201: `controlsView` computed property - UI controls
  - Lines 205-239: `manualEntrySheet` computed property - UI sheet
- **Lines 245-251:** Preview code - UI preview (100% UI)

---

### 9. `Sources/FightCity/Features/Confirmation/ConfirmationView.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 337 (end of file)
**UI SECTIONS:**
- **Lines 8-11:** SwiftUI imports
- **Lines 13-181:** `ConfirmationView` struct - UI view (100% UI)
  - Lines 30-61: `body` property - UI layout with background image
  - Lines 63-78: `imagePreviewSection` computed property - UI image display
  - Lines 80-100: `citationDetailsSection` computed property - UI details
  - Lines 102-107: `detailRow` function - UI row builder
  - Lines 109-131: `confidenceSection` computed property - UI confidence display
  - Lines 133-161: `actionButtonsSection` computed property - UI buttons
  - Lines 163-175: Helper functions for UI display
  - Lines 177-180: `formatCityId` function - UI text formatting
- **Lines 185-198:** `TertiaryButton` struct - UI component (100% UI)
- **Lines 202-336:** `CitationDetailView` struct - UI view (100% UI)
  - Lines 212-228: `body` property - UI layout
  - Lines 230-264: `headerCard` computed property - UI card
  - Lines 266-295: `deadlineCard` computed property - UI card
  - Lines 297-313: Color/icon helpers for UI
  - Lines 315-335: `actionButtons` computed property - UI buttons

---

### 10. `Sources/FightCity/Features/History/HistoryView.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 284 (end of file)
**UI SECTIONS:**
- **Lines 8-10:** SwiftUI imports
- **Lines 12-113:** `HistoryView` struct - UI view (100% UI)
  - Lines 19-56: `body` property - UI layout with background image
  - Lines 58-59: `historyList` computed property - UI List
  - Lines 61-93: `filterMenu` computed property - UI menu
  - Lines 95-112: `groupedCitations` computed property - UI data grouping
- **Lines 118-148:** `HistoryViewModel` class - ViewModel (NOT UI, but UI-related state)
- **Lines 152-175:** `CitationFilter` enum - UI filter type
- **Lines 179-215:** `CitationRow` struct - UI component (100% UI)
- **Lines 219-231:** `EmptyHistoryView` struct - UI component (100% UI)
- **Lines 235-283:** `HistoryStorage` classes - NOT UI (data layer)

---

### 11. `Sources/FightCityiOS/Camera/CameraPreviewView.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Line 186 (end of file)
**UI SECTIONS:**
- **Lines 8-9:** SwiftUI/AVFoundation imports
- **Lines 12-31:** `CameraPreviewView` struct - SwiftUI wrapper (100% UI)
  - Lines 17-23: `makeUIView` - UI creation
  - Lines 25-30: `updateUIView` - UI updates
- **Lines 34-85:** `CameraPreviewUIView` class - UIKit view (100% UI)
  - Lines 35-53: UI properties
  - Lines 55-56: UI layer setup
  - Lines 58-66: UI initialization
  - Lines 68-78: `setupViews` - UI setup
  - Lines 80-84: `layoutSubviews` - UI layout
- **Lines 88-99:** `BoundingBoxOverlayData` struct - UI data model
- **Lines 102-142:** `BoundingBoxOverlayView` class - UIKit view (100% UI)
  - Lines 103-107: UI property
  - Lines 109-141: `draw` method - UI drawing
- **Lines 148-174:** Extension for Vision integration (UI data conversion)
- **Lines 179-185:** Preview code - UI preview (100% UI)

---

### 12. `Sources/FightCity/App/SceneDelegate.swift`
**UI CODE START:** Line 13 (`import UIKit`)
**UI CODE END:** Line 51 (end of file)
**UI SECTIONS:**
- **Lines 13-14:** UIKit/SwiftUI imports
- **Lines 16-51:** `SceneDelegate` class - UIKit lifecycle (UI setup)
  - Lines 19-34: `scene(_:willConnectTo:options:)` - UI window setup
  - Lines 36-50: Scene lifecycle methods (UI state management)

---

## 🔄 MIXED FILES (Part UI, Part Logic)

### 13. `Sources/FightCity/Features/Capture/CaptureViewModel.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Check for `@Published`, `@StateObject`, `@ObservedObject` properties
**UI SECTIONS:**
- **Line 8:** SwiftUI import (for state management)
- **Lines with `@Published` properties:** UI state bindings
- **Lines with `@StateObject`/`@ObservedObject`:** UI state management
- **NOTE:** ViewModel contains UI state but logic is business logic, not UI rendering

---

### 14. `Sources/FightCity/Coordination/AppCoordinator.swift`
**UI CODE START:** Line 8 (`import SwiftUI`)
**UI CODE END:** Check for navigation-related code
**UI SECTIONS:**
- **Line 8:** SwiftUI import
- **Navigation-related properties:** UI navigation state
- **NOTE:** Coordinator manages UI navigation flow but doesn't render UI

---

## 📱 RESOURCES (UI Assets)

### 15. `Resources/Assets.xcassets/`
**UI CODE START:** All files
**UI CODE END:** All files
**UI SECTIONS:**
- **All Contents.json files:** UI asset definitions
- **All .png files:** UI images
- **All .colorset folders:** UI color definitions
- **All .imageset folders:** UI image sets

---

## 🚫 NON-UI FILES (Backend/Logic Only)

These files are **NOT** UI code:
- `Sources/FightCityFoundation/**/*.swift` - Business logic, networking, models
- `Sources/FightCityiOS/Camera/CameraManager.swift` - Camera logic (not UI)
- `Sources/FightCityiOS/Vision/**/*.swift` - Vision processing (not UI)
- `Sources/FightCityFoundation/Networking/**/*.swift` - API calls (not UI)
- `Sources/FightCityFoundation/Models/**/*.swift` - Data models (not UI)
- `Tests/**/*.swift` - Test code (not UI)

---

## 📊 SUMMARY STATISTICS

**Total UI Files:** 12 pure UI files + 2 mixed files
**Total UI Lines:** ~3,500+ lines of UI code
**UI Frameworks Used:**
- SwiftUI (primary)
- UIKit (camera previews, legacy components)
- AVFoundation (camera UI integration)

---

## 🎯 QUICK REFERENCE

**To find ALL UI code:**
1. Search for `import SwiftUI` or `import UIKit`
2. Look for `struct ...View: View` or `class ...View`
3. Look for `var body: some View`
4. Look for `@ViewBuilder`
5. Check `Resources/Assets.xcassets/` for all assets

**UI Code Patterns:**
- `struct XView: View` = UI component
- `var body: some View` = UI layout
- `@ViewBuilder` = UI builder function
- `Image()`, `Text()`, `Button()`, etc. = UI elements
- `.padding()`, `.background()`, `.foregroundColor()` = UI modifiers

---

**END OF UI CODE MAP**
