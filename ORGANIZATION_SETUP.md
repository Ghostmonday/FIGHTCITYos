# Setting Up Organization Developer Account in Xcode

## ✅ You Have: Organization Apple Developer Account
This means you have full App Store access! Let's get it configured.

---

## 🔧 Step 1: Add Your Apple ID to Xcode

1. **Open Xcode**
2. **Xcode** → **Preferences** (or press `Cmd + ,`)
3. **Click "Accounts" tab** (top of Preferences window)
4. **Click the "+" button** (bottom left)
5. **Select "Apple ID"**
6. **Enter your Apple ID email** (the one associated with your organization account)
7. **Enter your password**
8. **Click "Sign In"**
9. **You should see your organization name** appear in the list

---

## 🔐 Step 2: Select Your Organization Team

1. **In Xcode**: Select your project **FightCityTickets** (top of Navigator)
2. **Select Target**: **FightCity** (under TARGETS)
3. **Go to "Signing & Capabilities" tab**
4. **Check "Automatically manage signing"**
5. **Team dropdown**: Select your **Organization Name** (not "Personal Team")
   - It should show something like: `Your Organization Name (XXXXXXXXXX)`
   - The X's are your Team ID
6. **Verify**:
   - ✅ "Automatically manage signing" is checked
   - ✅ Your organization team is selected
   - ✅ Bundle Identifier: `com.fightcitytickets.app`
   - ✅ Provisioning Profile shows "Xcode Managed Profile"

---

## ⚠️ If You See Errors

### Error: "No accounts with App Store Connect access"
**Fix**: Make sure you're signed in with the Apple ID that has admin access to your organization account.

### Error: "Bundle identifier is already in use"
**Fix**: 
- Option 1: Change Bundle ID to something unique (e.g., `com.fightcitytickets.app.v2`)
- Option 2: Use existing app in App Store Connect if it's yours

### Error: "No provisioning profiles found"
**Fix**: 
- Make sure "Automatically manage signing" is checked
- Xcode will create profiles automatically
- Wait a few seconds for Xcode to sync

---

## 📋 Step 3: Verify Configuration

After selecting your team, you should see:

- ✅ **Signing Certificate**: "Apple Distribution" or "Apple Development"
- ✅ **Provisioning Profile**: "Xcode Managed Profile"
- ✅ **Status**: Green checkmark (no errors)

---

## 🚀 Step 4: Archive (Once Team is Selected)

1. **Change Destination**: Top left, select **"Any iOS Device"** (not simulator)
2. **Product** → **Archive**
3. **Wait** for archive (2-5 minutes)
4. **Organizer opens automatically**

---

## 📤 Step 5: Upload to App Store Connect

1. **In Organizer**: Select your archive
2. **Click "Distribute App"**
3. **Select**: App Store Connect
4. **Click "Next"** through the wizard
5. **Upload** your build

---

## 🎯 Quick Checklist

- [ ] Apple ID added to Xcode Preferences → Accounts
- [ ] Organization team visible in Accounts list
- [ ] Team selected in Signing & Capabilities
- [ ] "Automatically manage signing" checked
- [ ] No signing errors (green checkmark)
- [ ] Ready to Archive!

---

**Once your organization team is selected, you're ready to archive! 🚀**
