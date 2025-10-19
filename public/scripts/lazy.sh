#!/bin/bash

VERSION="1.0.4"

show_help() {
  cat << EOF
LazyCLI – Automate your dev flow like a lazy pro 💤

Usage:
  lazy [command] [subcommand]

Examples:
  lazy github init
      Initialize a new Git repository in the current directory.

  lazy github clone <repo-url>
      Clone a GitHub repository and auto-detect the tech stack for setup.

  lazy github push "<commit-message>"
      Stage all changes, commit with the given message, and push to the current branch.

  lazy github pr <base-branch> "<commit-message>"
      Pull latest changes from the base branch, install dependencies, commit local changes,
      push to current branch, and create a GitHub pull request.

  lazy github pull <base-branch> "<pr-title>"
      Create a simple pull request from current branch to the specified base branch.

  lazy node-js init
      Initialize a Node.js project with init -y and optional boilerplate package installation.

  lazy next-js init
      Scaffold a new Next.js application with recommended defaults and optional packages.

  lazy vite-js init
      Create a new Vite project, select framework, and optionally install common packages.

  lazy react-native init
      Scaffold a new React Native application with Expo or React Native CLI setup.
      
  lazy django init <project_name>
      Create a new Django project with static, templates, and media directories setup.

  lazy --version | -v
      Show current LazyCLI version.

  lazy --help | help
      Show this help message.

Available Commands:

  github        Manage GitHub repositories:
                - init       Initialize a new Git repo
                - clone      Clone a repo and optionally setup project
                - push       Commit and push changes with message
                - pull       Create a simple pull request from current branch
                - pr         Pull latest, build, commit, push, and create pull request

  node-js       Setup Node.js projects:
                - init       Initialize Node.js project with optional boilerplate

  next-js       Next.js project scaffolding:
                - init       Create Next.js app with TypeScript, Tailwind, ESLint defaults

  vite-js       Vite project scaffolding:
                - init       Create a Vite project with framework selection and optional packages

  react-native  Mobile app development with React Native:
                - init       Create React Native app with Expo or CLI, navigation, and essential packages
                  
  django        Django project setup:
                - init <project_name>  Create Django project with static, templates, and media setup

For more details on each command, run:
  lazy [command] --help

EOF
}


# Helper function to detect package manager
detect_package_manager() {
  if command -v bun &> /dev/null; then
    PKG_MANAGER="bun"
  elif command -v pnpm &> /dev/null; then
    PKG_MANAGER="pnpm"
  elif command -v yarn &> /dev/null; then
    PKG_MANAGER="yarn"
  else
    PKG_MANAGER="npm"
  fi
}

github_init() {
  echo "🛠️ Initializing new Git repository..."

  if [ -d ".git" ]; then
    echo "⚠️ Git repository already initialized in this directory."
    exit 1
  fi

  git init

  echo "✅ Git repository initialized successfully!"
}

github_clone() {
  repo="$1"
  tech="$2"

  if [[ -z "$repo" ]]; then
    echo "❌ Repo URL is required."
    echo "👉 Usage: lazy github clone <repo-url> [tech]"
    exit 1
  fi

  echo "🔗 Cloning $repo ..."
  git clone "$repo" || { echo "❌ Clone failed."; exit 1; }

  dir_name=$(basename "$repo" .git)
  cd "$dir_name" || exit 1

  echo "📁 Entered directory: $dir_name"

  if [[ -f package.json ]]; then
    echo "📦 Installing dependencies..."
    
    # Use the detect_package_manager function
    detect_package_manager
    
    echo "🔧 Using $PKG_MANAGER..."
    if [[ "$PKG_MANAGER" == "bun" ]]; then
      bun install
    elif [[ "$PKG_MANAGER" == "pnpm" ]]; then
      pnpm install
    elif [[ "$PKG_MANAGER" == "yarn" ]]; then
      yarn
    else
      npm install
    fi

    # Check if build script exists
    if grep -q '"build"' package.json; then
      echo "🏗️ Build script found. Building the project..."
      if [[ "$PKG_MANAGER" == "bun" ]]; then
        bun run build
      elif [[ "$PKG_MANAGER" == "pnpm" ]]; then
        pnpm run build
      elif [[ "$PKG_MANAGER" == "yarn" ]]; then
        yarn build
      else
        npm run build
      fi
    else
      echo "ℹ️ No build script found; skipping build."
    fi
  else
    echo "⚠️ No package.json found; skipping dependency install & build."
  fi

  if command -v code &> /dev/null; then
    echo "🚀 Opening project in VS Code..."
    code .
  else
    echo "💡 VS Code not found. You can manually open the project folder."
  fi

  echo "✅ Clone setup complete! Don't forget to commit and push your changes."
}

