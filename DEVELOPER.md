# FightCityTickets – iOS App Development Workspace

This repo is set up as a **proper iOS app development workspace**. Use this guide to work here day to day.

---

## Workspace at a glance

| Item | Value |
|------|--------|
| **App name** | FightCityTickets |
| **Bundle ID** | `com.fightcitytickets.app` |
| **Xcode** | 15.0+ (see `.xcode-version`) |
| **Swift** | 5.9 (see `.swift-version`) |
| **iOS target** | 16.0+ |
| **Project generator** | XcodeGen (`project.yml` → `FightCityTickets.xcodeproj`) |

---

## One-time setup (Mac)

1. **Xcode**  
   Install from the App Store. Accept license:  
   `sudo xcodebuild -license accept`

2. **Command Line Tools**  
   If needed: `xcode-select --install`

3. **Homebrew**  
   [brew.sh](https://brew.sh) — then:

   ```bash
   brew install xcodegen swiftlint
   ```

4. **Generate Xcode project**

   ```bash
   ./Scripts/generate-and-open.sh
   # or: xcodegen generate && open FightCityTickets.xcodeproj
   ```

5. **In Xcode**  
   Set your **Team** under **Signing & Capabilities** for the FightCity target.

**Verify everything:**

```bash
./Scripts/verify-environment.sh
```

---

## Daily workflow

| Task | Command |
|------|--------|
| **Lint** | `./Scripts/lint.sh` |
| **Build** | `./Scripts/build.sh` or Xcode ⌘B |
| **Test** | `./Scripts/test.sh` or Xcode ⌘U |
| **Run in Simulator** | Xcode: select iPhone 15 (or device), ⌘R |
| **Clean** | `./Scripts/clean.sh` or Xcode ⇧⌘K |
| **Regenerate project** | `xcodegen generate` |

---

## Project layout

```
FIGHTCITYos-main/
├── .xcode-version          # Xcode 15.0
├── .swift-version           # Swift 5.9
├── project.yml              # XcodeGen → FightCityTickets.xcodeproj
├── .swiftlint.yml           # Linting rules
│
├── Sources/
│   ├── FightCity/           # Main app (SwiftUI, features)
│   ├── FightCityiOS/        # iOS-only (Camera, OCR, Vision)
│   └── FightCityFoundation/  # Shared logic (networking, models)
│
├── Tests/
│   ├── UnitTests/           # Foundation, iOS, App tests
│   └── UITests/             # UI automation
│
├── Resources/               # Assets, Info.plist, strings
├── Support/                 # Framework Info.plists, Privacy
└── Scripts/                  # All dev and setup scripts
```

**Rule:** The source of truth for the Xcode project is `project.yml`. Do not edit `FightCityTickets.xcodeproj` by hand; run `xcodegen generate` after changing `project.yml`.

---

## Scripts reference

| Script | Purpose |
|--------|--------|
| `verify-environment.sh` | Check Xcode, XcodeGen, SwiftLint, schemes |
| `generate-and-open.sh` | Generate project and open in Xcode |
| `lint.sh` | Run SwiftLint |
| `build.sh` | Build app for Simulator |
| `test.sh` | Run unit tests |
| `clean.sh` | Remove build artifacts and DerivedData |
| `build-and-test.sh` | Build + test in one go |
| `see-in-simulator.sh` | Full setup + build + launch in Simulator |
| `mac-setup.sh` | First-time Mac setup (Homebrew, XcodeGen, generate) |
| `sprint-setup.sh` | One-shot setup + build + test + open Xcode |

---

## Code quality

- **SwiftLint** is configured in `.swiftlint.yml`.  
  Run `./Scripts/lint.sh` before committing.  
  Auto-fix where possible: `swiftlint --fix` (or use the script if it runs with `--fix`).

- **Tests**  
  Unit tests in `Tests/UnitTests/`. Run with `./Scripts/test.sh` or ⌘U in Xcode.

---

## Where to read more

- **FINALIZE_AND_TEST.md** – Build, test, run on device / TestFlight
- **README_IOS_BUILD.md** – Build and run from the command line
- **MAC_DAY_CHECKLIST.md** – Full Mac day through App Store submit
- **APP_SPECIFICATION.md** – Product and technical spec
- **CONTRIBUTING.md** – Branching, commits, PRs

---

## Troubleshooting

| Problem | Fix |
|--------|-----|
| No `FightCityTickets.xcodeproj` | Run `xcodegen generate` (or `./Scripts/generate-and-open.sh`) |
| Build errors after editing `project.yml` | Run `xcodegen generate` again |
| Signing errors | In Xcode: Signing & Capabilities → choose Team, enable automatic signing |
| Simulator not listed | Xcode → Settings → Platforms → install an iOS Simulator |
| Lint fails | `./Scripts/lint.sh` to see rules; fix or adjust `.swiftlint.yml` |

Run `./Scripts/verify-environment.sh` to confirm your Mac is set up correctly for this workspace.
