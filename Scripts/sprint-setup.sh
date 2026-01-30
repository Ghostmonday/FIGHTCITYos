#!/bin/bash
# Sprint setup for Mac: install deps, generate Xcode project, build, test.
# Run in Terminal on your Mac:  ./Scripts/sprint-setup.sh

set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# Ensure Homebrew is on PATH (Apple Silicon / Intel)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "=============================================="
echo "  FightCityTickets – Sprint setup on Mac"
echo "=============================================="
echo ""

# --- 1. Homebrew ---
if ! command -v brew &>/dev/null; then
    echo "[1/5] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add to PATH for this session (Apple Silicon / Intel)
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "[1/5] Homebrew already installed."
    command -v brew | xargs -I {} eval '$({} shellenv 2>/dev/null)' 2>/dev/null || true
fi

# --- 2. XcodeGen + SwiftLint ---
if ! command -v xcodegen &>/dev/null; then
    echo "[2/5] Installing XcodeGen and SwiftLint..."
    brew install xcodegen swiftlint
else
    echo "[2/5] XcodeGen already installed."
fi
command -v swiftlint &>/dev/null || brew install swiftlint

# --- 3. Xcode / CLI tools ---
if ! xcode-select -p &>/dev/null; then
    echo "[3/5] Xcode CLI tools required. Run: xcode-select --install"
    xcode-select --install
    echo "After install finishes, run this script again."
    exit 1
fi
echo "[3/5] Xcode CLI tools OK."
sudo xcodebuild -license accept 2>/dev/null || true

# --- 4. Generate Xcode project ---
echo "[4/5] Generating Xcode project..."
rm -rf FightCityTickets.xcodeproj
xcodegen generate
if [ ! -d "FightCityTickets.xcodeproj" ]; then
    echo "Failed to generate project."
    exit 1
fi
echo "    FightCityTickets.xcodeproj created."

# --- 5. Build and test ---
echo "[5/5] Building and running tests..."
DEST='platform=iOS Simulator,name=iPhone 15'
xcodebuild build -project FightCityTickets.xcodeproj -scheme FightCity -destination "$DEST" -quiet
xcodebuild test -project FightCityTickets.xcodeproj -scheme FightCity -destination "$DEST" -quiet

echo ""
echo "=============================================="
echo "  Sprint setup complete."
echo "=============================================="
echo "Opening Xcode..."
open FightCityTickets.xcodeproj

echo ""
echo "In Xcode: Signing & Capabilities → select your Team, then ⌘R to run."
echo ""
