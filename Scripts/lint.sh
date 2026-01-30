#!/bin/bash
# Run SwiftLint for the iOS app workspace. Use before committing.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v swiftlint &>/dev/null; then
    echo "SwiftLint not found. Install: brew install swiftlint"
    exit 1
fi

echo "Running SwiftLint..."
swiftlint lint --config "$ROOT/.swiftlint.yml"

echo "Lint finished."
