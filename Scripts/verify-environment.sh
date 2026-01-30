#!/bin/bash
# Verify the iOS app development workspace environment (Mac).
# Run after setup to confirm Xcode, XcodeGen, SwiftLint, and project are ready.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "=============================================="
echo "  FightCityTickets – Environment Check"
echo "=============================================="
echo ""

OK=0
FAIL=0

# Xcode
if xcode-select -p &>/dev/null; then
    echo "  [OK] Xcode Command Line Tools"
    xcodebuild -version 2>/dev/null | head -1 || true
    ((OK++)) || true
else
    echo "  [FAIL] Xcode Command Line Tools – run: xcode-select --install"
    ((FAIL++)) || true
fi

# XcodeGen
if command -v xcodegen &>/dev/null; then
    echo "  [OK] XcodeGen $(xcodegen --version 2>/dev/null)"
    ((OK++)) || true
else
    echo "  [FAIL] XcodeGen – run: brew install xcodegen"
    ((FAIL++)) || true
fi

# SwiftLint
if command -v swiftlint &>/dev/null; then
    echo "  [OK] SwiftLint $(swiftlint version 2>/dev/null)"
    ((OK++)) || true
else
    echo "  [FAIL] SwiftLint – run: brew install swiftlint"
    ((FAIL++)) || true
fi

# project.yml
if [ -f "$ROOT/project.yml" ]; then
    echo "  [OK] project.yml"
    ((OK++)) || true
else
    echo "  [FAIL] project.yml not found"
    ((FAIL++)) || true
fi

# Generated Xcode project
if [ -d "$ROOT/FightCityTickets.xcodeproj" ]; then
    echo "  [OK] FightCityTickets.xcodeproj (run xcodegen generate if you change project.yml)"
    ((OK++)) || true
else
    echo "  [--] FightCityTickets.xcodeproj not found – run: xcodegen generate"
fi

# Sources
for dir in Sources/FightCity Sources/FightCityiOS Sources/FightCityFoundation; do
    if [ -d "$ROOT/$dir" ]; then
        echo "  [OK] $dir"
    else
        echo "  [FAIL] $dir missing"
        ((FAIL++)) || true
    fi
done

echo ""
if [ "$FAIL" -gt 0 ]; then
    echo "  Some checks failed. Fix the [FAIL] items above."
    exit 1
fi
echo "  Environment looks good. Open FightCityTickets.xcodeproj and run (⌘R)."
echo "=============================================="
