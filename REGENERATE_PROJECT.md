# Regenerate Xcode Project

The Xcode project needs to be regenerated after cleanup. Choose one method:

## Method 1: Using Homebrew (Recommended)

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install XcodeGen
brew install xcodegen

# Generate project
cd /Users/rentamac/Documents/FIGHTCITYos
xcodegen generate
```

## Method 2: Using Mint

```bash
# Install Mint (if not installed)
brew install mint

# Bootstrap Mint packages
cd /Users/rentamac/Documents/FIGHTCITYos
mint bootstrap

# Generate project
mint run yonaskolb/XcodeGen xcodegen generate
```

## Method 3: Manual Installation

If you prefer not to use package managers:

1. Download XcodeGen from: https://github.com/yonaskolb/XcodeGen/releases
2. Extract and add to your PATH
3. Run: `xcodegen generate`

## After Generation

Once the project is generated:
1. Open `FightCityTickets.xcodeproj` in Xcode
2. Build the project (Cmd+B) to verify everything works
3. The SceneDelegate.swift reference error should be gone

---

**Note:** The project file (`FightCityTickets.xcodeproj`) is generated from `project.yml` - it's not stored in git and can always be regenerated.