github_push() {
  echo "📦 Staging changes..."
  git add .

  msg="$1"
  if [[ -z "$msg" ]]; then
    echo "⚠️ Commit message is required. Example:"
    echo "   lazy github push \"Your message here\""
    exit 1
  fi

  echo "📝 Committing changes..."
  if ! git commit -m "$msg"; then
    echo "❌ Commit failed. Nothing to commit or error occurred."
    exit 1
  fi

  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [[ -z "$BRANCH" ]]; then
    echo "❌ Could not detect branch. Are you in a git repo?"
    exit 1
  fi

  echo "🚀 Pushing to origin/$BRANCH..."
  if ! git push origin "$BRANCH"; then
    echo "❌ Push failed. Please check your network or branch."
    exit 1
  fi

  echo "✅ Changes pushed to origin/$BRANCH 🎉"
}

# Create a simple pull request from current branch to target branch
# Args: $1 = base branch, $2 = pull request title
github_create_pull() {
  local BASE_BRANCH="$1"
  local PR_TITLE="$2"

  if [[ -z "$BASE_BRANCH" || -z "$PR_TITLE" ]]; then
    echo "❌ Usage: lazy github pull <base-branch> \"<pr-title>\""
    return 1
  fi

  # Detect current branch
  local CURRENT_BRANCH
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "❌ Not inside a git repository."
    return 1
  fi

  if [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
    echo "❌ Cannot create PR from $BASE_BRANCH to itself. Please switch to a feature branch."
    return 1
  fi

  echo "🔁 Creating pull request: $CURRENT_BRANCH → $BASE_BRANCH"
  echo "📝 Title: $PR_TITLE"

  if ! gh pr create --base "$BASE_BRANCH" --head "$CURRENT_BRANCH" --title "$PR_TITLE" --body "$PR_TITLE"; then
    echo "❌ Pull request creation failed."
    echo "⚠️ GitHub CLI (gh) is not installed or not found in PATH."
    echo "👉 To enable automatic pull request creation:"
    echo "   1. Download and install GitHub CLI: https://cli.github.com/"
    echo "   2. If already installed, add it to your PATH to your gitbash:"
    echo "      export PATH=\"/c/Program Files/GitHub CLI:\$PATH\""
    return 1
  fi

  echo "✅ Pull request created successfully! 🎉"
}

# Create a pull request workflow: pull latest changes, install dependencies, commit, push, and create PR
# Automatically detects project type and runs appropriate build/install commands
# Args: $1 = base branch, $2 = commit message
github_create_pr() {
  local BASE_BRANCH="$1"
  local COMMIT_MSG="$2"

  if [[ -z "$BASE_BRANCH" || -z "$COMMIT_MSG" ]]; then
    echo "❌ Usage: lazy github pull <base-branch> \"<commit-message>\" [tech]"
    exit 1
  fi

  # Detect current branch
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  if [[ -z "$CURRENT_BRANCH" ]]; then
    echo "❌ Not in a git repo."
    exit 1
  fi

  echo "📥 Pulling latest from $BASE_BRANCH..."
  git pull origin "$BASE_BRANCH" || { echo "❌ Pull failed"; exit 1; }

  # Install dependencies based on package manager
  if [[ -f package.json ]]; then
    echo "📦 Installing dependencies..."
    if command -v npm &> /dev/null; then
      echo "🔧 Using npm..."
      npm run build
    elif command -v yarn &> /dev/null; then
      echo "🔧 Using yarn..."
      yarn
    elif command -v pnpm &> /dev/null; then
      echo "🔧 Using pnpm..."
      pnpm install
    elif command -v bun &> /dev/null; then
      echo "🔧 Using bun..."
      bun install
    else
      echo "⚠️ No supported package manager found."
    fi
  else
    echo "⚠️ No package.json found. Skipping install step."
  fi

  # Stage and commit
  echo "📦 Staging changes..."
  git add .

  echo "📝 Committing with message: $COMMIT_MSG"
  git commit -m "$COMMIT_MSG" || echo "⚠️ Nothing to commit"

  echo "🚀 Pushing to origin/$CURRENT_BRANCH"
  git push origin "$CURRENT_BRANCH" || { echo "❌ Push failed"; exit 1; }

  # Create pull request
  echo "🔁 Creating pull request: $CURRENT_BRANCH → $BASE_BRANCH"
  if ! gh pr create --base "$BASE_BRANCH" --head "$CURRENT_BRANCH" --title "$COMMIT_MSG" --body "$COMMIT_MSG"; then
    echo "❌ Pull request creation failed."
    echo "⚠️ GitHub CLI (gh) is not installed or not found in PATH."
    echo "👉 To enable automatic pull request creation:"
    echo "   1. Download and install GitHub CLI: https://cli.github.com/"
    echo "   2. If already installed, add it to your PATH to your gitbash:"
    echo "      export PATH=\"/c/Program Files/GitHub CLI:\$PATH\""
    return 1
  fi

  echo "✅ PR created successfully! 🎉"
}

# Create a new Next.js application with TypeScript, Tailwind, and optional packages
# Uses create-next-app with predefined settings and interactive package selection
# Supports: zod, bcrypt, js-cookie, swr, lucide-react, react-hot-toast, shadcn-ui
next_js_create() {
  echo "🛠️ Creating Next.js app..."

  # Ask for project name
  read -p "📦 Enter project name (no spaces): " project_name
  if [[ -z "$project_name" ]]; then
    echo "❌ Project name cannot be empty."
    return 1
  fi

  echo ""
  echo "⚙️ Next.js will use default options:"
  echo "- TypeScript: ✅"
  echo "- ESLint: ✅"
  echo "- Tailwind CSS: ✅"
  echo "- App Router: ✅"
  echo "- src/: ❌"
  echo "- Import alias: ✅"
  echo "- Turbopack: ✅"
  echo ""
  read -p "✅ Continue with these defaults? (1/0): " confirm_next

  # Default configuration
  if [[ "$confirm_next" == "1" ]]; then
    use_src=0
    use_tailwind=1
    use_eslint=1
    use_ts=1
    use_app=1
    use_alias=1
    use_turbo=1
  else
    echo ""
    echo "⚙️ Manual configuration mode:"
    read -p "📂 Use src/ directory? (1/0): " use_src
    read -p "✨ Use Tailwind CSS? (1/0): " use_tailwind
    read -p "🧹 Use ESLint? (1/0): " use_eslint
    read -p "⚙️ Use TypeScript? (1/0): " use_ts
    read -p "🧪 Use App Router? (1/0): " use_app
    read -p "📌 Use import alias '@/*'? (1/0): " use_alias
    read -p "🚀 Use Turbopack for dev? (1/0): " use_turbo
  fi

  echo ""
  echo "🧠 LazyCLI Smart Stack Setup"
  echo "   (Enter 1 = Yes, 0 = No, -1 = Cancel Setup)"

  # Mini helper
  prompt_or_exit() {
    local prompt_text=$1 answer
    while true; do
      read -p "$prompt_text (1/0/-1): " answer
      case "$answer" in
        1|0) echo "$answer"; return ;;
        -1) echo "🚫 Setup cancelled."; return 255 ;;
        *) echo "⚠️ Please enter 1, 0, or -1." ;;
      esac
    done
  }

  # Optional packages
  for pkg in \
    "zod:➕ Install zod?" \
    "bcrypt:🔐 Install bcrypt?" \
    "js-cookie:🍪 Install js-cookie?" \
    "swr:🔁 Install swr?" \
    "lucide-react:✨ Install lucide-react icons?" \
    "react-hot-toast:🔥 Install react-hot-toast?" \
    "shadcn-ui:🎨 Setup shadcn-ui?"
  do
    key=${pkg%%:*}
    text=${pkg#*:}
    answer=$(prompt_or_exit "$text") || return 1
    eval "ans_${key//-/_}=$answer"
  done

  # Construct Next.js CLI command
  echo ""
  echo "🚀 Creating Next.js project..."

  cmd="npx create-next-app@latest \"$project_name\" --yes"
  [[ "$use_ts" == "1" ]] && cmd+=" --typescript" || cmd+=" --no-typescript"
  [[ "$use_eslint" == "1" ]] && cmd+=" --eslint" || cmd+=" --no-eslint"
  [[ "$use_tailwind" == "1" ]] && cmd+=" --tailwind" || cmd+=" --no-tailwind"
  [[ "$use_app" == "1" ]] && cmd+=" --app" || cmd+=" --no-app"
  [[ "$use_src" == "1" ]] && cmd+=" --src-dir" || cmd+=" --no-src-dir"
  [[ "$use_alias" == "1" ]] && cmd+=' --import-alias "@/*"' || cmd+=" --no-import-alias"
  [[ "$use_turbo" == "1" ]] && cmd+=" --turbo" || cmd+=" --no-turbo"

  eval "$cmd" || { echo "❌ Failed to create project."; return 1; }

  cd "$project_name" || return 1

  # Detect package manager (fallback npm)
  if command -v bun &>/dev/null; then
    PKG_MANAGER="bun"
  elif command -v pnpm &>/dev/null; then
    PKG_MANAGER="pnpm"
  elif command -v yarn &>/dev/null; then
    PKG_MANAGER="yarn"
  else
    PKG_MANAGER="npm"
  fi

  # Build package list
  packages=()
  [[ "$ans_zod" == "1" ]] && packages+=("zod")
  [[ "$ans_bcrypt" == "1" ]] && packages+=("bcrypt")
  [[ "$ans_js_cookie" == "1" ]] && packages+=("js-cookie")
  [[ "$ans_swr" == "1" ]] && packages+=("swr")
  [[ "$ans_lucide_react" == "1" ]] && packages+=("lucide-react")
  [[ "$ans_react_hot_toast" == "1" ]] && packages+=("react-hot-toast")

  if [[ ${#packages[@]} -gt 0 ]]; then
    echo ""
    echo "📦 Installing: ${packages[*]}"
    if [[ "$PKG_MANAGER" == "npm" ]]; then
      npm install "${packages[@]}"
    else
      $PKG_MANAGER add "${packages[@]}"
    fi
  fi

  # Setup shadcn-ui
  if [[ "$ans_shadcn_ui" == "1" ]]; then
    echo ""
    echo "🎨 Initializing shadcn-ui..."
    if [[ "$PKG_MANAGER" == "npm" ]]; then
      npx shadcn-ui@latest init
    else
      $PKG_MANAGER dlx shadcn-ui@latest init || echo "⚠️ shadcn-ui failed to init."
    fi
  fi

  echo ""
  echo "✅ Your Next.js app is ready!"
  echo "➡️ Run: cd \"$project_name\" && $PKG_MANAGER run dev"
}


# Vite.js App Creator 
vite_js_create() {
  echo "🛠️ Creating Vite app for you..."

  # --- Project name ---
  read -p "📦 Enter project name (no spaces): " project_name
  if [ -z "$project_name" ]; then
    echo "❌ Project name cannot be empty."
    return 1
  fi

  # --- Framework selection ---
  echo "✨ Choose a framework:"
  echo "1) Vanilla"
  echo "2) React"
  echo "3) Vue"
  echo "4) Svelte"
  read -p "🔧 Enter choice [1-4]: " choice

  case $choice in
    1) framework="vanilla" ;;
    2) framework="react" ;;
    3) framework="vue" ;;
    4) framework="svelte" ;;
    *) echo "❌ Invalid choice."; return 1 ;;
  esac

  # --- Detect package manager ---
  detect_package_manager
  echo "📦 Using package manager: $PKG_MANAGER"

  echo
  echo "🧠 LazyCLI Smart Stack Setup"
  echo "   1 = Yes, 0 = No, -1 = Skip all remaining prompts"

  # --- Ask Package Function ---
  ask_package() {
    local label="$1"
    local var_name="$2"
    local input
    while true; do
      read -p "➕ Install $label? (1/0/-1): " input
      case $input in
        1|0)
          eval "$var_name=$input"
          return 0
          ;;
        -1)
          echo "🚫 Skipping all further package prompts."
          SKIP_ALL=true
          return 1
          ;;
        *) echo "Please enter 1, 0 or -1." ;;
      esac
    done
  }

  SKIP_ALL=false

  # --- Interactive dependency choices ---
  [[ "$SKIP_ALL" == false ]] && ask_package "axios" INSTALL_AXIOS
  [[ "$SKIP_ALL" == false ]] && ask_package "clsx" INSTALL_CLSX
  [[ "$SKIP_ALL" == false ]] && ask_package "zod" INSTALL_ZOD
  [[ "$SKIP_ALL" == false ]] && ask_package "react-hot-toast" INSTALL_TOAST
  if [[ "$framework" == "react" && "$SKIP_ALL" == false ]]; then
    ask_package "lucide-react" INSTALL_LUCIDE
  fi
  [[ "$SKIP_ALL" == false ]] && ask_package "Tailwind CSS" INSTALL_TAILWIND
  if [[ "$INSTALL_TAILWIND" == "1" && "$SKIP_ALL" == false ]]; then
    ask_package "DaisyUI (Tailwind plugin)" INSTALL_DAISY
  fi

  # --- Create Vite project ---
  echo
  echo "🚀 Scaffolding Vite + $framework..."
  npx create-vite "$project_name" --template "$framework"

  cd "$project_name" || { echo "❌ Failed to enter project directory."; return 1; }

  echo
  echo "📦 Installing base dependencies..."
  $PKG_MANAGER install

  # --- Optional packages ---
  packages=()
  [[ "$INSTALL_AXIOS" == "1" ]] && packages+=("axios")
  [[ "$INSTALL_CLSX" == "1" ]] && packages+=("clsx")
  [[ "$INSTALL_ZOD" == "1" ]] && packages+=("zod")
  [[ "$INSTALL_TOAST" == "1" ]] && packages+=("react-hot-toast")
  [[ "$INSTALL_LUCIDE" == "1" ]] && packages+=("lucide-react")

  if [[ "${#packages[@]}" -gt 0 ]]; then
    echo "📦 Installing selected packages: ${packages[*]}"
    if [[ "$PKG_MANAGER" == "npm" ]]; then
      npm install "${packages[@]}"
    else
      $PKG_MANAGER add "${packages[@]}"
    fi
  fi

  # --- Tailwind setup ---
  if [[ "$INSTALL_TAILWIND" == "1" ]]; then
    echo "🌬️ Setting up Tailwind CSS with modern Vite plugin..."

    if [[ "$INSTALL_DAISY" == "1" ]]; then
      echo "📦 Installing Tailwind CSS + DaisyUI..."
      $PKG_MANAGER add tailwindcss@latest @tailwindcss/vite@latest daisyui@latest
    else
      echo "📦 Installing Tailwind CSS..."
      $PKG_MANAGER add tailwindcss@latest @tailwindcss/vite@latest
    fi

    echo "⚙️ Configuring vite.config.js..."
    case "$framework" in
      react)
        cat > vite.config.js << 'EOF'
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import react from "@vitejs/plugin-react";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tailwindcss()],
});
EOF
        ;;
      vue)
        cat > vite.config.js << 'EOF'
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import vue from "@vitejs/plugin-vue";

