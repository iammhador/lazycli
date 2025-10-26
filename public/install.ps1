# PowerShell installer for LazyCLI on Windows
Write-Host "🛠️ Installing LazyCLI for Windows..." -ForegroundColor Cyan

# Set installation directory
$InstallDir = "$env:USERPROFILE\.lazycli"
$LazyScript = "$InstallDir\lazy.sh"
$LazyBinary = "$InstallDir\lazy.ps1"
$LazyBat = "$InstallDir\lazy.bat"

# Create install directory
try {
    if (!(Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
    Write-Host "📁 Created installation directory: $InstallDir" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create install directory: $InstallDir" -ForegroundColor Red
    Write-Host "👉 Try running PowerShell as Administrator" -ForegroundColor Yellow
    exit 1
}

# Download the latest CLI script
try {
    Write-Host "⬇️ Downloading LazyCLI script..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://lazycli.xyz/scripts/lazy.sh" -OutFile $LazyScript -UseBasicParsing
    Write-Host "✅ Downloaded LazyCLI script" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to download LazyCLI script" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create a batch wrapper for Command Prompt compatibility
$BatchContent = @"
@echo off
powershell.exe -ExecutionPolicy Bypass -File "\"%~dp0lazy.ps1\"" %*
"@

try {
    Set-Content -Path $LazyBat -Value $BatchContent -Encoding ASCII
    Write-Host "✅ Created batch wrapper: lazy.bat" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create batch wrapper" -ForegroundColor Red
    exit 1
}

# Create PowerShell wrapper script
$PowerShellContent = @"
# LazyCLI PowerShell Wrapper
param([Parameter(ValueFromRemainingArguments=`$true)][string[]]`$Arguments)

# Convert PowerShell to Bash-compatible environment
`$env:HOME = `$env:USERPROFILE
`$env:SHELL = "powershell"

# Execute the original bash script using Git Bash or WSL if available
`$GitBashPath = @(
    "`${env:ProgramFiles}\Git\bin\bash.exe",
    "`${env:ProgramFiles(x86)}\Git\bin\bash.exe",
    "`$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
) | Where-Object { Test-Path `$_ } | Select-Object -First 1

if (`$GitBashPath) {
    # Use Git Bash to execute the script
    `$LazyScript = "`$PSScriptRoot\lazy.sh"
    `$LazyScriptUnix = `$LazyScript -replace '\\', '/'
    `$LazyScriptUnix = `$LazyScriptUnix -replace '^([A-Z]):', '/`$1'.ToLower()
    `$LazyScriptUnix = `$LazyScriptUnix -replace ' ', '\ '
    & `$GitBashPath -c "`"`$LazyScriptUnix`" `$(`$Arguments -join ' ')"')"
} else {
    # Fallback: Basic PowerShell implementation
    Write-Host "⚠️ Git Bash not found. Limited functionality available." -ForegroundColor Yellow
    Write-Host "📥 Please install Git for Windows for full LazyCLI support." -ForegroundColor Yellow
    Write-Host "🔗 Download: https://git-scm.com/download/win" -ForegroundColor Cyan
    
    if (`$Arguments.Count -eq 0 -or `$Arguments[0] -eq "--help" -or `$Arguments[0] -eq "help") {
        Write-Host ""
        Write-Host "LazyCLI - Project Setup Automation Tool" -ForegroundColor Green
        Write-Host ""
        Write-Host "Available commands:" -ForegroundColor Yellow
        Write-Host "  lazy node-js init    - Initialize Node.js project"
        Write-Host "  lazy next-js init    - Initialize Next.js project"
        Write-Host "  lazy vite-js init    - Initialize Vite.js project"
        Write-Host "  lazy django init     - Initialize Django project"
        Write-Host "  lazy react-native init - Initialize React Native project"
        Write-Host "  lazy init            - Interactive project selector"
        Write-Host "  lazy --help          - Show this help"
        Write-Host "  lazy --version       - Show version"
        Write-Host ""
        Write-Host "For full functionality, please install Git for Windows." -ForegroundColor Cyan
    } elseif (`$Arguments[0] -eq "--version" -or `$Arguments[0] -eq "version" -or `$Arguments[0] -eq "-v") {
        Write-Host "LazyCLI version 1.0.4"
    } else {
        Write-Host "❌ Command not supported in PowerShell-only mode." -ForegroundColor Red
        Write-Host "📥 Please install Git for Windows for full support." -ForegroundColor Yellow
    }
}
"@

try {
    Set-Content -Path $LazyBinary -Value $PowerShellContent -Encoding UTF8
    Write-Host "✅ Created PowerShell wrapper script" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create PowerShell wrapper" -ForegroundColor Red
    exit 1
}

# Add to PATH
$CurrentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($CurrentPath -notlike "*$InstallDir*") {
    try {
        [Environment]::SetEnvironmentVariable("PATH", "$InstallDir;$CurrentPath", "User")
        Write-Host "📎 Added LazyCLI to user PATH" -ForegroundColor Green
        
        # Update current session PATH
        $env:PATH = "$InstallDir;$env:PATH"
        
    } catch {
        Write-Host "⚠️ Could not automatically add to PATH" -ForegroundColor Yellow
        Write-Host "📝 Please manually add this directory to your PATH:" -ForegroundColor Yellow
        Write-Host "   $InstallDir" -ForegroundColor White
    }
} else {
    Write-Host "📎 LazyCLI already in PATH" -ForegroundColor Green
}

# Final verification
Write-Host ""
Write-Host "✅ LazyCLI installed successfully! 🎉" -ForegroundColor Green
Write-Host "🔄 Please restart your terminal or open a new one" -ForegroundColor Yellow
Write-Host "🚀 Then run 'lazy --help' to get started" -ForegroundColor Cyan

Write-Host ""
Write-Host "💡 For best experience, install Git for Windows:" -ForegroundColor Blue
Write-Host "   https://git-scm.com/download/win" -ForegroundColor Cyan