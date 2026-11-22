# Minimal Code Editor

> **The Fluent, Modeless Terminal Code Editor for All Operating Systems.**  
> Blends the blazing speed (<50ms startup) and low resource footprint of the terminal with the modeless editing, rich aesthetics, and polyglot power of modern graphical IDEs like VS Code and Zed.

---

## ⚡ Core Philosophy & Guarantees

1. **Sub-50ms Cold Startup & Low Resource Usage**: Uses native Neovim 0.12 LuaJIT bytecode caching, compiled C/Rust plugins (`blink.cmp`, `snacks.nvim`), and intelligent event deferral. Starts in **~48ms** and runs comfortably under 40 MB RAM.
2. **100% Strict OS Isolation**: Powered by `NVIM_APPNAME=minimal`. Configs, plugins, sessions, and state are isolated in `~/.config/minimal` (or `%LOCALAPPDATA%\minimal` on Windows). Never interferes with your vanilla `nvim` or other configurations.
3. **Zero Host Terminal Tampering**: Never modifies your terminal emulator configs (`kitty.conf`, `ghostty.conf`, `foot.ini`, Windows Terminal). Word jumping, selection, and modeless navigation are handled natively by the editor.
4. **Universal All-OS Support**: First-class, zero-prerequisite installer for Linux (Debian, Ubuntu, Arch, Fedora, Alpine, Void), macOS (Intel & Apple Silicon), WSL, and Windows.
5. **Zero-Nest Terminal RPC Client**: Running `minimal <file>`, `nvim <file>`, or `code <file>` inside the integrated terminal drawer forwards the file directly to a new tab in the parent editor window instead of launching a nested Neovim process.
6. **Fluent Visuals**:
   - **Rainbow Tabs**: Color-accented tab bar with dirty indicators and filetype icons.
   - **Green Smooth & Fluent Cursor**: Modeless vertical beam (`ver25`) with active scope indent guidance.
   - **Breadcrumbs Winbar**: Instant directory path navigation with file icons.
   - **Realtime Hex Colorizer**: Inline color previews for hex and CSS colors (`#00E5FF`, `#FF007F`).
   - **6 Bespoke Minimal Themes**: Handcrafted original palettes with live interactive switcher.

---

## 🚀 Universal One-Line Installation

Install Minimal on any operating system with a single command. The installer automatically provisions dependencies, compiles the plugin cache, and registers the application.

### 🐧 Linux & 🍏 macOS & 🐧 WSL (One-Liner)
```bash
curl -fsSL https://raw.githubusercontent.com/utkarshIsAProgrammer/minimal/main/install.sh | bash
```
*(Or with `wget`: `wget -qO- https://raw.githubusercontent.com/utkarshIsAProgrammer/minimal/main/install.sh | bash`)*

### 🪟 Windows (PowerShell One-Liner)
Open PowerShell (as normal user) and run:
```powershell
irm https://raw.githubusercontent.com/utkarshIsAProgrammer/minimal/main/install.ps1 | iex
```

---

## 🌟 Starting Completely Fresh (Zero Pre-Installation Guarantee)

If you are setting up a brand-new computer or want to test a completely clean install from scratch:

### How it Works:
1. **No Pre-Installed Tools Needed**:
   - You **do not** need to install Neovim beforehand.
   - If `nvim` (or Neovim v0.10+) is missing, the installer automatically provisions the modern pre-compiled engine into your user directory.
   - On Windows, if `git` or `nvim` is missing, the installer automatically provisions them via `winget` or direct portable download.
2. **One-Command Fresh Reset**:
   If you already have Minimal and want to test a 100% clean installation from scratch:
   - **Linux / macOS**:
     ```bash
     curl -fsSL https://raw.githubusercontent.com/utkarshIsAProgrammer/minimal/main/install.sh | bash -s -- --clean
     ```
   - **Windows**:
     ```powershell
     & ([scriptblock]::Create((irm https://raw.githubusercontent.com/utkarshIsAProgrammer/minimal/main/install.ps1))) -Clean
     ```