export default defineConfig({
  plugins: [vue(), tailwindcss()],
});
EOF
        ;;
      svelte)
        cat > vite.config.js << 'EOF'
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import { svelte } from "@sveltejs/vite-plugin-svelte";

export default defineConfig({
  plugins: [svelte(), tailwindcss()],
});
EOF
        ;;
      *)
        cat > vite.config.js << 'EOF'
import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [tailwindcss()],
});
EOF
        ;;
    esac

    echo "🎨 Configuring CSS imports..."
    css_file=""
    [[ -f "src/index.css" ]] && css_file="src/index.css"
    [[ -f "src/style.css" ]] && css_file="src/style.css"
    [[ -z "$css_file" ]] && css_file="src/index.css"

    mkdir -p src
    if [[ "$INSTALL_DAISY" == "1" ]]; then
      echo -e "@import \"tailwindcss\";\n@plugin \"daisyui\";" > "$css_file"
    else
      echo -e "@import \"tailwindcss\";" > "$css_file"
    fi

    # Ensure import in main file for React
    if [[ "$framework" == "react" ]]; then
      for main_file in src/main.{jsx,tsx}; do
        if [[ -f "$main_file" ]]; then
          sed -i.bak "1i import './index.css'" "$main_file" && rm "$main_file.bak"
        fi
      done
    fi

    echo "✅ Tailwind CSS setup completed."
  else
    # --- When Tailwind not installed ---
    echo "🎨 Creating custom index.css..."
    mkdir -p src
    cat > src/index.css << 'EOF'
