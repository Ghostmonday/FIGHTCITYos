# Mac Day Checklist - Complete & Submit in One Day

## 🎯 Goal: Build, Polish, Test, and Submit to App Store in 8 Hours

This checklist ensures you can complete everything in a single Mac rental day.

---

## ⏰ Timeline (8 Hours)

- **Hour 1**: Mac Setup & Project Setup
- **Hour 2**: Build & Fix Issues
- **Hour 3**: Testing & Bug Fixes
- **Hour 4**: UI Polish & Assets
- **Hour 5**: App Store Connect Setup
- **Hour 6**: Archive & Upload
- **Hour 7**: Final Testing & Screenshots
- **Hour 8**: Submit for Review

---

## 📋 Pre-Mac Day Preparation (Do on Windows)

### ✅ Code Complete
- [ ] All Swift files written
- [ ] All features implemented
- [ ] Code reviewed and clean
- [ ] No TODO/FIXME comments
- [ ] SwiftLint passes (or will pass)

### ✅ Project Configuration
- [ ] `project.yml` complete
- [ ] Bundle ID: `com.fightcitytickets.app`
- [ ] Version: `1.0.0`
- [ ] Build: `1`
- [ ] Info.plist complete
- [ ] Privacy permissions configured

### ✅ Assets Ready
- [ ] App icon (1024x1024 PNG)
- [ ] Launch screen assets
- [ ] Screenshot mockups (for App Store)
- [ ] App Store description written
- [ ] Privacy policy URL ready

### ✅ Developer Account
- [ ] Apple Developer account active ($99/year)
- [ ] App Store Connect access
- [ ] Two-factor authentication device ready
- [ ] Team ID noted

### ✅ Mac Rental
- [ ] Mac rental service booked
- [ ] Access credentials received
- [ ] Remote access tested
- [ ] Backup Mac rental (optional)

---

## 🚀 Hour 1: Mac Setup & Project Setup

### Step 1: Connect to Mac (15 min)
```bash
# Test remote access
# Verify internet connection
ping -c 3 google.com

# Check macOS version (need 13.0+)
sw_vers
```

### Step 2: Install Xcode (30 min)
```bash
# Check if Xcode installed
xcode-select -p

# If not installed, download from App Store
# Or use command line:
# xcode-select --install

# Accept license
sudo xcodebuild -license accept

# Install Command Line Tools
xcode-select --install
```

### Step 3: Install Dependencies (10 min)
```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XcodeGen
brew install xcodegen

# Install SwiftLint
brew install swiftlint

# Verify installations
xcodegen --version
swiftlint version
```

### Step 4: Clone/Download Project (5 min)
```bash
# Option 1: Clone from Git
git clone https://github.com/YOUR_USERNAME/FightCityTickets.git
cd FightCityTickets

# Option 2: Transfer via USB/Cloud
# Download ZIP and extract

# Verify project structure
ls -la
```

### Step 5: Generate Xcode Project (5 min)
```bash
# Generate Xcode project
xcodegen generate

# Verify project created
ls -la *.xcodeproj

# Open project
open FightCityTickets.xcodeproj
```

**✅ Hour 1 Complete**: Xcode project open and ready

---

## 🔨 Hour 2: Build & Fix Issues

### Step 1: Initial Build (10 min)
```bash
# Clean build folder
xcodebuild clean -project FightCityTickets.xcodeproj -scheme FightCityTickets

# Build project
xcodebuild build -project FightCityTickets.xcodeproj -scheme FightCityTickets \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Step 2: Fix Build Errors (40 min)
Common issues and fixes:

**Issue: Missing imports**
```swift
// Add missing imports at top of files
import Foundation
import SwiftUI
import UIKit
```

**Issue: Code signing**
```bash
# In Xcode:
# 1. Select project → Signing & Capabilities
# 2. Select your team
# 3. Enable "Automatically manage signing"
```

**Issue: Missing assets**
- Add missing images to Assets.xcassets
- Verify Info.plist keys

**Issue: Swift version**
```bash
# Check Swift version in project.yml
# Should be: SWIFT_VERSION: "5.9"
```

### Step 3: Run SwiftLint (10 min)
```bash
# Run SwiftLint
swiftlint lint