3. **Desktop & Application Launcher Integration**:
   - On Linux, Minimal is registered with your desktop environment (`~/.local/share/applications/minimal.desktop`) and app grid with a dedicated HD vector icon.
   - On Windows, a **Minimal** shortcut is automatically placed in your Windows Start Menu.

---

## 💻 Running Minimal

```bash
# Open current directory / workspace
minimal .

# Open or create a file anywhere (auto-creates parent directories on save)
minimal src/api/routes/auth.go

# Inspect system health and language compilers
minimal --doctor

# Benchmark exact startup latency in milliseconds
minimal --benchmark
```

---

## 🧹 Clean Uninstallation

If you ever wish to remove Minimal, it cleans up all its symlinks, cache, and state, leaving your system completely untouched:

- **Linux / macOS**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/utkarshIsAProgrammer/minimal/main/uninstall.sh | bash -s -- -y
  ```
- **Windows**:
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/utkarshIsAProgrammer/minimal/main/uninstall.ps1))) -Force
  ```

---

## 🎨 Curated Bespoke Themes

Open the live theme previewer anytime with <kbd>Ctrl+K Ctrl+T</kbd> or through the Command Palette:

1. **Cyber Aurora** (Default): High-contrast electric cyan and green aurora on deep midnight space (`#090d16`).
2. **Dark Magic**: Deep neon synthwave & cyberpunk with obsidian violet (`#07070f`).
3. **Medieval Scriptorium**: Illuminated manuscript, dragon gold, and ancient castle stone (`#0e0d0b`).
4. **Crimson Nocturne**: Gothic black velvet, mahogany, and ruby red glow (`#0b0709`).

---

## ⌨️ Complete Keybinding Cheat Sheet

### 1. Modeless Editing & Clipboard
| Action | Shortcut |
|---|---|
| **Save File** | <kbd>Ctrl+S</kbd> |
| **Save All Files** | <kbd>Ctrl+Shift+S</kbd> |
| **New File** | <kbd>Ctrl+N</kbd> |
| **Close Tab** | <kbd>Ctrl+W</kbd> or <kbd>Ctrl+Q</kbd> |
| **Select All** | <kbd>Ctrl+A</kbd> |
| **Copy** | <kbd>Ctrl+C</kbd> or <kbd>Ctrl+Insert</kbd> |
| **Cut (Selection or Line)** | <kbd>Ctrl+X</kbd> or <kbd>Shift+Delete</kbd> |
| **Paste** | <kbd>Ctrl+V</kbd> or <kbd>Shift+Insert</kbd> |
| **Undo / Redo** | <kbd>Ctrl+Z</kbd> / <kbd>Ctrl+Y</kbd> (or <kbd>Ctrl+Shift+Z</kbd>) |
| **Delete Line** | <kbd>Ctrl+Shift+K</kbd> |
| **Move Line Up / Down** | <kbd>Alt+Up</kbd> / <kbd>Alt+Down</kbd> |
| **Duplicate Line** | <kbd>Shift+Alt+Down</kbd> / <kbd>Shift+Alt+Up</kbd> |
| **Insert Line Below / Above** | <kbd>Ctrl+Enter</kbd> / <kbd>Ctrl+Shift+Enter</kbd> |
| **Toggle Line / Block Comment** | <kbd>Ctrl+/</kbd> / <kbd>Shift+Alt+A</kbd> |
| **Fold / Unfold Block** | <kbd>Ctrl+Shift+[</kbd> / <kbd>Ctrl+Shift+]</kbd> |
| **Multi-Cursor (Next Match)** | <kbd>Ctrl+D</kbd> |

