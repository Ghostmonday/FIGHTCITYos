#!/bin/bash
# Run unit tests for the FightCity app (Simulator).
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PROJECT="$ROOT/FightCityTickets.xcodeproj"
DEST="platform=iOS Simulator,name=iPhone 15"

if [ ! -d "$PROJECT" ]; then
    echo "FightCityTickets.xcodeproj not found. Run: xcodegen generate"
    exit 1
fi

echo "Running tests..."
xcodebuild test -project "$PROJECT" -scheme FightCity -destination "$DEST" -quiet
echo "Tests finished."