:root {
  font-family: system-ui, Avenir, Helvetica, Arial, sans-serif;
  line-height: 1.5;
  font-weight: 400;

  color-scheme: light dark;
  color: rgba(255, 255, 255, 0.87);
  background-color: #242424;
}
EOF
    if [[ "$framework" == "react" ]]; then
      for main_file in src/main.{jsx,tsx}; do
        if [[ -f "$main_file" ]]; then
          sed -i.bak "1i import './index.css'" "$main_file" && rm "$main_file.bak"
        fi
      done
    fi
    echo "✅ Custom CSS added."
  fi

  echo
  echo "🎉 Done! Your Vite + $framework project is ready."
  echo "➡️  cd $project_name && $PKG_MANAGER run dev"
}


node_js_init() {
  echo "🛠️ Initializing Node.js project..."

  read -p "🤔 Choose setup: 1) Basic JS  2) TypeScript [1/2]: " setup
  detect_package_manager
  pkg_manager="$PKG_MANAGER"

  echo "📦 Using package manager: $pkg_manager"
  $pkg_manager init -y >/dev/null 2>&1

  # Common deps
  dev_deps=()
  deps=()

  read -p "➕ Install dotenv? [y/N]: " use_dotenv
  [[ "$use_dotenv" =~ ^[Yy]$ ]] && deps+=("dotenv")

  read -p "🌀 Use nodemon for auto-reload? [y/N]: " use_nodemon
  [[ "$use_nodemon" =~ ^[Yy]$ ]] && dev_deps+=("nodemon")

  if [[ "$setup" == "2" ]]; then
    echo "🧩 Setting up TypeScript environment..."
    dev_deps+=("typescript" "@types/node" "ts-node")
    mkdir -p src
    cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true
  }
}
EOF

    # Minimal index.ts
    cat > src/index.ts <<'EOF'