### 2. Navigation, Focus & Precise Selection
| Action | Shortcut |
|---|---|
| **Focus File Explorer Sidebar** | <kbd>Ctrl+0</kbd> or <kbd>Ctrl+Shift+E</kbd> |
| **Focus Editor Window** | <kbd>Ctrl+1</kbd> or <kbd>Alt+1</kbd> |
| **Focus Integrated Terminal** | <kbd>Ctrl+2</kbd> or <kbd>Alt+2</kbd> |
| **Jump Word Left / Right** | <kbd>Ctrl+Left</kbd> / <kbd>Ctrl+Right</kbd> |
| **Select Whole Word Left / Right** | <kbd>Ctrl+Shift+Left</kbd> / <kbd>Ctrl+Shift+Right</kbd> |
| **Select by Character** | <kbd>Shift+Left</kbd> / <kbd>Shift+Right</kbd> / <kbd>Shift+Up/Down</kbd> |
| **Select to Line Start / End** | <kbd>Shift+Home</kbd> / <kbd>Shift+End</kbd> |
| **Select to File Start / End** | <kbd>Ctrl+Shift+Home</kbd> / <kbd>Ctrl+Shift+End</kbd> |
| **Jump to Line Start / End** | <kbd>Home</kbd> / <kbd>End</kbd> |
| **Jump to File Start / End** | <kbd>Ctrl+Home</kbd> / <kbd>Ctrl+End</kbd> |
| **Delete Word Left / Right** | <kbd>Ctrl+Backspace</kbd> / <kbd>Ctrl+Delete</kbd> |
| **Find in Current File** | <kbd>Ctrl+F</kbd> |
| **Replace in Current File** | <kbd>Ctrl+H</kbd> |
| **Go to Line Number** | <kbd>Ctrl+G</kbd> |
| **Quick Open File** | <kbd>Ctrl+P</kbd> |
| **Command Palette** | <kbd>Ctrl+Shift+P</kbd> |
| **Go to Symbol in File** | <kbd>Ctrl+Shift+O</kbd> |
| **Global Search (Live Grep)** | <kbd>Ctrl+Shift+F</kbd> |
| **Toggle File Explorer Sidebar** | <kbd>Ctrl+B</kbd> |
| **Toggle Terminal Drawer** | <kbd>Ctrl+\`</kbd> / <kbd>Ctrl+~</kbd> / <kbd>Ctrl+J</kbd> |

### 3. Integrated Terminal Drawer & F5 Runner
| Action | Shortcut |
|---|---|
| **Toggle Bottom Terminal Drawer** | <kbd>Ctrl+\`</kbd> or <kbd>Ctrl+J</kbd> |
| **New Terminal Instance Tab** | <kbd>Ctrl+Shift+\`</kbd> |
| **Resize Terminal Drawer Height** | <kbd>Ctrl+Up</kbd> / <kbd>Ctrl+Down</kbd> |
| **Terminal Word Jump** | <kbd>Ctrl+Left</kbd> / <kbd>Ctrl+Right</kbd> |
| **Terminal Word Delete** | <kbd>Ctrl+Backspace</kbd> |
| **Run Code (F5 Runner)** | <kbd>F5</kbd> |
| **Stop Running Code** | <kbd>Shift+F5</kbd> |

### 4. Language Server (LSP) & Refactoring
| Action | Shortcut |
|---|---|
| **Go to Definition** | <kbd>F12</kbd> (or <kbd>Ctrl+Click</kbd>) |
| **Peek Definition** | <kbd>Alt+F12</kbd> |
| **Find References** | <kbd>Shift+F12</kbd> |
| **Rename Symbol** | <kbd>F2</kbd> |
| **Quick Fix / Code Action** | <kbd>Ctrl+.</kbd> |
| **Format Document** | <kbd>Shift+Alt+F</kbd> |
| **Parameter Hints / Signature** | <kbd>Ctrl+Shift+Space</kbd> |
| **Toggle Problems Panel** | <kbd>Ctrl+Shift+M</kbd> |
| **Theme Switcher** | <kbd>Ctrl+K Ctrl+T</kbd> |
