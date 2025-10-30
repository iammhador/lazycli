<div align="center">
  <img src="./public/logo.png" alt="LazyCLI Logo" width="120" height="120">
  
  # ⚡ LazyCLI – Automate your dev flow like a lazy pro
  
  **Automate your development workflow like a lazy pro** 💤
  
  [![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
  [![Version](https://img.shields.io/badge/version-1.0.2-blue.svg)](https://github.com/iammhador/lazycli)
  [![Open Source](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://opensource.org/)
  
  *A powerful, Bash-based command-line interface that simplifies your development and deployment workflow — from initializing projects to pushing code to GitHub — all in a single CLI tool.*
</div>

---

## 🚀 Installation

Install globally with one command (macOS/Linux):

```bash
# Standard installation
curl -s https://lazycli.xyz/install.sh | bash

# Custom version installation
curl -s https://lazycli.xyz/install.sh | bash -s version_name
```

> 💡 **Windows users:** Requires WSL or Git Bash — [See installation guide →](https://lazycli.xyz/windows)

---

## ✅ Current Features

### 🐙 GitHub Automation

- **`lazy github init`** - Initialize a new Git repository
- **`lazy github clone <repo-url>`** - Clone repository with auto-setup
- **`lazy github push "<message>"`** - Stage, commit, and push changes
- **`lazy github pull <base-branch> "<title>"`** - Create pull request
- **`lazy github pr <base-branch> "<message>"`** - Full PR workflow (pull, build, commit, push, create PR)

### 📦 Node.js Development

- **`lazy node-js init`** - Initialize Node.js + TypeScript project
- **`lazy node-js structure`** - Create comprehensive Node.js project structure with templates

### 🐍 Django Development

- **`lazy django init <project_name>`** - Complete Django project initialization

  - **Smart Virtual Environment Management**
  - **Pre-configured project structure**: `static/`, `templates/`, `media/`
  - **Auto-configured settings**: static, templates, media

### ⚛️ Next.js Scaffolding

- **`lazy next-js init`** - Scaffold a new Next.js app with modern defaults
- TypeScript, Tailwind CSS, and ESLint pre-configured
- Optional packages: Zod, bcrypt, js-cookie, SWR, Lucide React, react-hot-toast
- shadcn/ui integration support

### ⚡ Vite.js Projects

- **`lazy vite-js init`** - Multi-framework Vite project initialization
- Supports: Vanilla JS, React, Vue, Svelte
- Optional packages: axios, clsx, zod, react-hot-toast, react-router-dom, lucide-react
- Modern Tailwind CSS integration with DaisyUI support

### 📱 React Native Development

- **`lazy react-native init`** - Cross-platform mobile app initialization
- Supports: Expo (beginner-friendly) and React Native CLI (advanced)
- Navigation: React Navigation with stack and tab navigation
- State management: Redux Toolkit, Zustand options
- UI libraries: NativeWind (Tailwind), React Native Elements
- Essential packages: Async Storage, Vector Icons, React Hook Form, Axios

### 🔧 System Features

- **`lazy --version`** - Show current version
- **`lazy upgrade`** - Auto-upgrade to latest version
- **`lazy --help`** - Comprehensive help system
- Smart package manager detection
- Cross-platform compatibility

---

## 🔮 Upcoming Features

- Python project bootstrapping
- Docker containerization support
- Deployment via PM2 and SSH
- Flutter, Go, Rust, .NET support
- Environment and secret management
- Auto-updating CLI (`lazycli update`)

---

## 🧪 Usage

Run commands globally from anywhere in your terminal:

### GitHub Workflow

```bash
lazy github init
lazy github clone https://github.com/iammhador/repo.git
lazy github push "Add new feature"
lazy github pr main "Implement user authentication"
```

### Project Creation / Initialization

```bash
lazy node-js init
lazy node-js structure
lazy next-js init
lazy vite-js init
lazy react-native init
lazy django init myproject
```

---

## 🖥️ Platform Support

| Platform       | Status             | Requirements    |
| -------------- | ------------------ | --------------- |
| 🍎 **macOS**   | ✅ Full Support    | Bash 4.0+       |
| 🐧 **Linux**   | ✅ Full Support    | Bash 4.0+       |
| 🪟 **Windows** | ⚠️ Partial Support | WSL or Git Bash |

---

## 🤝 Contributing

We welcome contributions! LazyCLI is open-source.

```bash
git clone https://github.com/iammhador/lazycli
cd lazycli
```

- 📝 Follow existing code style and patterns
- 🧪 Test your changes thoroughly
- 📚 Update documentation
- 🔍 Ensure cross-platform compatibility

More: [lazycli.xyz/contribute](https://lazycli.xyz/contribute)

---

## 📄 License

[MIT License](LICENSE)

---

## 🙌 Credits

Built and maintained by [iammhador](https://iammhador.xyz).
