# LazyCLI Windows Installation Guide

LazyCLI now supports native Windows installation! Choose the method that works best for your environment.

## 🚀 Quick Install (Recommended)

### PowerShell (Recommended)
Open **PowerShell** and run:
```powershell
iwr -useb https://lazycli.xyz/install.ps1 | iex
```

### Command Prompt
If you prefer Command Prompt, download the batch file:
```cmd
curl -o lazy.bat https://lazycli.xyz/lazy.bat
```

## 📋 Installation Methods

### Method 1: PowerShell Installer (Best Experience)
1. Open **PowerShell** (Windows + X → Windows PowerShell)
2. Run the installer:
   ```powershell
   iwr -useb https://lazycli.xyz/install.ps1 | iex
   ```
3. Restart your terminal
4. Test with: `lazy --help`

**Features:**
- ✅ Full LazyCLI functionality (with Git Bash)
- ✅ Automatic PATH configuration
- ✅ Works in PowerShell and Command Prompt
- ✅ Fallback mode without Git Bash

### Method 2: Git Bash (Unix-like Experience)
1. Install [Git for Windows](https://git-scm.com/download/win)
2. Open **Git Bash**
3. Run the Unix installer:
   ```bash
   curl -s https://lazycli.xyz/install.sh | bash
   ```

**Features:**
- ✅ Full Unix-like experience
- ✅ All LazyCLI commands work perfectly
- ✅ Best compatibility with the original script

### Method 3: WSL (Windows Subsystem for Linux)
1. Install WSL: `wsl --install`
2. Open your Linux distribution
3. Run the Unix installer:
   ```bash
   curl -s https://lazycli.xyz/install.sh | bash
   ```

## 🔧 What Gets Installed

The Windows installer creates:
- `%USERPROFILE%\.lazycli\lazy.ps1` - PowerShell wrapper script
- `%USERPROFILE%\.lazycli\lazy.bat` - Command Prompt wrapper
- Adds `%USERPROFILE%\.lazycli` to your PATH

## 🎯 Available Commands

After installation, you can use:

```cmd
lazy --help              # Show help
lazy --version           # Show version
lazy init                # Interactive project selector
lazy node-js init        # Initialize Node.js project
lazy next-js init        # Initialize Next.js project
lazy vite-js init        # Initialize Vite.js project
lazy django init         # Initialize Django project
lazy react-native init   # Initialize React Native project
```

## 🛠️ Troubleshooting

### "lazy is not recognized as an internal or external command"
1. Restart your terminal/PowerShell
2. Check if `%USERPROFILE%\.lazycli` is in your PATH:
   ```cmd
   echo %PATH%
   ```
3. Manually add to PATH if needed:
   ```powershell
   $env:PATH += ";$env:USERPROFILE\.lazycli"
   ```

### "Execution Policy" Error in PowerShell
Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Limited Functionality Warning
If you see "Git Bash not found" warnings:
1. Install [Git for Windows](https://git-scm.com/download/win)
2. Restart your terminal
3. Full functionality will be available

### Permission Denied
1. Run PowerShell as Administrator
2. Or install to a different directory:
   ```powershell
   $env:LAZYCLI_DIR = "C:\Tools\lazycli"
   iwr -useb https://lazycli.xyz/install.ps1 | iex
   ```

## 🔄 Updating LazyCLI

To update to the latest version:
```cmd
lazy upgrade
```

Or reinstall:
```powershell
iwr -useb https://lazycli.xyz/install.ps1 | iex
```

## 🗑️ Uninstalling

To remove LazyCLI:
1. Delete the installation directory:
   ```powershell
   Remove-Item -Recurse -Force "$env:USERPROFILE\.lazycli"
   ```
2. Remove from PATH (optional):
   - Open System Properties → Environment Variables
   - Remove `%USERPROFILE%\.lazycli` from PATH

## 💡 Tips

1. **Best Experience**: Install Git for Windows for full functionality
2. **Multiple Terminals**: Works in PowerShell, Command Prompt, and Git Bash
3. **Development**: Use Git Bash or WSL for the most Unix-like experience
4. **Corporate Networks**: If download fails, try downloading manually from the website

## 🆘 Need Help?

- 📖 [Full Documentation](https://lazycli.xyz/guideline)
- 🐛 [Report Issues](https://github.com/your-repo/issues)
- 💬 [Community Support](https://github.com/your-repo/discussions)

---

**Note**: For the best development experience on Windows, we recommend installing Git for Windows, which provides Git Bash and enables full LazyCLI functionality.