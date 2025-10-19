#!/usr/bin/env bash
# LazyCLI Universal Installer - Works on Linux, macOS, Windows (Git Bash/WSL), and all shells

set -e

# Color codes for better output (disabled on Windows CMD/PowerShell)
if [[ -t 1 ]] && [[ "$TERM" != "dumb" ]] && [[ -z "$NO_COLOR" ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
else
  RED=''
  GREEN=''
  YELLOW=''
  BLUE=''
  NC=''
fi

echo -e "${BLUE}🛠️  Installing LazyCLI...${NC}"

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Linux*)     echo "linux";;
    Darwin*)    echo "macos";;
    CYGWIN*)    echo "windows";;
    MINGW*)     echo "windows";;
    MSYS*)      echo "windows";;
    *)          echo "unknown";;
  esac
}

OS_TYPE=$(detect_os)

# Set platform-specific variables
if [[ "$OS_TYPE" == "windows" ]]; then
  INSTALL_DIR="$HOME/.lazycli"
  LAZY_BINARY="$INSTALL_DIR/lazy.exe"
  DOWNLOAD_URL="https://lazycli.xyz/scripts/lazy-windows.exe"
else
  INSTALL_DIR="$HOME/.lazycli"
  LAZY_BINARY="$INSTALL_DIR/lazy"
  DOWNLOAD_URL="https://lazycli.xyz/scripts/lazy.sh"
fi

# Create install directory
if ! mkdir -p "$INSTALL_DIR" 2>/dev/null; then
  echo -e "${RED}❌ Failed to create install directory: $INSTALL_DIR${NC}"
  if [[ "$OS_TYPE" != "windows" ]]; then
    echo -e "${YELLOW}👉 Try running with sudo:${NC}"
    echo "   curl -fsSL https://lazycli.xyz/install.sh | sudo bash"
  else
    echo -e "${YELLOW}👉 Run your terminal as Administrator${NC}"
  fi
  exit 1
fi

# Download the binary
echo -e "${BLUE}📦 Downloading LazyCLI...${NC}"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$DOWNLOAD_URL" -o "$LAZY_BINARY" || {
    echo -e "${RED}❌ Failed to download LazyCLI.${NC}"
    exit 1
  }
elif command -v wget >/dev/null 2>&1; then
  wget -q "$DOWNLOAD_URL" -O "$LAZY_BINARY" || {
    echo -e "${RED}❌ Failed to download LazyCLI.${NC}"
    exit 1
  }
else
  echo -e "${RED}❌ Neither curl nor wget found. Please install one of them.${NC}"
  exit 1
fi

# Make executable (Unix-like systems)
if [[ "$OS_TYPE" != "windows" ]]; then
  chmod +x "$LAZY_BINARY"
fi

echo -e "${GREEN}✅ Binary downloaded successfully${NC}"

# Detect current shell
detect_shell() {
  local shell_name
  
  # Check SHELL environment variable first
  if [[ -n "$SHELL" ]]; then
    shell_name=$(basename "$SHELL")
  elif [[ -n "$PSModulePath" ]]; then
    # PowerShell detection
    echo "powershell"
    return
  elif [[ -n "$COMSPEC" ]]; then
    # CMD detection
    echo "cmd"
    return
  else
    # Fallback to bash
    shell_name="bash"
  fi
  
  echo "$shell_name"
}

CURRENT_SHELL=$(detect_shell)

# Get profile file based on shell
get_profile_file() {
  local shell="$1"
  local profile_files=()
  
  case "$shell" in
    bash)
      if [[ "$OS_TYPE" == "macos" ]]; then
        profile_files=("$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile")
      else
        profile_files=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
      fi
      ;;
    zsh)
      profile_files=("$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.profile")
      ;;
    fish)
      mkdir -p "$HOME/.config/fish" 2>/dev/null
      profile_files=("$HOME/.config/fish/config.fish")
      ;;
    ksh|mksh)
      profile_files=("$HOME/.kshrc" "$HOME/.profile")
      ;;
    tcsh|csh)
      profile_files=("$HOME/.tcshrc" "$HOME/.cshrc")
      ;;
    dash)
      profile_files=("$HOME/.profile")
      ;;
    powershell|pwsh)
      local ps_profile=$(powershell.exe -NoProfile -Command 'echo $PROFILE' 2>/dev/null | tr -d '\r')
      if [[ -n "$ps_profile" ]]; then
        echo "$ps_profile"
        return
      fi
      profile_files=("$HOME/Documents/PowerShell/Microsoft.PowerShell_profile.ps1")
      ;;
    cmd)
      # For CMD, we'll use registry or provide manual instructions
      echo "MANUAL"
      return
      ;;
    *)
      profile_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
      ;;
  esac
  
  # Return first existing file, or first file in list
  for profile in "${profile_files[@]}"; do
    if [[ -f "$profile" ]]; then
      echo "$profile"
      return
    fi
  done
  
  echo "${profile_files[0]}"
}