# Auto-fix issues
swiftlint lint --fix
```

**✅ Hour 2 Complete**: Project builds without errors

---

## 🧪 Hour 3: Testing & Bug Fixes

### Step 1: Run Unit Tests (15 min)
```bash
# Run tests
xcodebuild test -project FightCityTickets.xcodeproj \
  -scheme FightCityTickets \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Step 2: Manual Testing (30 min)
Test in Simulator:
- [ ] App launches
- [ ] Camera permission requested
- [ ] Camera preview works
- [ ] Capture button works
- [ ] OCR processing works
- [ ] Citation validation works
- [ ] History screen works
- [ ] Navigation flows work

### Step 3: Fix Critical Bugs (15 min)
- Fix any crashes
- Fix UI layout issues
- Fix navigation problems

**✅ Hour 3 Complete**: App works in Simulator

---

## 🎨 Hour 4: UI Polish & Assets

### Step 1: Add App Icon (10 min)
```bash
# In Xcode:
# 1. Select Assets.xcassets
# 2. Select AppIcon
# 3. Drag 1024x1024 PNG to AppIcon slot
```

### Step 2: Polish UI (30 min)
- [ ] Check all screen sizes (iPhone SE, iPhone 15, iPad)
- [ ] Fix layout issues
- [ ] Improve spacing
- [ ] Check dark mode (if supported)
- [ ] Verify accessibility labels

### Step 3: Add Launch Screen (10 min)
- [ ] Configure launch screen
- [ ] Add app logo
- [ ] Test launch animation

### Step 4: Final Assets Check (10 min)
- [ ] All images optimized
- [ ] App icon set
- [ ] Launch screen configured
- [ ] Assets.xcassets complete

**✅ Hour 4 Complete**: UI polished, assets added

---

## 📱 Hour 5: App Store Connect Setup

### Step 1: Configure Signing (15 min)
```bash
# In Xcode:
# 1. Select project → Signing & Capabilities
# 2. Select your Team
# 3. Bundle Identifier: com.fightcitytickets.app
# 4. Enable "Automatically manage signing"
```

### Step 2: App Store Connect App (15 min)
1. Go to https://appstoreconnect.apple.com
2. My Apps → + → New App
3. Fill in:
   - Platform: iOS
   - Name: FightCityTickets
   - Primary Language: English
   - Bundle ID: com.fightcitytickets.app
   - SKU: fightcitytickets-001

### Step 3: App Information (20 min)
Fill in App Store listing:
- [ ] App Name: FightCityTickets
- [ ] Subtitle: Validate and Appeal Parking Tickets
- [ ] Category: Utilities
- [ ] Description: (from Windows prep)
- [ ] Keywords: parking, tickets, citation, appeal
- [ ] Support URL: https://fightcitytickets.com/support
- [ ] Marketing URL: https://fightcitytickets.com
- [ ] Privacy Policy URL: https://fightcitytickets.com/privacy

### Step 4: Age Rating (10 min)
Complete age rating questionnaire:
- [ ] No objectionable content
- [ ] No violence
- [ ] No profanity
- [ ] Submit questionnaire

**✅ Hour 5 Complete**: App Store Connect configured

---

## 📦 Hour 6: Archive & Upload

### Step 1: Update Version & Build (5 min)
```bash
# In Xcode:
# 1. Select project → General
# 2. Version: 1.0.0
# 3. Build: 1
# Or edit project.yml:
#   version: "1.0.0"
#   build: 1
```

### Step 2: Archive Build (15 min)
```bash
# In Xcode:
# 1. Product → Destination → Any iOS Device
# 2. Product → Archive
# Wait for archive to complete
```

### Step 3: Validate Archive (10 min)
```bash
# In Organizer window:
# 1. Select archive
# 2. Click "Validate App"
# 3. Fix any validation errors
```

### Step 4: Upload to App Store (20 min)
```bash
# In Organizer window:
# 1. Select archive
# 2. Click "Distribute App"
# 3. Select "App Store Connect"
# 4. Follow wizard
# 5. Upload
```

**✅ Hour 6 Complete**: Build uploaded to App Store Connect

