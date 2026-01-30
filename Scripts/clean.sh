#!/bin/bash
# Clean build artifacts for the iOS app workspace.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Cleaning build artifacts..."
rm -rf "$ROOT/build"
rm -rf FightCityTickets.xcodeproj

echo "Local build/ and generated .xcodeproj removed."
echo "To clean Xcode DerivedData (optional):"
echo "  rm -rf ~/Library/Developer/Xcode/DerivedData"
echo "To regenerate project: xcodegen generate"
