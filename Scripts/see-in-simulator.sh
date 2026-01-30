#!/bin/bash
# Set up Xcode project, build, boot Simulator, and launch the app so you can see how it looks.
# Run in Terminal on your Mac:  ./Scripts/see-in-simulator.sh

set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "=============================================="
echo "  FightCityTickets – See it in the Simulator"
echo "=============================================="
echo ""

# 1. Homebrew
if ! command -v brew &>/dev/null; then
    echo "[1/6] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "[1/6] Homebrew OK."
fi

# 2. XcodeGen + SwiftLint
if ! command -v xcodegen &>/dev/null; then
    echo "[2/6] Installing XcodeGen and SwiftLint..."
    brew install xcodegen swiftlint
else
    echo "[2/6] XcodeGen OK."
fi

# 3. Xcode CLI
if ! xcode-select -p &>/dev/null; then
    echo "[3/6] Install Xcode Command Line Tools: run 'xcode-select --install' then run this script again."
    xcode-select --install
    exit 1
fi
echo "[3/6] Xcode CLI OK."
sudo xcodebuild -license accept 2>/dev/null || true

# 4. Generate Xcode project
echo "[4/6] Generating Xcode project..."
rm -rf FightCityTickets.xcodeproj
xcodegen generate
if [ ! -d "FightCityTickets.xcodeproj" ]; then
    echo "Failed to generate project."
    exit 1
fi

# 5. Pick simulator and build
DEST='platform=iOS Simulator,name=iPhone 15'
# Fallback if iPhone 15 not available
if ! xcrun simctl list devices available | grep -q "iPhone 15"; then
    DEST='platform=iOS Simulator,name=iPhone 16'
fi
if ! xcrun simctl list devices available | grep -q "iPhone 16"; then
    DEST='platform=iOS Simulator,name=iPhone 14'
fi

echo "[5/6] Building for Simulator..."
xcodebuild build -project FightCityTickets.xcodeproj -scheme FightCity -destination "$DEST" -derivedDataPath build -quiet

# 6. Boot Simulator, install app, launch
echo "[6/6] Booting Simulator and launching app..."
open -a Simulator 2>/dev/null || true

# Find the built .app (DerivedData or build)
APP_PATH=""
if [ -d "build/Build/Products/Debug-iphonesimulator/FightCity.app" ]; then
    APP_PATH="build/Build/Products/Debug-iphonesimulator/FightCity.app"
fi
if [ -z "$APP_PATH" ]; then
    APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "FightCity.app" -path "*Debug-iphonesimulator*" -type d 2>/dev/null | head -1)
fi

if [ -n "$APP_PATH" ] && [ -d "$APP_PATH" ]; then
    # Get booted simulator device UDID
    UDID=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()')
    if [ -z "$UDID" ]; then
        # Boot first available iPhone
        UDID=$(xcrun simctl list devices available | grep "iPhone" | head -1 | grep -oE '\([A-F0-9-]+\)' | tr -d '()')
        xcrun simctl boot "$UDID" 2>/dev/null || true
    fi
    if [ -n "$UDID" ]; then
        xcrun simctl install "$UDID" "$APP_PATH"
        xcrun simctl launch "$UDID" com.fightcitytickets.app
        echo ""
        echo "App launched in Simulator. You should see FightCityTickets on the device."
    else
        echo "Could not find simulator. Open Xcode, select iPhone 15 Simulator, press Cmd+R to run."
    fi
else
    echo "Built app not found. In Xcode: open FightCityTickets.xcodeproj, select iPhone 15, press Cmd+R."
fi

echo ""
echo "=============================================="
echo "  In Xcode: set your Team in Signing & Capabilities, then Cmd+R to run again."
echo "=============================================="
open FightCityTickets.xcodeproj 2>/dev/null || true
