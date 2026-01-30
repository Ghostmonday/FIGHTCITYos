#!/bin/bash
# Build the FightCity app for the iOS Simulator.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PROJECT="$ROOT/FightCityTickets.xcodeproj"
DEST="platform=iOS Simulator,name=iPhone 15"

if [ ! -d "$PROJECT" ]; then
    echo "FightCityTickets.xcodeproj not found. Run: xcodegen generate"
    exit 1
fi

echo "Building FightCity for Simulator..."
xcodebuild build -project "$PROJECT" -scheme FightCity -destination "$DEST" -quiet
echo "Build finished."
