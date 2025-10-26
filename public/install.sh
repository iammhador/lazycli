#!/bin/bash

# Detect Windows and redirect to PowerShell installer
detect_windows() {
  # First, check if running in Unix-like environment on Windows (Git Bash, Cygwin, WSL)
  if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ -n "$WSL_DISTRO_NAME" ]]; then
    return 1  # Unix-like environment on Windows - continue with Unix installer
  fi
  
  # Check if we have a proper SHELL environment (indicates Unix-like environment)
  if [[ -n "$SHELL" ]] && [[ "$SHELL" =~ (bash|zsh|fish|sh)$ ]]; then
    return 1  # Unix-like shell detected
  fi
  
  # Check for native Windows PowerShell/CMD environment
  if [[ -n "$WINDIR" ]] || [[ -n "$SYSTEMROOT" ]] || [[ "$OS" == "Windows_NT" ]]; then
    # Additional check: if powershell.exe is available but no proper SHELL, likely native Windows
    if command -v powershell.exe >/dev/null 2>&1 && [[ -z "$SHELL" ]]; then
      return 0  # Native Windows detected
    fi
    # If we have Windows env vars but also a proper shell, likely Git Bash/WSL
    return 1
  fi
  
  return 1  # Default to Unix-like
}

# Check if running on native Windows
if detect_windows; then
  echo "🪟 Windows detected! Redirecting to PowerShell installer..."
  echo ""
  echo "Please run this command in PowerShell instead:"
  echo "  iwr -useb https://lazycli.xyz/install.ps1 | iex"
  echo ""
  echo "Or download and run manually:"
  echo "  https://lazycli.xyz/install.ps1"
  echo ""
  echo "If you're using Git Bash or WSL, you can continue with this installer."
  read -p "Continue with Unix installer anyway? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
  fi
fi

echo "🛠️ Installing LazyCLI..."
INSTALL_DIR="$HOME/.lazycli"
LAZY_BINARY="$INSTALL_DIR/lazy"

# Ensure install dir is writable:
if ! mkdir -p "$INSTALL_DIR" 2>/dev/null; then
  echo "❌ Failed to create install directory: $INSTALL_DIR"
  echo "👉 Try running this command instead:"
  echo "   curl -s https://lazycli.xyz/install.sh | sudo HOME=$HOME bash"
  exit 1
fi

# Download the latest CLI script:
curl -fsSL https://lazycli.xyz/scripts/lazy.sh -o "$LAZY_BINARY" || {
  echo "❌ Failed to download LazyCLI."
  exit 1
}

# Make it executable:
chmod +x "$LAZY_BINARY"

# Detect current shell and determine profile file
detect_shell_profile() {
  local current_shell
  local profile_files=()
  
  # Get current shell (remove path, keep only shell name)
  current_shell=$(basename "$SHELL" 2>/dev/null || echo "bash")
  
  case "$current_shell" in
    bash)
      profile_files=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
      ;;
    zsh)
      profile_files=("$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.profile")
      ;;
    fish)
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
    *)
      # Fallback: try common profile files
      profile_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
      echo "⚠️  Unknown shell: $current_shell. Trying common profile files..."
      ;;
  esac
  
  # Find the first existing profile file, or create the primary one
  for profile in "${profile_files[@]}"; do
    if [[ -f "$profile" ]]; then
      echo "$profile"
      return 0
    fi
  done
  
  # If no profile file exists, create the primary one
  echo "${profile_files[0]}"
}

# Function to add PATH export based on shell type
add_to_path() {
  local profile_file="$1"
  local path_export_line
  
  # Determine the correct syntax based on shell
  local shell_name=$(basename "$SHELL" 2>/dev/null || echo "bash")
  
  case "$shell_name" in
    fish)
      # Fish shell uses different syntax
      path_export_line='set -gx PATH "$HOME/.lazycli" $PATH'
      ;;
    tcsh|csh)
      # C shell family uses setenv
      path_export_line='setenv PATH "$HOME/.lazycli:$PATH"'
      ;;
    *)
      # POSIX-compatible shells (bash, zsh, dash, ksh, etc.)
      path_export_line='export PATH="$HOME/.lazycli:$PATH"'
      ;;
  esac
  
  # Check if PATH is already configured
  if [[ -f "$profile_file" ]] && grep -q "$HOME/.lazycli" "$profile_file" 2>/dev/null; then
    echo "📎 PATH already configured in $profile_file"
    return 0
  fi
  
  # Add the export line
  echo "$path_export_line" >> "$profile_file"
  echo "📎 Updated $profile_file with LazyCLI path."
  
  # For fish shell, also update the current session differently
  if [[ "$shell_name" == "fish" ]]; then
    # Fish users would need to restart their shell or source the config
    echo "🐟 Fish shell detected. Please restart your terminal or run: source ~/.config/fish/config.fish"
  fi
}

# Detect and configure profile
PROFILE_FILE=$(detect_shell_profile)

if [[ -n "$PROFILE_FILE" ]]; then
  add_to_path "$PROFILE_FILE"
else
  echo "⚠️  Could not determine appropriate profile file."
  echo "📝 Please manually add this line to your shell's profile file:"
  echo "   export PATH=\"\$HOME/.lazycli:\$PATH\""
fi

# Apply to current session (works for POSIX-compatible shells)
export PATH="$HOME/.lazycli:$PATH"

# Final check
if command -v lazy >/dev/null 2>&1; then
  echo "✅ LazyCLI installed successfully! Run 'lazy --help' to begin. 😎"
else
  echo "✅ LazyCLI installed! Please restart your terminal or run:"
  echo "   source $PROFILE_FILE"
  echo "   Then run 'lazy --help' to begin. 😎"
fi

# Display shell-specific instructions if needed
shell_name=$(basename "$SHELL" 2>/dev/null || echo "bash")
case "$shell_name" in
  fish)
    echo ""
    echo "🐟 Fish shell users: If the command isn't available immediately,"
    echo "   please restart your terminal or run: source ~/.config/fish/config.fish"
    ;;
  tcsh|csh)
    echo ""
    echo "🐚 C shell users: If the command isn't available immediately,"
    echo "   please restart your terminal or run: source $PROFILE_FILE"
    ;;
esac
