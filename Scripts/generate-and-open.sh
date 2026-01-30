#!/bin/bash
# Generate Xcode project and open it. Run from project root.
# Uses xcodegen (from PATH or Homebrew) or mint run XcodeGen.

set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if [ -d "FightCityTickets.xcodeproj" ]; then
    rm -rf FightCityTickets.xcodeproj
fi

if command -v xcodegen &>/dev/null; then
    echo "Using xcodegen..."
    xcodegen generate
elif command -v mint &>/dev/null; then
    echo "Using mint run XcodeGen..."
    mint run yonaskolb/XcodeGen xcodegen generate
else
    echo "Install XcodeGen first:"
    echo "  brew install xcodegen"
    echo "  OR: mint bootstrap   (then: mint run yonaskolb/XcodeGen xcodegen generate)"
    exit 1
fi

if [ -d "FightCityTickets.xcodeproj" ]; then
    open FightCityTickets.xcodeproj
    echo "Opened FightCityTickets.xcodeproj"
else
    echo "Project was not created."
    exit 1
fi
