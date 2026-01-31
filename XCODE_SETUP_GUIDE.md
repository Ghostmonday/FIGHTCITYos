# Xcode Setup Guide for App Store Submission

## ✅ Pre-Setup Checklist

- [x] App builds successfully
- [x] App runs in simulator
- [x] App icon configured (1024x1024)
- [x] Screenshots ready (9 screenshots on Desktop)
- [x] Version: 1.0 (Build: 1)

---

## 🔧 Step 1: Open Project in Xcode

1. **Open Xcode** (should already be open)
2. **Open Project**: `FightCityTickets.xcodeproj`
3. **Select Scheme**: `FightCity` (top left, next to device selector)

---

## 🔐 Step 2: Configure Code Signing

### In Xcode:

1. **Select Project** in Navigator (top item "FightCityTickets")
2. **Select Target**: `FightCity` (under TARGETS)
3. **Go to "Signing & Capabilities" tab**
4. **Check "Automatically manage signing"**
5. **Select your Team** from dropdown:
   - If you see your Apple Developer account, select it
   - If not, click "Add Account..." and sign in
6. **Bundle Identifier**: Should be `com.fightcitytickets.app`
   - If it's different, change it to match

### Verify:
- ✅ "Automatically manage signing" is checked
- ✅ Team is selected
- ✅ Bundle Identifier: `com.fightcitytickets.app`
- ✅ Provisioning Profile shows "Xcode Managed Profile"

---

## 📱 Step 3: Verify Build Settings

### In "Signing & Capabilities" tab:

1. **Version**: Should show `1.0`
2. **Build**: Should show `1`
3. **Deployment Target**: iOS 17.0

### If version/build are wrong:
- Go to "General" tab
- Update "Version" to `1.0`
- Update "Build" to `1`

---

## 🎨 Step 4: Verify App Icon

1. **In Navigator**: Expand `Resources` → `Assets.xcassets` → `AppIcon`
2. **Verify**: You should see `app_icon.png` in the 1024x1024 slot
3. **If missing**: Drag `app_icon.png` into the 1024x1024 slot

---

## 📦 Step 5: Archive Build

### Before Archiving:

1. **Select Destination**: Top left, change from simulator to **"Any iOS Device"**
   - Click device selector → "Any iOS Device"
2. **Clean Build Folder**: Product → Clean Build Folder (Shift+Cmd+K)

### Create Archive:

1. **Product** → **Archive**
2. **Wait** for archive to complete (2-5 minutes)
3. **Organizer window** will open automatically

---

## ✅ Step 6: Validate Archive

### In Organizer:

1. **Select your archive** (should be the latest one)
2. **Click "Validate App"**
3. **Select options**:
   - Distribution: App Store Connect
   - Upload: Automatically upload symbols
4. **Click "Validate"**
5. **Wait** for validation (1-2 minutes)
6. **If errors**: Fix them, then re-archive

---

## 📤 Step 7: Upload to App Store Connect

### In Organizer:

1. **Select your archive**
2. **Click "Distribute App"**
3. **Select**: App Store Connect
4. **Click "Next"**
5. **Select**: Upload
6. **Click "Next"**
7. **Review options**:
   - ✅ Include bitcode (if available)
   - ✅ Upload symbols
8. **Click "Upload"**
9. **Wait** for upload (5-10 minutes)
10. **Success!** Build will appear in App Store Connect

---

## 🚨 Common Issues & Fixes

### Issue: "No signing certificate found"
**Fix**: 
- Go to Xcode → Preferences → Accounts
- Add your Apple ID
- Select your team

### Issue: "Bundle identifier already exists"
**Fix**: 
- Change Bundle ID to something unique
- Or use existing app in App Store Connect

### Issue: "Invalid provisioning profile"
**Fix**: 
- Uncheck "Automatically manage signing"
- Re-check "Automatically manage signing"
- Select team again

### Issue: Archive fails
**Fix**: 
- Make sure destination is "Any iOS Device" (not simulator)
- Clean build folder (Shift+Cmd+K)
- Try again

---

## 📋 Post-Upload Checklist

After upload completes:

- [ ] Go to https://appstoreconnect.apple.com
- [ ] Navigate to your app (or create new app)
- [ ] Go to "App Store" → "iOS App"
- [ ] Scroll to "Build" section
- [ ] Select uploaded build
- [ ] Upload screenshots (from Desktop)
- [ ] Fill in app description
- [ ] Set pricing (Free)
- [ ] Complete age rating
- [ ] Submit for review!

---

## 🎯 Quick Reference

**Bundle ID**: `com.fightcitytickets.app`
**Version**: `1.0`
**Build**: `1`
**Deployment Target**: iOS 17.0
**Team**: Your Apple Developer Team

**Screenshots Location**: `~/Desktop/Simulator Screenshot - iPhone 16e - *.png`

---

**Ready to submit! 🚀**
