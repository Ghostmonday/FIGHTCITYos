#!/bin/bash

# Mac Setup Script - Run this first on your rented Mac
# This script sets up everything needed for iOS development

set -e  # Exit on error

echo "🚀 FightCityTickets Mac Setup Script"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check macOS version
echo "Checking macOS version..."
MACOS_VERSION=$(sw_vers -productVersion)
echo "macOS Version: $MACOS_VERSION"

if [[ $(echo "$MACOS_VERSION 13.0" | awk '{print ($1 >= $2)}') == 1 ]]; then
    print_status "macOS version is compatible"
else
    print_error "macOS 13.0+ required. Current: $MACOS_VERSION"
    exit 1
fi

# Check Xcode
echo ""
echo "Checking Xcode installation..."
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_status "Xcode found: $XCODE_VERSION"
    
    # Check if license accepted
    if xcodebuild -checkFirstLaunchStatus 2>&1 | grep -q "requires admin privileges"; then
        print_warning "Xcode license needs to be accepted"
        echo "Run: sudo xcodebuild -license accept"
    else
        print_status "Xcode license accepted"
    fi
else
    print_error "Xcode not found. Please install Xcode from App Store."
    exit 1
fi

# Install Homebrew if not installed
echo ""
echo "Checking Homebrew..."
if command -v brew &> /dev/null; then
    print_status "Homebrew installed"
    BREW_VERSION=$(brew --version | head -n 1)
    echo "  Version: $BREW_VERSION"
else
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_status "Homebrew installed"
fi

# Update Homebrew
echo ""
echo "Updating Homebrew..."
brew update

# Install XcodeGen
echo ""
echo "Checking XcodeGen..."
if command -v xcodegen &> /dev/null; then
    XCODEGEN_VERSION=$(xcodegen --version)
    print_status "XcodeGen installed: $XCODEGEN_VERSION"
else
    print_warning "XcodeGen not found. Installing..."
    brew install xcodegen
    print_status "XcodeGen installed"
fi

# Install SwiftLint
echo ""
echo "Checking SwiftLint..."
if command -v swiftlint &> /dev/null; then
    SWIFTLINT_VERSION=$(swiftlint version)
    print_status "SwiftLint installed: $SWIFTLINT_VERSION"
else
    print_warning "SwiftLint not found. Installing..."
    brew install swiftlint
    print_status "SwiftLint installed"
fi

# Check Git
echo ""
echo "Checking Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_status "Git installed: $GIT_VERSION"
else
    print_error "Git not found. Please install Git."
    exit 1
fi

# Check if project exists
echo ""
echo "Checking project files..."
if [ -f "project.yml" ]; then
    print_status "project.yml found"
else
    print_error "project.yml not found. Are you in the project directory?"
    exit 1
fi

# Generate Xcode project using foolproof script
echo ""
echo "Setting up Xcode project (foolproof)..."
if [ -f "Scripts/xcode-setup.sh" ]; then
    chmod +x Scripts/xcode-setup.sh
    ./Scripts/xcode-setup.sh
else
    # Fallback to basic xcodegen
    echo "Using basic xcodegen (xcode-setup.sh not found)..."
    if xcodegen generate; then
        print_status "Xcode project generated successfully"
    else
        print_error "Failed to generate Xcode project"
        exit 1
    fi
    
    if [ -d "FightCityTickets.xcodeproj" ]; then
        print_status "Xcode project created: FightCityTickets.xcodeproj"
    else
        print_error "Xcode project not found after generation"
        exit 1
    fi
fi

# Run SwiftLint
echo ""
echo "Running SwiftLint..."
if swiftlint lint --quiet; then
    print_status "SwiftLint passed"
else
    print_warning "SwiftLint found issues. Run 'swiftlint lint' to see details."
    print_warning "Run 'swiftlint lint --fix' to auto-fix issues."
fi

# Summary
echo ""
echo "======================================"
echo "✅ Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Open FightCityTickets.xcodeproj in Xcode"
echo "2. Select your development team in Signing & Capabilities"
echo "3. Build the project (Cmd+B)"
echo "4. Run in Simulator (Cmd+R)"
echo ""
echo "For detailed instructions, see MAC_DAY_CHECKLIST.md"
echo "======================================"
