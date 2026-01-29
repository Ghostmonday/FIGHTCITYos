# Windows Development Guide - Maximum Productivity Before Mac Day

## 🎯 Goal: Do 95% of work on Windows, finish on Mac in 1 day

This guide helps you maximize development on Windows, then seamlessly transition to a rented Mac for final build, polish, and App Store submission.

---

## ✅ What You CAN Do on Windows

### 1. Code Development (100% Windows-Compatible)
- ✅ Edit all Swift files (.swift)
- ✅ Edit project.yml (XcodeGen config)
- ✅ Edit Info.plist
- ✅ Edit .gitignore, .swiftlint.yml
- ✅ Write documentation (Markdown)
- ✅ Design UI/UX (Figma, Adobe XD)
- ✅ Version control (Git)
- ✅ Code review and planning

### 2. Code Quality (Windows-Compatible)
- ✅ Run SwiftLint (via Docker or WSL)
- ✅ Static code analysis
- ✅ Documentation writing
- ✅ Architecture planning

### 3. Testing Preparation (Windows-Compatible)
- ✅ Write unit tests
- ✅ Write UI test scripts
- ✅ Create test data
- ✅ Document test cases

### 4. App Store Preparation (Windows-Compatible)
- ✅ Write App Store description
- ✅ Create screenshots (design mockups)
- ✅ Write privacy policy
- ✅ Prepare marketing materials
- ✅ App Store Connect setup (web-based)

---

## ❌ What You CANNOT Do on Windows

- ❌ Build iOS app (requires Xcode)
- ❌ Run iOS Simulator
- ❌ Test on device
- ❌ Archive for App Store
- ❌ Code signing
- ❌ Final App Store submission

---

## 🛠️ Windows Development Setup

### Option 1: WSL2 + Docker (Recommended)

```powershell
# Install WSL2
wsl --install

# Install Docker Desktop for Windows
# Download from: https://www.docker.com/products/docker-desktop

# Use Swift Docker image for syntax checking
docker run -it -v ${PWD}:/workspace swift:5.9 bash
cd /workspace
swift --version
```

### Option 2: GitHub Codespaces / GitPod

Use cloud-based IDE with Swift support:
- GitHub Codespaces (free tier available)
- GitPod (free tier available)

### Option 3: VS Code + Swift Extensions

```powershell
# Install VS Code
# Install extensions:
# - Swift (by sswg)
# - SwiftLint
# - GitLens
```

---

## 📋 Pre-Mac Checklist (Complete on Windows)

### Code Quality
- [ ] All Swift files written and reviewed
- [ ] SwiftLint passes (run via Docker/WSL)
- [ ] No syntax errors (check with Swift Docker)
- [ ] All TODO comments resolved
- [ ] Code comments added
- [ ] Error handling implemented

### Project Configuration
- [ ] `project.yml` is complete and valid
- [ ] `Info.plist` has all required keys
- [ ] Bundle identifier set: `com.fightcitytickets.app`
- [ ] App icons prepared (1024x1024 PNG)
- [ ] Launch screen configured
- [ ] Privacy permissions configured

### Documentation
- [ ] README.md complete
- [ ] App Store description written
- [ ] Privacy policy written
- [ ] Support URL ready
- [ ] Marketing URL ready

### Testing
- [ ] Unit tests written
- [ ] UI test scripts written
- [ ] Test data prepared
- [ ] Test cases documented

### App Store Connect
- [ ] Apple Developer account active ($99/year)
- [ ] App Store Connect app created
- [ ] App Store listing prepared
- [ ] Screenshots designed (mockups)
- [ ] App preview video script (if needed)

### Git Repository
- [ ] All code committed
- [ ] .gitignore configured
- [ ] Repository pushed to GitHub/GitLab
- [ ] Branch strategy defined

---

## 🚀 Windows Development Workflow

### Daily Workflow

1. **Morning Setup**
   ```powershell
   # Pull latest changes
   git pull origin main
   
   # Check Swift syntax (Docker)
   docker run -it -v ${PWD}:/workspace swift:5.9 swift --version
   ```

2. **Code Development**
   - Edit Swift files in VS Code
   - Use Swift extension for syntax highlighting
   - Commit frequently

3. **Code Quality Check**
   ```powershell
   # Run SwiftLint (if available via Docker/WSL)
   # Or use GitHub Actions for linting
   ```

4. **End of Day**
   ```powershell
   # Commit and push
   git add .
   git commit -m "Feature: [description]"
   git push origin main
   ```

---

## 📦 Pre-Mac Package Preparation

Before renting Mac, ensure you have:

### 1. Code Repository
```powershell
# Create a release branch
git checkout -b release/v1.0.0
git push origin release/v1.0.0
```

### 2. App Store Assets
Create these files on Windows:
- `AppStore/screenshots/` (design mockups)
- `AppStore/description.txt`
- `AppStore/keywords.txt`
- `AppStore/privacy-policy.md`