# Generate PATH configuration line based on shell
get_path_line() {
  local shell="$1"
  
  case "$shell" in
    fish)
      echo 'set -gx PATH "$HOME/.lazycli" $PATH'
      ;;
    tcsh|csh)
      echo 'setenv PATH "$HOME/.lazycli:$PATH"'
      ;;
    powershell|pwsh)
      echo '$env:Path = "$env:HOME\.lazycli;$env:Path"'
      ;;
    *)
      echo 'export PATH="$HOME/.lazycli:$PATH"'
      ;;
  esac
}

# Add to PATH configuration
configure_path() {
  local profile_file="$1"
  local shell="$2"
  local path_line
  
  if [[ "$profile_file" == "MANUAL" ]]; then
    echo -e "${YELLOW}⚠️  CMD detected. Please manually add to PATH:${NC}"
    echo "   setx PATH \"%PATH%;%USERPROFILE%\\.lazycli\""
    return 1
  fi
  
  path_line=$(get_path_line "$shell")
  
  # Check if already configured
  if [[ -f "$profile_file" ]] && grep -q ".lazycli" "$profile_file" 2>/dev/null; then
    echo -e "${BLUE}📎 PATH already configured in $profile_file${NC}"
    return 0
  fi
  
  # Create profile file if it doesn't exist
  if [[ ! -f "$profile_file" ]]; then
    mkdir -p "$(dirname "$profile_file")" 2>/dev/null || true
    touch "$profile_file" 2>/dev/null || {
      echo -e "${YELLOW}⚠️  Could not create profile file: $profile_file${NC}"
      return 1
    }
  fi
  
  # Add PATH configuration
  echo "" >> "$profile_file"
  echo "# LazyCLI" >> "$profile_file"
  echo "$path_line" >> "$profile_file"
  
  echo -e "${GREEN}📎 Updated $profile_file${NC}"
  return 0
}

# Main configuration
PROFILE_FILE=$(get_profile_file "$CURRENT_SHELL")

if configure_path "$PROFILE_FILE" "$CURRENT_SHELL"; then
  echo -e "${GREEN}✅ PATH configured successfully${NC}"
else
  echo -e "${YELLOW}📝 Please manually add to your PATH:${NC}"
  echo "   $INSTALL_DIR"
fi

# Update current session PATH (for POSIX shells)
if [[ "$CURRENT_SHELL" != "powershell" ]] && [[ "$CURRENT_SHELL" != "cmd" ]]; then
  export PATH="$INSTALL_DIR:$PATH"
fi

# Final verification
echo ""
echo -e "${BLUE}🔍 Verifying installation...${NC}"

if command -v lazy >/dev/null 2>&1; then
  echo -e "${GREEN}✅ LazyCLI installed successfully!${NC}"
  echo -e "${GREEN}🚀 Run 'lazy --help' to get started${NC}"
else
  echo -e "${YELLOW}✅ LazyCLI installed!${NC}"
  echo -e "${YELLOW}⚠️  Please restart your terminal or run:${NC}"
  
  case "$CURRENT_SHELL" in
    fish)
      echo "   source ~/.config/fish/config.fish"
      ;;
    tcsh|csh)
      echo "   source $PROFILE_FILE"
      ;;
    powershell|pwsh)
      echo "   . \$PROFILE"
      echo "   (or restart your PowerShell terminal)"
      ;;
    *)
      echo "   source $PROFILE_FILE"
      ;;
  esac
  
  echo ""
  echo -e "${GREEN}Then run 'lazy --help' to get started! 😎${NC}"
fi

# Display additional tips
echo ""
echo -e "${BLUE}💡 Tips:${NC}"
echo "   • Installation directory: $INSTALL_DIR"
echo "   • Profile updated: $PROFILE_FILE"
if [[ "$OS_TYPE" == "windows" ]]; then
  echo "   • You may need to restart your terminal"
fi

exit 0