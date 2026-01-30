#!/bin/bash
# Build and run unit tests for FightCityTickets (Simulator).
# Run this after: xcodegen generate (or ./Scripts/mac-setup.sh)
# Usage: ./Scripts/build-and-test.sh

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$PROJECT_ROOT/FightCityTickets.xcodeproj"
SCHEME="FightCity"
DESTINATION="platform=iOS Simulator,name=iPhone 15"

cd "$PROJECT_ROOT"

if [ ! -d "$PROJECT" ]; then
    echo "Error: FightCityTickets.xcodeproj not found."
    echo "Run first: xcodegen generate"
    exit 1
fi

echo "Building..."
xcodebuild build -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" -quiet

echo "Running tests..."
xcodebuild test -project "$PROJECT" -scheme "$SCHEME" -destination "$DESTINATION" -quiet

echo "Build and tests completed successfully."
