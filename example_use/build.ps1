# Lite Simple UI Example - Build Script
# Usage:
#   .\build.ps1 dev           # Development mode with hot reload
#   .\build.ps1 apk           # Build Android APK
#   .\build.ps1 windows       # Build Windows app
#   .\build.ps1 web           # Build Web app
#   .\build.ps1 clean         # Clean build cache
#   .\build.ps1 deps          # Get dependencies
#   .\build.ps1 test          # Run tests
#   .\build.ps1 help          # Show help

param(
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$Args = @()
)

$Target = if ($Args.Count -gt 0) { $Args[0] } else { "help" }

$ErrorActionPreference = "Stop"

# Color output functions
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error- { Write-Host $args -ForegroundColor Red }
function Write-Warn- { Write-Host $args -ForegroundColor Yellow }

# Check Flutter installation
function Test-Flutter {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Error- "Error: Flutter not found. Please install Flutter and add it to PATH"
        exit 1
    }
    Write-Info "Flutter version:"
    flutter --version
}

# Development mode
function Invoke-Dev {
    Write-Info "Starting development mode (hot reload)..."
    flutter run
}

# Build Android APK
function Invoke-Apk {
    Write-Info "Building Android APK..."
    flutter build apk --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: APK built successfully!"
        Write-Info "Output: build\app\outputs\flutter-apk\app-release.apk"
    } else {
        Write-Error- "FAILED: APK build failed"
        exit 1
    }
}

# Build Android App Bundle
function Invoke-Aab {
    Write-Info "Building Android App Bundle..."
    flutter build appbundle --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: App Bundle built successfully!"
        Write-Info "Output: build\app\outputs\bundle\release\app-release.aab"
    } else {
        Write-Error- "FAILED: App Bundle build failed"
        exit 1
    }
}

# Build Windows app
function Invoke-Windows {
    Write-Info "Building Windows app..."
    flutter build windows --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: Windows app built successfully!"
        Write-Info "Output: build\windows\x64\runner\Release\"
    } else {
        Write-Error- "FAILED: Windows app build failed"
        exit 1
    }
}

# Build Web app
function Invoke-Web {
    Write-Info "Building Web app..."
    flutter build web --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: Web app built successfully!"
        Write-Info "Output: build\web\"
    } else {
        Write-Error- "FAILED: Web app build failed"
        exit 1
    }
}

# Build iOS app
function Invoke-Ios {
    Write-Warn- "iOS build requires macOS with Xcode"
    Write-Info "Building iOS app..."
    flutter build ios --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: iOS app built successfully!"
    } else {
        Write-Error- "FAILED: iOS app build failed"
        exit 1
    }
}

# Build macOS app
function Invoke-Macos {
    Write-Warn- "macOS build requires macOS with Xcode"
    Write-Info "Building macOS app..."
    flutter build macos --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: macOS app built successfully!"
    } else {
        Write-Error- "FAILED: macOS app build failed"
        exit 1
    }
}

# Build Linux app
function Invoke-Linux {
    Write-Info "Building Linux app..."
    flutter build linux --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: Linux app built successfully!"
    } else {
        Write-Error- "FAILED: Linux app build failed"
        exit 1
    }
}

# Clean build cache
function Invoke-Clean {
    Write-Info "Cleaning build cache..."
    flutter clean
    
    Write-Info "Removing pubspec.lock..."
    if (Test-Path "pubspec.lock") {
        Remove-Item "pubspec.lock"
    }
    
    Write-Success "SUCCESS: Clean completed!"
}

# Get dependencies
function Invoke-Deps {
    Write-Info "Getting Flutter dependencies..."
    flutter pub get
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: Dependencies installed!"
    } else {
        Write-Error- "FAILED: Dependencies install failed"
        exit 1
    }
}

# Run tests
function Invoke-Test {
    Write-Info "Running tests..."
    flutter test
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "SUCCESS: Tests passed!"
    } else {
        Write-Error- "FAILED: Tests failed"
        exit 1
    }
}

# Show help
function Show-Help {
    Write-Host @"
Lite Simple UI Example - Build Tool

Usage: .\build.ps1 <command>

Available Commands:
  dev              Development mode (hot reload)
  apk              Build Android APK
  aab              Build Android App Bundle
  windows          Build Windows app
  web              Build Web app
  ios              Build iOS app (requires macOS)
  macos            Build macOS app (requires macOS)
  linux            Build Linux app
  clean            Clean build cache
  deps             Get dependencies
  test             Run tests
  help             Show this help message

Examples:
  .\build.ps1 dev                    Start development mode
  .\build.ps1 apk                    Build APK
  .\build.ps1 clean; .\build.ps1 deps  Clean and reinstall dependencies

====================================================
Tips for easier usage:

Method 1: Install GNU Make for Windows
  1. Download from: https://chocolatey.org/packages/make
  2. Run: choco install make
  3. Then use: make dev

Method 2: Create PowerShell alias
  Add this function to your PowerShell profile:
  
  function make { .\build.ps1 \$args }
  
  Then you can use: make dev
  
  To find your profile path, run: echo \$PROFILE

"@ -ForegroundColor Green
}

# Main logic
Write-Info "========================================"
Test-Flutter

switch ($Target) {
    "dev" { Invoke-Dev }
    "apk" { Invoke-Apk }
    "aab" { Invoke-Aab }
    "windows" { Invoke-Windows }
    "web" { Invoke-Web }
    "ios" { Invoke-Ios }
    "macos" { Invoke-Macos }
    "linux" { Invoke-Linux }
    "clean" { Invoke-Clean }
    "deps" { Invoke-Deps }
    "test" { Invoke-Test }
    "help" { Show-Help }
    default { 
        Write-Error- "Unknown command: $Target"
        Show-Help
        exit 1
    }
}

Write-Info "========================================"
