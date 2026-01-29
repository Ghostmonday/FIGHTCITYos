#!/bin/bash
# Foolproof Xcode Setup Script
# This script validates, generates, and verifies Xcode project setup
# Run this after project reorganization to ensure Xcode is perfectly configured

set -e

echo "🚀 FightCityTickets Xcode Setup - Foolproof Edition"
echo "===================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: Validate project.yml
echo -e "${BLUE}Step 1:${NC} Validating project.yml..."
if ! command -v xcodegen &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} XcodeGen not installed. Installing..."
    if command -v brew &> /dev/null; then
        brew install xcodegen
    else
        echo -e "${RED}✗${NC} Homebrew not found. Please install XcodeGen manually:"
        echo "  brew install xcodegen"
        exit 1
    fi
fi

if [ ! -f "project.yml" ]; then
    echo -e "${RED}✗${NC} project.yml not found!"
    echo "Make sure you're in the project root directory."
    exit 1
fi

# Validate YAML syntax by attempting dry-run
echo "Validating project.yml syntax..."
if xcodegen generate --dry-run > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} project.yml syntax is valid"
else
    echo -e "${YELLOW}⚠${NC} Validating project.yml (may show warnings)..."
    xcodegen generate --dry-run || true
fi
echo ""

# Step 2: Generate Xcode project
echo -e "${BLUE}Step 2:${NC} Generating Xcode project..."
if [ -d "FightCityTickets.xcodeproj" ]; then
    echo "Removing existing project..."
    rm -rf FightCityTickets.xcodeproj
fi

if xcodegen generate; then
    echo -e "${GREEN}✓${NC} Xcode project generated successfully"
else
    echo -e "${RED}✗${NC} Failed to generate Xcode project"
    echo "Check project.yml for errors."
    exit 1
fi
echo ""

# Step 3: Verify project structure
echo -e "${BLUE}Step 3:${NC} Verifying project structure..."
if [ ! -d "FightCityTickets.xcodeproj" ]; then
    echo -e "${RED}✗${NC} Xcode project not created!"
    exit 1
fi

# Check for required targets
echo "Checking targets..."
TARGETS=("FightCity" "FightCityiOS" "FightCityFoundation")
MISSING_TARGETS=()

for target in "${TARGETS[@]}"; do
    if xcodebuild -list -project FightCityTickets.xcodeproj 2>/dev/null | grep -q "$target"; then
        echo -e "${GREEN}✓${NC} Target '$target' found"
    else
        echo -e "${RED}✗${NC} Target '$target' not found!"
        MISSING_TARGETS+=("$target")
    fi
done

if [ ${#MISSING_TARGETS[@]} -gt 0 ]; then
    echo -e "${RED}✗${NC} Missing targets: ${MISSING_TARGETS[*]}"
    echo "Check project.yml target definitions."
    exit 1
fi
echo ""

# Step 4: Verify source files exist
echo -e "${BLUE}Step 4:${NC} Verifying source files..."
SOURCE_DIRS=("Sources/FightCity" "Sources/FightCityiOS" "Sources/FightCityFoundation")
MISSING_DIRS=()

for dir in "${SOURCE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        FILE_COUNT=$(find "$dir" -name "*.swift" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$FILE_COUNT" -gt 0 ]; then
            echo -e "${GREEN}✓${NC} $dir ($FILE_COUNT Swift files)"
        else
            echo -e "${YELLOW}⚠${NC} $dir exists but has no Swift files yet"
        fi
    else
        echo -e "${YELLOW}⚠${NC} $dir not found (will be created during migration)"
        MISSING_DIRS+=("$dir")
    fi
done
echo ""

# Step 5: Check Xcode installation
echo -e "${BLUE}Step 5:${NC} Checking Xcode installation..."
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}✗${NC} Xcode not installed or command line tools missing"
    echo "Install Xcode from App Store, then run:"
    echo "  sudo xcodebuild -license accept"
    exit 1
fi

XCODE_VERSION=$(xcodebuild -version | head -n 1)
echo -e "${GREEN}✓${NC} $XCODE_VERSION installed"

# Check license
if xcodebuild -checkFirstLaunchStatus 2>&1 | grep -q "requires admin"; then
    echo -e "${YELLOW}⚠${NC} Xcode license needs acceptance"
    echo "Run: sudo xcodebuild -license accept"
else
    echo -e "${GREEN}✓${NC} Xcode license accepted"
fi
echo ""

# Step 6: Test project configuration
echo -e "${BLUE}Step 6:${NC} Testing project configuration..."
echo "Checking build settings..."

# Check if we can list schemes
if xcodebuild -list -project FightCityTickets.xcodeproj > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Project configuration is valid"
    
    # List all schemes
    echo ""
    echo "Available schemes:"
    xcodebuild -list -project FightCityTickets.xcodeproj | grep -A 10 "Schemes:" | tail -n +2 | sed 's/^/  /'
else
    echo -e "${YELLOW}⚠${NC} Could not list schemes (sources may not exist yet)"
fi
echo ""

# Step 7: Check for common issues
echo -e "${BLUE}Step 7:${NC} Checking for common issues..."

# Check Swift version
SWIFT_VERSION=$(xcodebuild -project FightCityTickets.xcodeproj -showBuildSettings -target FightCity 2>/dev/null | grep "SWIFT_VERSION" | head -n 1 | awk '{print $3}')
if [ -n "$SWIFT_VERSION" ]; then
    echo -e "${GREEN}✓${NC} Swift version: $SWIFT_VERSION"
else
    echo -e "${YELLOW}⚠${NC} Could not determine Swift version"
fi

# Check deployment target
DEPLOYMENT_TARGET=$(xcodebuild -project FightCityTickets.xcodeproj -showBuildSettings -target FightCity 2>/dev/null | grep "IPHONEOS_DEPLOYMENT_TARGET" | head -n 1 | awk '{print $3}')
if [ -n "$DEPLOYMENT_TARGET" ]; then
    echo -e "${GREEN}✓${NC} Deployment target: iOS $DEPLOYMENT_TARGET"
else
    echo -e "${YELLOW}⚠${NC} Could not determine deployment target"
fi
echo ""

# Step 8: Open in Xcode
echo -e "${BLUE}Step 8:${NC} Opening in Xcode..."
if command -v open &> /dev/null; then
    open FightCityTickets.xcodeproj
    echo -e "${GREEN}✓${NC} Project opened in Xcode"
else
    echo -e "${YELLOW}⚠${NC} Could not open Xcode (not on macOS?)"
    echo "Manually open: FightCityTickets.xcodeproj"
fi
echo ""

# Final instructions
echo "===================================================="
echo -e "${GREEN}✅ Xcode Setup Complete!${NC}"
echo ""
echo "Next steps in Xcode:"
echo "1. Select your development team:"
echo "   - Click project → Signing & Capabilities"
echo "   - Select your team from dropdown"
echo "   - Enable 'Automatically manage signing'"
echo ""
echo "2. Build the project:"
echo "   - Press Cmd+B or Product → Build"
echo ""
echo "3. Run in Simulator:"
echo "   - Select iPhone 15 Simulator"
echo "   - Press Cmd+R or Product → Run"
echo ""
echo "If you see any errors:"
echo "- Check 'Common Xcode Issues' section in plan"
echo "- Run: xcodebuild clean"
echo "- Run: xcodegen generate"
echo "- Run this script again: ./Scripts/xcode-setup.sh"
echo ""
echo "For detailed troubleshooting, see:"
echo "- MAC_DAY_CHECKLIST.md"
echo "- Repository reorganization plan"
echo "===================================================="
