#!/bin/bash

VERSION="1.0.3"

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
      Initialize a new Vite project, select framework, and optionally install common packages.

  lazy react-native init
      Scaffold a new React Native application with Expo or React Native CLI setup.

  lazy init
      Run the interactive project initializer (Next.js, Vite.js, React Native, Node.js).

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
                - init       Initialize Next.js app with TypeScript, Tailwind, ESLint defaults

  vite-js       Vite project scaffolding:
                - init       Initialize Vite project with framework selection and optional packages

  react-native  Mobile app development with React Native:
                - init       Initialize React Native app with Expo or CLI, navigation, and essential packages

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

node_js_init() {
  echo "🛠️ Initializing Node.js project..."
  
  # Ask user preference
  read -p "🤔 Use simple setup (1) or TypeScript setup (2)? [1/2]: " setup_type
  
  if [[ "$setup_type" == "1" ]]; then
    # Simple setup
    npm init -y
    echo "📦 Suggested packages:"
    echo "   npm install express nodemon"
    echo "   npm install -D @types/node"
  else
    # TypeScript setup (enhanced version)
    echo "🛠️ Setting up TypeScript Node.js project..."
    
    # Detect package manager
    detect_package_manager
    pkg_manager="$PKG_MANAGER"
    
    echo "🧠 LazyCLI Smart Stack Setup: Answer once and make yourself gloriously lazy"
    echo "   1 = Yes, 0 = No, -1 = Skip all remaining prompts"
    
    prompt_or_exit() {
      local prompt_text=$1
      local answer
      while true; do
        read -p "$prompt_text (1/0/-1): " answer
        case "$answer" in
          1|0|-1) echo "$answer"; return ;;
          *) echo "Please enter 1, 0, or -1." ;;
        esac
      done
    }
    
    ans_nodemon=$(prompt_or_exit "➕ Install nodemon for development?")
    [[ "$ans_nodemon" == "-1" ]] && echo "🚫 Setup skipped." && return
    
    ans_express=$(prompt_or_exit "🌐 Install express?")
    [[ "$ans_express" == "-1" ]] && echo "🚫 Setup skipped." && return
    
    ans_cors=$(prompt_or_exit "🔗 Install cors?")
    [[ "$ans_cors" == "-1" ]] && echo "🚫 Setup skipped." && return
    
    ans_dotenv=$(prompt_or_exit "🔐 Install dotenv?")
    [[ "$ans_dotenv" == "-1" ]] && echo "🚫 Setup skipped." && return
    
    # Initialize npm project
    npm init -y
    
    # Install TypeScript and related packages
    echo "📦 Installing TypeScript and development dependencies..."
    if [[ "$pkg_manager" == "npm" ]]; then
      npm install -D typescript @types/node ts-node
    else
      $pkg_manager add -D typescript @types/node ts-node
    fi
    
    # Install optional packages
    packages=()
    dev_packages=()
    
    [[ "$ans_express" == "1" ]] && packages+=("express") && dev_packages+=("@types/express")
    [[ "$ans_cors" == "1" ]] && packages+=("cors") && dev_packages+=("@types/cors")
    [[ "$ans_dotenv" == "1" ]] && packages+=("dotenv")
    [[ "$ans_nodemon" == "1" ]] && dev_packages+=("nodemon")
    
    if [[ ${#packages[@]} -gt 0 ]]; then
      echo "📦 Installing packages: ${packages[*]}"
      if [[ "$pkg_manager" == "npm" ]]; then
        npm install "${packages[@]}"
      else
        $pkg_manager add "${packages[@]}"
      fi
    fi
    
    if [[ ${#dev_packages[@]} -gt 0 ]]; then
      echo "📦 Installing dev packages: ${dev_packages[*]}"
      if [[ "$pkg_manager" == "npm" ]]; then
        npm install -D "${dev_packages[@]}"
      else
        $pkg_manager add -D "${dev_packages[@]}"
      fi
    fi
    
    # Create TypeScript config
    echo "⚙️ Creating tsconfig.json..."
    cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF
    
    # Create src directory and index.ts
    mkdir -p src
    
    if [[ ! -f "src/index.ts" ]]; then
      echo "📝 Creating src/index.ts..."
      if [[ "$ans_express" == "1" ]]; then
        # Express server template
        cat > src/index.ts <<'EOF'
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.json({
    message: '🚀 LazyCLI Express Server is running!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

app.get('/health', (req, res) => {
  res.json({ status: 'OK', uptime: process.uptime() });
});

// Error handling middleware
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log('💤 Built with LazyCLI – stay lazy, code smart!');
});
EOF
      else
        # Simple Node.js template
        cat > src/index.ts <<'EOF'
console.log('🚀 Hello from TypeScript Node.js!');
console.log('💤 Built with LazyCLI – stay lazy, code smart!');

// Example function
function greet(name: string): string {
  return `Hello, ${name}! Welcome to your TypeScript project.`;
}

console.log(greet('Developer'));
EOF
      fi
    else
      echo "ℹ️ src/index.ts already exists. Appending LazyCLI branding..."
      echo 'console.log("🚀 Booted with LazyCLI – stay lazy, code smart 😴");' >> src/index.ts
    fi
    
    # Create environment file if dotenv is installed
    if [[ "$ans_dotenv" == "1" && ! -f ".env" ]]; then
      echo "🔐 Creating .env file..."
      cat > .env <<'EOF'
# Environment variables
NODE_ENV=development
PORT=5000

# Add your environment variables here
# DATABASE_URL=
# JWT_SECRET=
EOF
      
      # Add .env to .gitignore if it exists
      if [[ -f ".gitignore" ]]; then
        echo ".env" >> .gitignore
      else
        echo ".env" > .gitignore
      fi
    fi
    
    # Create a clean package.json with proper structure
    echo "🛠️ Creating package.json with LazyCLI template..."
    
    # Remove existing package.json to avoid conflicts
    rm -f package.json
    
    # Create new package.json with proper structure
    if [[ "$pkg_manager" == "bun" ]]; then
      if [[ "$ans_nodemon" == "1" ]]; then
        cat > package.json <<'EOF'
{
  "name": "node-typescript-project",
  "version": "1.0.0",
  "description": "TypeScript Node.js project created with LazyCLI",
  "main": "dist/index.js",
  "module": "src/index.ts",
  "type": "commonjs",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "nodemon src/index.ts",
    "build": "tsc",
    "clean": "rm -rf dist",
    "test": "bun test"
  },
  "keywords": ["typescript", "node", "lazycli"],
  "author": "",
  "license": "MIT",
  "devDependencies": {},
  "dependencies": {}
}
EOF
      else
        cat > package.json <<'EOF'
{
  "name": "node-typescript-project",
  "version": "1.0.0",
  "description": "TypeScript Node.js project created with LazyCLI",
  "main": "dist/index.js",
  "module": "src/index.ts",
  "type": "commonjs",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "ts-node src/index.ts",
    "build": "tsc",
    "clean": "rm -rf dist",
    "test": "bun test"
  },
  "keywords": ["typescript", "node", "lazycli"],
  "author": "",
  "license": "MIT",
  "devDependencies": {},
  "dependencies": {}
}
EOF
      fi
    else
      if [[ "$ans_nodemon" == "1" ]]; then
        cat > package.json <<'EOF'
{
  "name": "node-typescript-project",
  "version": "1.0.0",
  "description": "TypeScript Node.js project created with LazyCLI",
  "main": "dist/index.js",
  "type": "commonjs",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "nodemon src/index.ts",
    "build": "tsc",
    "clean": "rm -rf dist",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["typescript", "node", "lazycli"],
  "author": "",
  "license": "MIT",
  "devDependencies": {},
  "dependencies": {}
}
EOF
      else
        cat > package.json <<'EOF'
{
  "name": "node-typescript-project",
  "version": "1.0.0",
  "description": "TypeScript Node.js project created with LazyCLI",
  "main": "dist/index.js",
  "type": "commonjs",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "ts-node src/index.ts",
    "build": "tsc",
    "clean": "rm -rf dist",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["typescript", "node", "lazycli"],
  "author": "",
  "license": "MIT",
  "devDependencies": {},
  "dependencies": {}
}
EOF
      fi
    fi
    
    echo "📁 Project structure created:"
    echo "   src/index.ts - Main TypeScript file"
    echo "   tsconfig.json - TypeScript configuration"
    [[ "$ans_dotenv" == "1" ]] && echo "   .env - Environment variables"
    echo ""
    
    if [[ "$ans_nodemon" == "1" ]]; then
      echo "✅ Run with: $pkg_manager run dev (development with auto-reload)"
    else
      echo "✅ Run with: $pkg_manager run dev (development)"
    fi
    echo "✅ Build with: $pkg_manager run build"
    echo "✅ Run production: $pkg_manager run start"
    
    echo "✅ Node.js + TypeScript project is ready!"
  fi
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



# Create a new React Native application with Expo or React Native CLI
# Supports both Expo and React Native CLI workflows with common packages
# Includes: navigation, async storage, vector icons, state management, UI libraries
react_native_create() {
  echo "📱 Creating React Native app..."

  read -p "📦 Enter project name (no spaces): " project_name
  if [ -z "$project_name" ]; then
    echo "❌ Project name cannot be empty."
    return
  fi

  echo "🛠️ Choose React Native setup method:"
  echo "1) Expo (Recommended for beginners - easier setup, managed workflow)"
  echo "2) React Native CLI (Advanced - more control, native modules)"
  read -p "🔧 Enter choice [1-2]: " setup_choice

  case $setup_choice in
    1) setup_method="expo" ;;
    2) setup_method="cli" ;;
    *) echo "❌ Invalid choice. Defaulting to Expo."; setup_method="expo" ;;
  esac

  detect_package_manager

  echo ""
  echo "🧠 LazyCLI Smart Stack Setup: Answer once and make yourself gloriously lazy"
  echo "   1 = Yes, 0 = No, -1 = Skip all remaining prompts"

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
  
  # Core navigation and essential packages
  [[ "$SKIP_ALL" == false ]] && ask_package "React Navigation (tab/stack navigation)" INSTALL_NAVIGATION
  [[ "$SKIP_ALL" == false ]] && ask_package "Async Storage (local data persistence)" INSTALL_ASYNC_STORAGE
  [[ "$SKIP_ALL" == false ]] && ask_package "Vector Icons (icon library)" INSTALL_VECTOR_ICONS
  
  # State management
  [[ "$SKIP_ALL" == false ]] && ask_package "Redux Toolkit (state management)" INSTALL_REDUX
  [[ "$SKIP_ALL" == false ]] && ask_package "Zustand (lightweight state management)" INSTALL_ZUSTAND
  
  # UI and styling
  [[ "$SKIP_ALL" == false ]] && ask_package "NativeWind (Tailwind for React Native)" INSTALL_NATIVEWIND
  [[ "$SKIP_ALL" == false ]] && ask_package "React Native Elements (UI components)" INSTALL_RN_ELEMENTS
  
  # Utilities
  [[ "$SKIP_ALL" == false ]] && ask_package "React Hook Form (form handling)" INSTALL_HOOK_FORM
  [[ "$SKIP_ALL" == false ]] && ask_package "Axios (HTTP client)" INSTALL_AXIOS
  [[ "$SKIP_ALL" == false ]] && ask_package "React Query/TanStack Query (data fetching)" INSTALL_REACT_QUERY
  [[ "$SKIP_ALL" == false ]] && ask_package "Date-fns (date utilities)" INSTALL_DATE_FNS

  # TypeScript option
  if [[ "$setup_method" == "expo" ]]; then
    [[ "$SKIP_ALL" == false ]] && ask_package "TypeScript template" INSTALL_TYPESCRIPT
  fi

  echo ""
  echo "🚀 Creating React Native project with $setup_method..."

  if [[ "$setup_method" == "expo" ]]; then
    # Expo setup
    if [[ "$INSTALL_TYPESCRIPT" == "1" ]]; then
      echo "📦 Creating Expo app with TypeScript..."
      npx create-expo-app "$project_name" --template blank-typescript
    else
      echo "📦 Creating Expo app with JavaScript..."
      npx create-expo-app "$project_name" --template blank
    fi
  else
    # React Native CLI setup
    echo "📦 Creating React Native CLI app..."
    npx react-native init "$project_name"
  fi

  cd "$project_name" || return

  echo "📦 Installing base dependencies..."
  if [[ "$PKG_MANAGER" == "npm" ]]; then
    npm install
  else
    $PKG_MANAGER install
  fi

  # Prepare packages list based on setup method
  packages=()
  dev_packages=()

  if [[ "$INSTALL_NAVIGATION" == "1" ]]; then
    if [[ "$setup_method" == "expo" ]]; then
      packages+=("@react-navigation/native" "@react-navigation/native-stack" "@react-navigation/bottom-tabs")
      packages+=("react-native-screens" "react-native-safe-area-context")
    else
      packages+=("@react-navigation/native" "@react-navigation/native-stack" "@react-navigation/bottom-tabs")
      packages+=("react-native-screens" "react-native-safe-area-context" "react-native-gesture-handler")
    fi
  fi

  [[ "$INSTALL_ASYNC_STORAGE" == "1" ]] && packages+=("@react-native-async-storage/async-storage")
  [[ "$INSTALL_VECTOR_ICONS" == "1" ]] && packages+=("react-native-vector-icons")
  [[ "$INSTALL_REDUX" == "1" ]] && packages+=("@reduxjs/toolkit" "react-redux")
  [[ "$INSTALL_ZUSTAND" == "1" ]] && packages+=("zustand")
  [[ "$INSTALL_NATIVEWIND" == "1" ]] && packages+=("nativewind") && dev_packages+=("tailwindcss")
  [[ "$INSTALL_RN_ELEMENTS" == "1" ]] && packages+=("react-native-elements" "react-native-ratings" "react-native-slider")
  [[ "$INSTALL_HOOK_FORM" == "1" ]] && packages+=("react-hook-form")
  [[ "$INSTALL_AXIOS" == "1" ]] && packages+=("axios")
  [[ "$INSTALL_REACT_QUERY" == "1" ]] && packages+=("@tanstack/react-query")
  [[ "$INSTALL_DATE_FNS" == "1" ]] && packages+=("date-fns")

  # Install selected packages
  if [[ ${#packages[@]} -gt 0 ]]; then
    echo "📦 Installing selected packages: ${packages[*]}"
    if [[ "$PKG_MANAGER" == "npm" ]]; then
      npm install "${packages[@]}"
    else
      $PKG_MANAGER add "${packages[@]}"
    fi
  fi

  # Install dev dependencies
  if [[ ${#dev_packages[@]} -gt 0 ]]; then
    echo "📦 Installing dev dependencies: ${dev_packages[*]}"
    if [[ "$PKG_MANAGER" == "npm" ]]; then
      npm install --save-dev "${dev_packages[@]}"
    else
      $PKG_MANAGER add -D "${dev_packages[@]}"
    fi
  fi

  # Setup NativeWind if selected
  if [[ "$INSTALL_NATIVEWIND" == "1" ]]; then
    echo "🌬️ Setting up NativeWind (Tailwind CSS for React Native)..."
    
    # Create tailwind.config.js
    cat > tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {},
  },
  plugins: [],
}
EOF
    
    # Create global.css
    cat > global.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;
EOF
    
    echo "✅ NativeWind configured! Import './global.css' in your App.js"
  fi

  # Create basic navigation structure if navigation is selected
  if [[ "$INSTALL_NAVIGATION" == "1" ]]; then
    echo "🧭 Setting up basic navigation structure..."
    
    mkdir -p src/screens src/navigation src/components
    
    # Create basic screens
    cat > src/screens/HomeScreen.js << 'EOF'
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

export default function HomeScreen({ navigation }) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome to Your React Native App!</Text>
      <Text style={styles.subtitle}>Built with LazyCLI</Text>
      
      <TouchableOpacity
        style={styles.button}
        onPress={() => navigation.navigate('Profile')}
      >
        <Text style={styles.buttonText}>Go to Profile</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 30,
  },
  button: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 8,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});
EOF

    cat > src/screens/ProfileScreen.js << 'EOF'
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';

export default function ProfileScreen({ navigation }) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Profile Screen</Text>
      <Text style={styles.subtitle}>This is your profile page</Text>
      
      <TouchableOpacity
        style={styles.button}
        onPress={() => navigation.goBack()}
      >
        <Text style={styles.buttonText}>Go Back</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 30,
  },
  button: {
    backgroundColor: '#FF3B30',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 8,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});
EOF

    # Create navigation file
    cat > src/navigation/AppNavigator.js << 'EOF'
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from '../screens/HomeScreen';
import ProfileScreen from '../screens/ProfileScreen';

const Stack = createNativeStackNavigator();

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{ title: 'LazyCLI App' }}
        />
        <Stack.Screen
          name="Profile"
          component={ProfileScreen}
          options={{ title: 'Profile' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
EOF

    # Update App.js to use navigation
    if [[ "$setup_method" == "expo" ]]; then
      cat > App.js << 'EOF'
import React from 'react';
import AppNavigator from './src/navigation/AppNavigator';

export default function App() {
  return <AppNavigator />;
}
EOF
    else
      cat > App.tsx << 'EOF'
import React from 'react';
import AppNavigator from './src/navigation/AppNavigator';

function App(): JSX.Element {
  return <AppNavigator />;
}

export default App;
EOF
    fi
    
    echo "✅ Basic navigation structure created!"
  fi

  # Platform-specific setup instructions
  echo ""
  echo "📱 Setup Instructions:"
  if [[ "$setup_method" == "expo" ]]; then
    echo "🚀 Run your Expo app:"
    echo "   cd $project_name"
    echo "   npx expo start"
    echo ""
    echo "📱 Download Expo Go app on your phone to test"
    echo "🔗 Expo Go: https://expo.dev/client"
  else
    echo "🚀 Run your React Native app:"
    echo "   cd $project_name"
    echo ""
    echo "📱 For iOS:"
    echo "   npx react-native run-ios"
    echo "   (Requires Xcode and iOS Simulator)"
    echo ""
    echo "🤖 For Android:"
    echo "   npx react-native run-android"
    echo "   (Requires Android Studio and emulator)"
    echo ""
    echo "⚠️  Additional setup may be required for React Native CLI:"
    echo "   - iOS: https://reactnative.dev/docs/environment-setup"
    echo "   - Android: https://reactnative.dev/docs/environment-setup"
  fi

  echo ""
  echo "🎉 React Native project setup complete!"
  echo "📁 Project structure:"
  [[ "$INSTALL_NAVIGATION" == "1" ]] && echo "   src/screens/ - App screens"
  [[ "$INSTALL_NAVIGATION" == "1" ]] && echo "   src/navigation/ - Navigation setup"
  [[ "$INSTALL_NAVIGATION" == "1" ]] && echo "   src/components/ - Reusable components"
  [[ "$INSTALL_NATIVEWIND" == "1" ]] && echo "   global.css - Tailwind styles"
  echo "   App.js - Main app component"
  echo ""
  echo "🛠️ Installed packages:"
  [[ "$INSTALL_NAVIGATION" == "1" ]] && echo "   ✓ React Navigation"
  [[ "$INSTALL_ASYNC_STORAGE" == "1" ]] && echo "   ✓ Async Storage"
  [[ "$INSTALL_VECTOR_ICONS" == "1" ]] && echo "   ✓ Vector Icons"
  [[ "$INSTALL_REDUX" == "1" ]] && echo "   ✓ Redux Toolkit"
  [[ "$INSTALL_ZUSTAND" == "1" ]] && echo "   ✓ Zustand"
  [[ "$INSTALL_NATIVEWIND" == "1" ]] && echo "   ✓ NativeWind (Tailwind CSS)"
  [[ "$INSTALL_RN_ELEMENTS" == "1" ]] && echo "   ✓ React Native Elements"
  [[ "$INSTALL_HOOK_FORM" == "1" ]] && echo "   ✓ React Hook Form"
  [[ "$INSTALL_AXIOS" == "1" ]] && echo "   ✓ Axios"
  [[ "$INSTALL_REACT_QUERY" == "1" ]] && echo "   ✓ React Query"
  [[ "$INSTALL_DATE_FNS" == "1" ]] && echo "   ✓ Date-fns"
  
  echo "✅ Your React Native app is ready to go! 🚀"
}

# Main command dispatcher
case "$1" in
  --help | help )
    show_help
    ;;

  --version | -v )
    echo "🧠 LazyCLI v$VERSION"
    ;;

  upgrade )
    echo "🔄 Upgrading LazyCLI..."
    rm -f "$HOME/.lazycli/lazy"
    curl -s https://lazycli.vercel.app/scripts/lazy.sh -o "$HOME/.lazycli/lazy"
    chmod +x "$HOME/.lazycli/lazy"
    echo "✅ LazyCLI upgraded to the latest version!"
    exit 0
    ;;

  github )
    case "$2" in
      init) github_init ;;
      clone) github_clone "$3" "$4" ;;
      push) github_push "$3" ;;
      pull) github_create_pull "$3" "$4" ;;
      pr) github_create_pr "$3" "$4" ;;
      *) echo "❌ Unknown github subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  node-js )
    case "$2" in
      init) node_js_init ;;
      *) echo "❌ Unknown node-js subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  next-js )
    case "$2" in
      init) next_js_create ;;  # renamed create → init (function stays same)
      *) echo "❌ Unknown next-js subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  vite-js )
    case "$2" in
      init) vite_js_create ;;  # renamed create → init
      *) echo "❌ Unknown vite-js subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  react-native )
    case "$2" in
      init) react_native_create ;;  # renamed create → init
      *) echo "❌ Unknown react-native subcommand: $2"; show_help; exit 1 ;;
    esac
    ;;

  init )
    echo "✨ LazyCLI Universal Initializer"
    echo "--------------------------------"
    echo "1) Next.js App"
    echo "2) Vite.js App"
    echo "3) React Native App"
    echo "4) Node.js Backend"
    echo "--------------------------------"
    read -p "🔧 Choose what to initialize [1-4]: " stack_choice

    case "$stack_choice" in
      1) next_js_create ;;
      2) vite_js_create ;;
      3) react_native_create ;;
      4) node_js_init ;;
      *) echo "❌ Invalid choice."; exit 1 ;;
    esac
    ;;

  *)
    echo "❌ Unknown command: $1"
    show_help
    exit 1
    ;;
esac