### 3. Developer Account Info
- Apple ID email
- Apple Developer account password
- Two-factor authentication device ready
- Team ID (found in App Store Connect)

### 4. Mac Rental Checklist
- [ ] Mac rental service booked (MacStadium, MacinCloud, etc.)
- [ ] Access credentials received
- [ ] VPN/Remote access tested
- [ ] Backup plan (second rental service)

---

## 🔍 Pre-Flight Verification Script

Run this before Mac day to ensure everything is ready:

```powershell
# verify-windows-setup.ps1
Write-Host "=== Pre-Mac Verification ===" -ForegroundColor Green

# Check Git
Write-Host "Checking Git..." -ForegroundColor Yellow
git --version
git status

# Check project files
Write-Host "Checking project files..." -ForegroundColor Yellow
if (Test-Path "project.yml") { Write-Host "✓ project.yml exists" -ForegroundColor Green }
if (Test-Path "App") { Write-Host "✓ App directory exists" -ForegroundColor Green }
if (Test-Path "Resources") { Write-Host "✓ Resources directory exists" -ForegroundColor Green }

# Check Swift files
$swiftFiles = Get-ChildItem -Recurse -Filter "*.swift"
Write-Host "Found $($swiftFiles.Count) Swift files" -ForegroundColor Cyan

# Check for TODO/FIXME
$todos = Select-String -Path "*.swift" -Pattern "TODO|FIXME" -Recurse
if ($todos) {
    Write-Host "⚠ Found TODOs/FIXMEs:" -ForegroundColor Yellow
    $todos | ForEach-Object { Write-Host "  $($_.Filename):$($_.LineNumber)" }
} else {
    Write-Host "✓ No TODOs/FIXMEs found" -ForegroundColor Green
}

# Check Git status
Write-Host "`nGit Status:" -ForegroundColor Yellow
git status --short

Write-Host "`n=== Verification Complete ===" -ForegroundColor Green
```

---

## 📱 App Store Connect Preparation (Do on Windows)

### 1. Create App Listing
1. Go to https://appstoreconnect.apple.com
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: FightCityTickets
   - Primary Language: English
   - Bundle ID: com.fightcitytickets.app
   - SKU: fightcitytickets-001

### 2. Prepare App Information
- App Name: FightCityTickets
- Subtitle: Validate and Appeal Parking Tickets
- Category: Utilities
- Content Rights: Yes, I have rights
- Age Rating: Complete questionnaire

### 3. Prepare Screenshots (Design Mockups)
Create placeholder screenshots showing:
- Main capture screen
- OCR result screen
- Citation details screen
- History screen

### 4. Write App Description
```
FightCityTickets helps you validate and appeal parking tickets quickly and easily.

KEY FEATURES:
• Scan parking tickets with your camera
• Automatic citation number recognition
• Validate citations against city databases
• Track multiple citations
• Appeal tickets directly from the app
• Works offline - queue requests when offline

SUPPORTED CITIES:
• San Francisco (SFMTA)
• Los Angeles
• New York City
• Denver

Privacy-focused with opt-in telemetry only.
```

---

## 🎯 Mac Day Action Plan

See `MAC_DAY_CHECKLIST.md` for the complete one-day plan.

---

## 💡 Pro Tips for Windows Development

1. **Use GitHub Actions for CI**
   - Set up automated builds
   - Run tests automatically
   - Get build feedback without Mac

2. **Test Swift Syntax with Docker**
   ```powershell
   docker run -it -v ${PWD}:/workspace swift:5.9 bash
   cd /workspace
   swift build  # Check for syntax errors
   ```

3. **Use VS Code Extensions**
   - Swift extension for syntax highlighting
   - GitLens for version control
   - Error Lens for inline errors

4. **Design UI Mockups**
   - Use Figma/Adobe XD for UI design
   - Export assets ready for Xcode
   - Create screenshot mockups

5. **Document Everything**
   - Write comprehensive README
   - Document API endpoints
   - Create user guides

---

## 🆘 Troubleshooting

### Swift Syntax Checking
If Docker isn't available, use GitHub Actions:
```yaml
# .github/workflows/syntax-check.yml
name: Syntax Check
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: swift-actions/setup-swift@v1
      - run: swift build
```

### File Encoding Issues
Ensure all files are UTF-8:
```powershell
# Check encoding
Get-Content file.swift -Encoding UTF8
```

### Line Ending Issues
```powershell
# Set Git to handle line endings
git config core.autocrlf true
```

---

## 📞 Support Resources

- **Apple Developer Forums**: https://developer.apple.com/forums/
- **Swift Forums**: https://forums.swift.org/
- **Stack Overflow**: Tag `swift` and `ios`
- **Mac Rental Services**:
  - MacStadium: https://www.macstadium.com/
  - MacinCloud: https://www.macincloud.com/
  - AWS EC2 Mac: https://aws.amazon.com/ec2/instance-types/mac/

---

**Next Step**: Complete the Windows checklist, then proceed to `MAC_DAY_CHECKLIST.md` for your Mac rental day plan.
