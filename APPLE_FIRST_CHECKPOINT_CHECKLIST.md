# Apple First Checkpoint Checklist

## Overview
This checklist covers what's needed to pass Apple's **automated first checkpoint** (upload validation). This happens BEFORE human review and checks for:
- Code signing
- Basic metadata
- App launches without crashing
- No obvious placeholder content
- Required permissions properly declared

**Note**: Backend APIs, webhooks, and API keys are NOT required for first checkpoint - these can be stubbed/mocked.

---

## ✅ Already Complete

### Code Signing & Metadata
- ✅ Bundle ID: `com.fightcitytickets.app`
- ✅ Version: `1.0.0`
- ✅ Build: `1`
- ✅ Display Name: `FightCityTickets`
- ✅ Encryption: `ITSAppUsesNonExemptEncryption = false`

### Privacy & Permissions
- ✅ Camera usage description
- ✅ Photo library usage descriptions (read + add)
- ✅ Microphone usage description
- ✅ Speech recognition usage description
- ✅ Location usage description
- ✅ Privacy manifest (`PrivacyInfo.xcprivacy`) complete

### Info.plist
- ✅ All required keys present
- ✅ Version format correct (`1.0.0`)
- ✅ No legacy device requirements
- ✅ Deployment target: iOS 17.0

---

## 🔧 Required Fixes for First Checkpoint

### 1. Fix Force Unwraps (Potential Crashes)

**File**: `Sources/FightCity/Features/Root/ContentView.swift`

**Issue**: Force unwraps on URLs could crash if URLs are malformed (unlikely but Apple checks for this)

**Fix**:
```swift
// Lines 648 & 659 - Replace force unwraps:
Link(destination: URL(string: "https://fightcitytickets.com/privacy") ?? URL(string: "https://fightcitytickets.com")!) {
    // ...
}

// Better: Use guard or if-let
if let privacyURL = URL(string: "https://fightcitytickets.com/privacy") {
    Link(destination: privacyURL) {
        // ...
    }
}
```

**Priority**: HIGH (could cause rejection)

---

### 2. Ensure App Launches Without Backend

**Current State**: App has fallbacks but need to verify:
- ✅ CityAddressManager has hardcoded fallback addresses
- ✅ AppealWriter has static template fallbacks
- ✅ OfflineManager queues failed requests
- ⚠️ Need to verify API calls don't crash on network errors

**Action Required**:
- Test app launch with airplane mode ON
- Verify no fatal errors or crashes
- Ensure error messages are user-friendly

**Priority**: CRITICAL (app must launch)

---

### 3. Remove/Disable Placeholder Content

**Check for**:
- [ ] No "TODO" text visible to users
- [ ] No "Coming Soon" screens
- [ ] No placeholder images or text
- [ ] All buttons have proper actions (even if they show errors)

**Files to Check**:
- `CaptureView.swift` - Ensure manual entry works if OCR fails
- `ConfirmationView.swift` - Ensure appeal generation works offline
- `HistoryView.swift` - Ensure empty state is polished

**Priority**: HIGH (Apple rejects apps with placeholder content)

---

### 4. Graceful API Failure Handling

**Current Implementation**: ✅ Good
- `APIClient` throws errors (doesn't crash)
- `OfflineManager` queues operations
- Error messages are user-friendly

**Verify**:
- [ ] Citation validation fails gracefully (shows error, doesn't crash)
- [ ] Appeal submission fails gracefully (queues for retry)
- [ ] Telemetry upload fails silently (doesn't block app)
- [ ] Lob mail sending shows error message (doesn't crash)

**Priority**: HIGH

---

### 5. Disable Features That Require Backend (Optional)

**Option A**: Keep features but ensure graceful failures ✅ (Recommended)
- All API calls already have error handling
- Offline queue handles failures
- User sees error messages, app doesn't crash

**Option B**: Disable features until backend ready
- Add feature flags to hide backend-dependent features
- Show "Coming Soon" messages (NOT recommended - Apple rejects)

**Recommendation**: Keep Option A - graceful failures are better than disabled features

---

## 📋 Pre-Upload Checklist

### Build & Archive
- [ ] Clean build folder (`Product → Clean Build Folder`)
- [ ] Select "Any iOS Device" (not simulator)
- [ ] Product → Archive
- [ ] Archive succeeds with no errors
- [ ] Archive validates successfully (`Validate App`)

### App Store Connect
- [ ] App listing created
- [ ] Bundle ID matches: `com.fightcitytickets.app`
- [ ] Version matches: `1.0.0`
- [ ] Build number: `1` (or increment)

### Testing (Critical)
- [ ] App launches on physical device
- [ ] App launches on simulator
- [ ] No crashes on launch
- [ ] Camera permission requested properly
- [ ] All screens navigate correctly
- [ ] Error messages display (don't crash)
- [ ] Offline mode works (airplane mode test)

---

## 🚫 What's NOT Required for First Checkpoint

### Backend APIs
- ❌ Backend API doesn't need to be live
- ❌ Citation validation can fail gracefully
- ❌ Appeal submission can queue offline
- ❌ Telemetry upload can fail silently

### External Services
- ❌ Lob API doesn't need to be configured
- ❌ DeepSeek API doesn't need to be configured
- ❌ Webhooks don't need to be set up
- ❌ Address scraping doesn't need to work

### Full Functionality
- ❌ App doesn't need to validate real citations
- ❌ App doesn't need to send real mail
- ❌ App doesn't need real city data
- ❌ App just needs to launch and not crash

---

## ✅ Final Pre-Upload Steps

### 1. Fix Force Unwraps
```bash
# Fix ContentView.swift URLs
```

### 2. Test Launch
```bash
# Run on device/simulator
# Verify no crashes
# Test with airplane mode ON
```

### 3. Archive & Validate
```bash
# Xcode: Product → Archive
# Xcode: Window → Organizer → Validate App
# Fix any validation errors
```

### 4. Upload
```bash
# Xcode: Distribute App → App Store Connect
# Wait for processing
# Select build in App Store Connect
```

---

## 🎯 Success Criteria

The app passes first checkpoint if:
- ✅ Build uploads successfully
- ✅ No code signing errors
- ✅ No metadata errors
- ✅ App processes successfully in App Store Connect
- ✅ Build appears in "Builds" section

**You can submit for review even if backend isn't ready** - just ensure:
- App launches without crashing
- Error messages are user-friendly
- No placeholder content visible
- All features gracefully handle failures

---

## 📝 Notes

- **First checkpoint is automated** - no human review yet
- **Backend can be added later** - app just needs to launch
- **Error handling is key** - graceful failures are acceptable
- **Placeholder content is NOT acceptable** - must be polished

**Status**: Ready for first checkpoint after fixing force unwraps ✅