console.log("🚀 LazyCLI Node.js + TypeScript project running!");
EOF

    start_cmd="node dist/index.js"
    dev_cmd="ts-node src/index.ts"
  else
    echo "🧱 Creating simple JavaScript project..."
    mkdir -p src
    cat > src/index.js <<'EOF'
console.log("🚀 LazyCLI Node.js project running!");
EOF

    start_cmd="node src/index.js"
    dev_cmd="$start_cmd"
  fi

  # Install deps
  if [[ ${#deps[@]} -gt 0 ]]; then
    echo "📦 Installing dependencies: ${deps[*]}"
    $pkg_manager add "${deps[@]}"
  fi

  if [[ ${#dev_deps[@]} -gt 0 ]]; then
    echo "🧩 Installing dev dependencies: ${dev_deps[*]}"
    $pkg_manager add -D "${dev_deps[@]}"
  fi

  # Update package.json scripts
  echo "🧠 Configuring package.json scripts..."
  jq --arg start "$start_cmd" \
     --arg dev "$([[ "$use_nodemon" =~ ^[Yy]$ ]] && echo "nodemon src/index" || echo "$dev_cmd")" \
     '.scripts = {start: $start, dev: $dev, build: "tsc"}' package.json > package.tmp.json && mv package.tmp.json package.json

  # Optional .env
  if [[ "$use_dotenv" =~ ^[Yy]$ ]]; then
    echo "🔐 Creating .env file..."
    cat > .env <<EOF
NODE_ENV=development
PORT=5000
EOF
    echo ".env" >> .gitignore 2>/dev/null || echo ".env" > .gitignore
  fi

  echo ""
  echo "✅ Project ready!"
  echo "➡️  Run development: $pkg_manager run dev"
  echo "➡️  Run production:  $pkg_manager run start"
  echo ""
  echo "💤 Stay lazy, code smart."
}


# Setup virtual environment for Django
setup_virtualenv() {
	# Check if virtual environment already exists
	if [ -d "venv" ]; then
		echo "Virtual environment 'venv' already exists. Activating..."
		return 0
	fi
	
	echo "Virtual environment not found. Creating new one..."
	
	if command -v virtualenv >/dev/null 2>&1; then
		virtualenv venv
		echo "Virtualenv created using 'virtualenv' package."
	else
		echo "The 'virtualenv' package is not installed."
		read -p "Would you like to install 'virtualenv'? (y/n, default: use python -m venv): " choice
		if [ "$choice" = "y" ]; then
			if ! pip install virtualenv; then
				echo "pip install failed. Trying apt install python3-virtualenv..."
				sudo apt update && sudo apt install -y python3-virtualenv
			fi
			virtualenv venv
			echo "Virtualenv installed and created."
			
		else
			python3 -m venv venv
			echo "Virtualenv created using default 'venv' module."
		fi
	fi
}

# Create a new Django project with static, templates, and media setup
djangoInit() {
	if ! command -v python3 >/dev/null 2>&1; then
		echo "Python3 is not installed or not found in PATH."
		return 1
	fi
	
	if [ -z "$1" ]; then
		echo "Usage: lazy django init <project_name>"
		return 1
	fi
    
	PROJECT_NAME=$1
	mkdir -p $PROJECT_NAME
	cd $PROJECT_NAME || exit 1

	setup_virtualenv
	source venv/bin/activate
	echo "Virtualenv activated."

	
	if ! command -v django-admin >/dev/null 2>&1; then
		echo "'django-admin' not found. Installing Django via pip..."
		pip install django || { echo "Failed to install Django."; return 1; }
	fi
	django-admin startproject $PROJECT_NAME .

	# Create directories
	mkdir -p static
	mkdir -p templates
	mkdir -p media

	# Update settings.py
	SETTINGS_FILE="$PROJECT_NAME/settings.py"
	if ! grep -q "'django.contrib.staticfiles'" "$SETTINGS_FILE"; then
		sed -i "/^INSTALLED_APPS = \[/a    'django.contrib.staticfiles'," "$SETTINGS_FILE"
	fi
	echo -e "\nSTATICFILES_DIRS = [BASE_DIR / 'static']\nTEMPLATES[0]['DIRS'] = [BASE_DIR / 'templates']\nMEDIA_URL = '/media/'\nMEDIA_ROOT = BASE_DIR / 'media'" >> $SETTINGS_FILE

	echo "Django project '$PROJECT_NAME' created with static, templates, and media directories."
}

# Main CLI router
case "$1" in
  "init")
    lazy_init
    ;;

  "github")
    case "$2" in
      "init") github_init ;;
      "clone") shift 2; github_clone "$@" ;;
      "push") shift 2; github_push "$@" ;;
      "pull") shift 2; github_create_pull "$@" ;;
      "pr") shift 2; github_create_pr "$@" ;;
      *) echo "❌ Unknown github subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  "node-js")
    case "$2" in
      "init") node_js_init ;;
      *) echo "❌ Unknown node-js subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  "next-js")
    case "$2" in
      "init") next_js_init ;;
      *) echo "❌ Unknown next-js subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  "vite-js")
    case "$2" in
      "init") vite_js_init ;;
      *) echo "❌ Unknown vite-js subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  "react-native")
    case "$2" in
      "init") react_native_init ;;
      *) echo "❌ Unknown react-native subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  "django")
    case "$2" in
      "init") shift 2; djangoInit "$@" ;;
      *) echo "❌ Unknown django subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  "--version" | "version" | "-v")
    echo "LazyCLI version $VERSION"
    ;;

  "--help" | "help")
    show_help
    ;;

  *)
    echo "❌ Unknown command: $1"
    show_help
    exit 1
    ;;
esac
