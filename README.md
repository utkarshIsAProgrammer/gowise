# Gowise Code Editor

> **The Fluent, Modeless Terminal Code Editor for All Operating Systems.**  
> Blends the blazing speed (<50ms startup) and low resource footprint of the terminal with the modeless editing, rich aesthetics, and polyglot power of modern graphical IDEs like VS Code and Zed.

---

## ⚡ Core Philosophy & Guarantees

1. **Sub-50ms Cold Startup & Low Resource Usage**: Uses native Neovim 0.12 LuaJIT bytecode caching, compiled C/Rust plugins (`blink.cmp`, `snacks.nvim`), and intelligent event deferral. Starts in **~48ms** and runs comfortably under 40 MB RAM.
2. **100% Strict OS Isolation**: Powered by `NVIM_APPNAME=gowise`. Configs, plugins, sessions, and state are isolated in `~/.config/gowise` (or `%LOCALAPPDATA%\gowise` on Windows). Never interferes with your vanilla `nvim` or other configurations.
3. **Zero Host Terminal Tampering**: Never modifies your terminal emulator configs (`kitty.conf`, `ghostty.conf`, `foot.ini`, Windows Terminal). Word jumping, selection, and modeless navigation are handled natively by the editor.
4. **Universal All-OS Support**: First-class, zero-prerequisite installer for Linux (Debian, Ubuntu, Arch, Fedora, Alpine, Void), macOS (Intel & Apple Silicon), WSL, and Windows.
5. **Zero-Nest Terminal RPC Client**: Running `gowise <file>`, `nvim <file>`, or `code <file>` inside the integrated terminal drawer forwards the file directly to a new tab in the parent editor window instead of launching a nested Neovim process.
6. **Fluent Visuals**:
   - **Rainbow Tabs**: Color-accented tab bar with dirty indicators and filetype icons.
   - **Green Smooth & Fluent Cursor**: Modeless vertical beam (`ver25`) with active scope indent guidance.
   - **Breadcrumbs Winbar**: Instant directory path navigation with file icons.
   - **Realtime Hex Colorizer**: Inline color previews for hex and CSS colors (`#00E5FF`, `#FF007F`).
   - **6 Bespoke Gowise Themes**: Handcrafted original palettes with live interactive switcher.

---

## 🚀 Universal One-Line Installation

Install Gowise on any operating system with a single command. The installer automatically provisions dependencies, compiles the plugin cache, and registers the application.

### 🐧 Linux & 🍏 macOS & 🐧 WSL (One-Liner)
```bash
curl -fsSL https://raw.githubusercontent.com/utkarshIsAProgrammer/gowise/main/install.sh | bash
```
*(Or with `wget`: `wget -qO- https://raw.githubusercontent.com/utkarshIsAProgrammer/gowise/main/install.sh | bash`)*

### 🪟 Windows (PowerShell One-Liner)
Open PowerShell (as normal user) and run:
```powershell
irm https://raw.githubusercontent.com/utkarshIsAProgrammer/gowise/main/install.ps1 | iex
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
   If you already have Gowise and want to test a 100% clean installation from scratch:
   - **Linux / macOS**:
     ```bash
     curl -fsSL https://raw.githubusercontent.com/utkarshIsAProgrammer/gowise/main/install.sh | bash -s -- --clean
     ```
   - **Windows**:
     ```powershell
     & ([scriptblock]::Create((irm https://raw.githubusercontent.com/utkarshIsAProgrammer/gowise/main/install.ps1))) -Clean
     ```
3. **Desktop & Application Launcher Integration**:
   - On Linux, Gowise is registered with your desktop environment (`~/.local/share/applications/gowise.desktop`) and app grid with a dedicated HD vector icon.
   - On Windows, a **Gowise** shortcut is automatically placed in your Windows Start Menu.

---

## 💻 Running Gowise

```bash
# Open current directory / workspace
gowise .

# Open or create a file anywhere (auto-creates parent directories on save)
gowise src/api/routes/auth.go

# Inspect system health and language compilers
gowise --doctor

# Benchmark exact startup latency in milliseconds
gowise --benchmark
```

---

## 🧹 Clean Uninstallation

If you ever wish to remove Gowise, it cleans up all its symlinks, cache, and state, leaving your system completely untouched:

- **Linux / macOS**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/utkarshIsAProgrammer/gowise/main/uninstall.sh | bash -s -- -y
  ```
- **Windows**:
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/utkarshIsAProgrammer/gowise/main/uninstall.ps1))) -Force
  ```

---

## 🎨 6 Signature Gowise Themes

Open the live theme previewer anytime with <kbd>Ctrl+K Ctrl+T</kbd> or through the Command Palette:

1. **Gowise Obsidian Void** (Default): Pure deep space black (`#090B10`), electric cyan, vivid purple, and mint green.
2. **Gowise Aurora Teal**: Nordic deep sea (`#0B151C`), glacier mist, emerald aurora, and starlight amber.
3. **Gowise Cyber Synth**: Neon dark matter (`#120E1E`), laser magenta, hyper cyan, and electric lime.
4. **Gowise Monolith Titanium**: Brushed graphite (`#121417`), chilled steel, cobalt blue, and emerald accents.
5. **Gowise Velvet Espresso**: Roasted mocha (`#141115`), warm milk, tangerine flame, and soft amethyst.
6. **Gowise Cobalt Nebula**: Deep cosmic navy (`#0A0E1A`), starlit silver, indigo ray, and ruby laser.

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
