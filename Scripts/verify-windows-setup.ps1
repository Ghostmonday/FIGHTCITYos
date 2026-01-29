# Pre-Mac Verification Script for Windows
# Run this before your Mac rental day to ensure everything is ready

Write-Host "=== FightCityTickets Pre-Mac Verification ===" -ForegroundColor Green
Write-Host ""

$errors = 0
$warnings = 0

# Function to check file exists
function Check-File {
    param($path, $description)
    if (Test-Path $path) {
        Write-Host "✓ $description" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ $description - NOT FOUND" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

# Function to check directory exists
function Check-Directory {
    param($path, $description)
    if (Test-Path $path) {
        Write-Host "✓ $description" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ $description - NOT FOUND" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

# Check Git
Write-Host "=== Git Configuration ===" -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✓ Git installed: $gitVersion" -ForegroundColor Green
    
    $gitStatus = git status --short
    if ($gitStatus) {
        Write-Host "⚠ Uncommitted changes detected:" -ForegroundColor Yellow
        git status --short | ForEach-Object { Write-Host "  $_" }
        $script:warnings++
    } else {
        Write-Host "✓ Working directory clean" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Git not found or not working" -ForegroundColor Red
    $script:errors++
}

Write-Host ""

# Check Project Files
Write-Host "=== Project Files ===" -ForegroundColor Yellow
Check-File "project.yml" "project.yml"
Check-Directory "App" "App directory"
Check-Directory "Core" "Core directory"
Check-Directory "Domain" "Domain directory"
Check-Directory "Network" "Network directory"
Check-Directory "UI" "UI directory"
Check-Directory "Resources" "Resources directory"

Write-Host ""

# Check Swift Files
Write-Host "=== Swift Files ===" -ForegroundColor Yellow
$swiftFiles = Get-ChildItem -Recurse -Filter "*.swift" -ErrorAction SilentlyContinue
if ($swiftFiles) {
    Write-Host "✓ Found $($swiftFiles.Count) Swift files" -ForegroundColor Green
} else {
    Write-Host "✗ No Swift files found" -ForegroundColor Red
    $script:errors++
}

# Check for TODO/FIXME
Write-Host ""
Write-Host "=== Code Quality Checks ===" -ForegroundColor Yellow
$todos = Select-String -Path "*.swift" -Pattern "TODO|FIXME" -Recurse -ErrorAction SilentlyContinue
if ($todos) {
    Write-Host "⚠ Found $($todos.Count) TODO/FIXME comments:" -ForegroundColor Yellow
    $todos | Select-Object -First 10 | ForEach-Object {
        Write-Host "  $($_.Filename):$($_.LineNumber) - $($_.Line.Trim())"
    }
    if ($todos.Count -gt 10) {
        Write-Host "  ... and $($todos.Count - 10) more" -ForegroundColor Yellow
    }
    $script:warnings++
} else {
    Write-Host "✓ No TODO/FIXME comments found" -ForegroundColor Green
}

# Check for C files (should be none)
Write-Host ""
$cFiles = Get-ChildItem -Recurse -Filter "*.c" -ErrorAction SilentlyContinue
$hFiles = Get-ChildItem -Recurse -Filter "*.h" -ErrorAction SilentlyContinue
if ($cFiles -or $hFiles) {
    Write-Host "⚠ Found C files (should be removed for 100% Swift):" -ForegroundColor Yellow
    if ($cFiles) { $cFiles | ForEach-Object { Write-Host "  $($_.FullName)" } }
    if ($hFiles) { $hFiles | ForEach-Object { Write-Host "  $($_.FullName)" } }
    $script:warnings++
} else {
    Write-Host "✓ No C files found (100% Swift confirmed)" -ForegroundColor Green
}

# Check Resources
Write-Host ""
Write-Host "=== Resources ===" -ForegroundColor Yellow
Check-File "Resources/Info.plist" "Info.plist"
if (Test-Path "Resources/Assets.xcassets") {
    Write-Host "✓ Assets.xcassets found" -ForegroundColor Green
} else {
    Write-Host "⚠ Assets.xcassets not found" -ForegroundColor Yellow
    $script:warnings++
}

# Check Documentation
Write-Host ""
Write-Host "=== Documentation ===" -ForegroundColor Yellow
Check-File "README.md" "README.md"
Check-File "APP_SPECIFICATION.md" "APP_SPECIFICATION.md"
Check-File "ARCHITECTURE_BLUEPRINT.md" "ARCHITECTURE_BLUEPRINT.md"

# Check for App Store assets
Write-Host ""
Write-Host "=== App Store Preparation ===" -ForegroundColor Yellow
if (Test-Path "AppStore") {
    Write-Host "✓ AppStore directory found" -ForegroundColor Green
} else {
    Write-Host "⚠ AppStore directory not found (create for screenshots/description)" -ForegroundColor Yellow
    $script:warnings++
}

# Summary
Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Verification Summary:" -ForegroundColor Green
Write-Host "  Errors: $errors" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
Write-Host "  Warnings: $warnings" -ForegroundColor $(if ($warnings -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($errors -eq 0) {
    Write-Host "✅ Ready for Mac day!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Commit all changes: git add . && git commit -m 'Ready for Mac day'"
    Write-Host "2. Push to remote: git push"
    Write-Host "3. Book Mac rental"
    Write-Host "4. Follow MAC_DAY_CHECKLIST.md on Mac day"
} else {
    Write-Host "❌ Please fix errors before Mac day" -ForegroundColor Red
    Write-Host ""
    Write-Host "Fix the errors above, then run this script again."
}

Write-Host "======================================" -ForegroundColor Green

exit $errors