---

## 📸 Hour 7: Final Testing & Screenshots

### Step 1: Test on Device (20 min)
If you have physical device:
- [ ] Install via TestFlight or Xcode
- [ ] Test all features
- [ ] Test camera functionality
- [ ] Test network requests
- [ ] Test offline mode

### Step 2: Create Screenshots (30 min)
Take screenshots in Simulator:
```bash
# iPhone 15 Pro (6.7"): 1290 x 2796
# iPhone 15 (6.1"): 1179 x 2556
# iPhone SE (4.7"): 750 x 1334

# In Simulator:
# 1. Run app
# 2. Navigate to each screen
# 3. Cmd+S to save screenshot
# 4. Edit screenshots (remove status bar if needed)
```

Required screenshots:
- [ ] Main capture screen
- [ ] OCR result screen
- [ ] Citation details screen
- [ ] History screen
- [ ] Onboarding screen (if applicable)

### Step 3: Upload Screenshots (10 min)
1. Go to App Store Connect
2. App Store → iOS App
3. Upload screenshots for each device size
4. Add captions if needed

**✅ Hour 7 Complete**: Screenshots uploaded

---

## 🚀 Hour 8: Submit for Review

### Step 1: Final Checklist (10 min)
- [ ] Build uploaded successfully
- [ ] Screenshots uploaded
- [ ] App description complete
- [ ] Privacy policy URL set
- [ ] Support URL set
- [ ] Age rating complete
- [ ] Export compliance answered

### Step 2: Submit for Review (5 min)
1. Go to App Store Connect
2. App Store → iOS App
3. Click "Submit for Review"
4. Answer export compliance questions
5. Confirm submission

### Step 3: Monitor Submission (45 min)
- [ ] Check email for confirmation
- [ ] Monitor App Store Connect for status
- [ ] Status should change to "Waiting for Review"

**✅ Hour 8 Complete**: App submitted for review!

---

## 🎉 Post-Submission

### Immediate Actions
- [ ] Save submission confirmation email
- [ ] Note submission date/time
- [ ] Share with team/stakeholders

### While Waiting for Review
- [ ] Monitor App Store Connect
- [ ] Prepare for potential rejections
- [ ] Plan marketing launch
- [ ] Prepare support documentation

### Review Timeline
- **Typical**: 24-48 hours
- **Fastest**: 2-4 hours (rare)
- **Longest**: 7 days (if issues)

### If Rejected
- [ ] Read rejection reason carefully
- [ ] Fix issues
- [ ] Resubmit with new build
- [ ] Use "Resolution Center" to communicate

---

## 🆘 Emergency Troubleshooting

### Build Fails
```bash
# Clean everything
rm -rf ~/Library/Developer/Xcode/DerivedData
xcodebuild clean
xcodegen generate
```

### Signing Issues
```bash
# Reset signing
# In Xcode: Signing & Capabilities → Remove team → Re-add team
```

### Upload Fails
- Check internet connection
- Verify Apple Developer account status
- Try uploading via Xcode Organizer instead of Transporter

### Simulator Issues
```bash
# Reset Simulator
xcrun simctl erase all
```

---

## 📞 Quick Reference

### Important URLs
- App Store Connect: https://appstoreconnect.apple.com
- Apple Developer: https://developer.apple.com
- TestFlight: https://testflight.apple.com

### Key Commands
```bash
# Generate project
xcodegen generate

# Build
xcodebuild build -project FightCityTickets.xcodeproj -scheme FightCityTickets

# Test
xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCityTickets

# Archive
xcodebuild archive -project FightCityTickets.xcodeproj -scheme FightCityTickets
```

---

## ✅ Success Criteria

By end of Mac day, you should have:
- ✅ App builds without errors
- ✅ App runs in Simulator
- ✅ All features work
- ✅ Build archived successfully
- ✅ Build uploaded to App Store Connect
- ✅ Screenshots uploaded
- ✅ App submitted for review

**You did it! 🎉**

---

**Estimated Total Time**: 8 hours
**Actual Time**: May vary based on issues encountered
**Backup Plan**: If issues arise, extend Mac rental or book second day
