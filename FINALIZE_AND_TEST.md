# Finalize and Test on Mac / iPhone

You’ve migrated to a Mac. Use this order: **finalize the environment → build → test (simulator) → test on iPhone / TestFlight**.

---

## Order of operations

| Step | What | Why |
|------|------|-----|
| **1** | Finalize environment | Generate Xcode project, install tools, fix any config issues |
| **2** | Build | Confirm the app compiles; fix build errors before testing |
| **3** | Test (Simulator) | Run unit tests and manual checks in Simulator |
| **4** | Test on iPhone | Run on a real device, then TestFlight if desired |

So: **finalize and build first, then test.** Don’t skip to device testing until the app builds and passes tests in Simulator.

---

## Step 1: Finalize environment (do this first)

On your Mac, in Terminal:

```bash
cd /path/to/FIGHTCITYos-main

# One-time: install Xcode Command Line Tools if prompted
xcode-select --install

# One-time: install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# One-time: install XcodeGen and SwiftLint
brew install xcodegen swiftlint

# Alternative: use Mint (no Homebrew)
# brew install mint && mint bootstrap

# Accept Xcode license if needed
sudo xcodebuild -license accept
```

Generate the Xcode project:

```bash
cd /path/to/FIGHTCITYos-main
./Scripts/mac-setup.sh
# OR generate + open in one step:
./Scripts/generate-and-open.sh
# OR manually:
xcodegen generate
open FightCityTickets.xcodeproj
# With Mint: mint run yonaskolb/XcodeGen xcodegen generate && open FightCityTickets.xcodeproj
```

In Xcode:

1. **Signing**: Select the project → **Signing & Capabilities** → choose your **Team** → enable **Automatically manage signing**.
2. Leave **Bundle ID** as `com.fightcitytickets.app` (or match what you use in App Store Connect).

---

## Step 2: Build

**In Xcode**

- Select scheme **FightCity** and destination **iPhone 15** (or any Simulator).
- **Product → Build** (⌘B).

**From Terminal**

```bash
cd /path/to/FIGHTCITYos-main
xcodebuild build -project FightCityTickets.xcodeproj -scheme FightCity \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

Fix any build errors before moving to testing.

---

## Step 3: Test (Simulator)

**Unit tests (Xcode)**

- **Product → Test** (⌘U), or run the **FightCity** scheme tests.

**Unit tests (Terminal)**

```bash
cd /path/to/FIGHTCITYos-main
xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCity \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Quick build + test script**

```bash
./Scripts/build-and-test.sh
```

**Manual checks in Simulator**

- Run the app (⌘R), then:
  - [ ] App launches
  - [ ] Camera permission (if prompted)
  - [ ] Capture flow and OCR (if applicable)
  - [ ] Navigation and History

---

## Step 4: Test on your iPhone

Do this only after the app **builds** and **tests pass** in Simulator.

### 4a. Run from Xcode on your iPhone

1. Connect your iPhone with USB (or use wireless debugging).
2. Unlock the phone and tap **Trust** if asked.
3. In Xcode: select your **iPhone** as the run destination (not Simulator).
4. **Product → Run** (⌘R).
5. On the device: **Settings → General → VPN & Device Management** → trust your developer certificate if prompted.

### 4b. TestFlight (optional, for beta testers)

1. In Xcode: **Product → Destination → Any iOS Device**.
2. **Product → Archive**.
3. In the Organizer: **Distribute App** → **App Store Connect** → upload.
4. In [App Store Connect](https://appstoreconnect.apple.com) → your app → **TestFlight** → add internal/external testers and install via the TestFlight app on the iPhone.

---

## Troubleshooting

| Issue | Action |
|-------|--------|
| **Xcode project missing** | Run `xcodegen generate` from project root. |
| **Code signing errors** | Set your Team in **Signing & Capabilities** and use automatic signing. |
| **“No such module”** | Clean (**Product → Clean Build Folder**), then build again; ensure all targets build. |
| **Simulator not listed** | Open **Xcode → Settings → Platforms** and install an iOS Simulator. |
| **Device not trusted** | On iPhone: **Settings → General → VPN & Device Management** → trust your developer cert. |

---

## Quick reference

- **Generate project**: `xcodegen generate` then `open FightCityTickets.xcodeproj`
- **Build**: `xcodebuild build -project FightCityTickets.xcodeproj -scheme FightCity -destination 'platform=iOS Simulator,name=iPhone 15'`
- **Test**: `xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCity -destination 'platform=iOS Simulator,name=iPhone 15'`
- **Lint**: `swiftlint lint`

For the full Mac-day flow (including App Store submit), see **MAC_DAY_CHECKLIST.md**.
