# Gowise Code Editor

> **The Fluent, Modeless Terminal Code Editor for All Operating Systems.**  
> Blends the speed and low-resource consumption of the terminal with the frictionless modeless editing, rich aesthetics, and polyglot power of VS Code and Zed.

---

## ⚡ Core Philosophy & Guarantees

1. **Sub-30ms Startup & Ultra-Low Resource Usage**: Uses native Neovim 0.12 JIT bytecode caching, compiled Rust/Lua plugins (`blink.cmp`, `snacks.nvim`), and deferred lazy-loading. Consumes under 40 MB RAM at idle.
2. **100% Strict OS Isolation**: Powered by `NVIM_APPNAME=gowise`. Configs, plugins, sessions, and state are isolated in `~/.config/gowise` (or `%LOCALAPPDATA%\gowise` on Windows). Never touches or interferes with Vanilla `nvim`, `minimal`, or `vsc`.
3. **Zero Host Terminal Tampering**: Never modifies your terminal emulator configs (`kitty.conf`, `ghostty.conf`, `foot.ini`, Windows Terminal). All keybindings, word jumping, and word deletions are handled internally.
4. **All OS Native**: First-class support for Linux, macOS, and Windows (via PowerShell / ConPTY).
5. **Fluent Visuals**:
   - **Rainbow Tabs**: Color-accented tab bar with dirty indicators and file icons.
   - **Green Smooth & Fluent Line**: Glowing fluent active cursor line and illuminated active scope indent guide.
   - **Rainbow Delimiters**: Color-coded nested brackets `() {} []`.
   - **Realtime Hex Colorizer**: Inline color previews for hex and CSS colors (`#00E5FF`, `#FF007F`).
   - **6 Bespoke Gowise Themes**: Handcrafted original palettes with live interactive preview.

---

## 🚀 Installation & Launch

### Linux & macOS
```bash
git clone https://github.com/your-username/gowise.git
cd gowise
./install.sh
```

### Windows (PowerShell)
```powershell
git clone https://github.com/your-username/gowise.git
cd gowise
.\install.ps1
```

### Running Gowise
```bash
# Open current directory
gowise .

# Open or create a file anywhere (auto-creates missing parent directories on save)
gowise src/api/routes/auth.go

# Check startup latency
gowise --benchmark
```

---

## 🎨 6 Signature Gowise Themes (No Clones!)

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
| **Close Tab** | <kbd>Ctrl+W</kbd> |
| **Select All** | <kbd>Ctrl+A</kbd> |
| **Copy / Cut / Paste** | <kbd>Ctrl+C</kbd> / <kbd>Ctrl+X</kbd> / <kbd>Ctrl+V</kbd> |
| **Undo / Redo** | <kbd>Ctrl+Z</kbd> / <kbd>Ctrl+Y</kbd> (or <kbd>Ctrl+Shift+Z</kbd>) |
| **Delete Line** | <kbd>Ctrl+Shift+K</kbd> |
| **Move Line Up / Down** | <kbd>Alt+Up</kbd> / <kbd>Alt+Down</kbd> |
| **Duplicate Line** | <kbd>Shift+Alt+Down</kbd> / <kbd>Shift+Alt+Up</kbd> |
| **Insert Line Below / Above** | <kbd>Ctrl+Enter</kbd> / <kbd>Ctrl+Shift+Enter</kbd> |
| **Toggle Line / Block Comment** | <kbd>Ctrl+/</kbd> / <kbd>Shift+Alt+A</kbd> |
| **Fold / Unfold Block** | <kbd>Ctrl+Shift+[</kbd> / <kbd>Ctrl+Shift+]</kbd> |
| **Multi-Cursor (Next Match)** | <kbd>Ctrl+D</kbd> |

### 2. Navigation & Exact Word Movement
| Action | Shortcut |
|---|---|
| **Jump Word Left / Right** | <kbd>Ctrl+Left</kbd> / <kbd>Ctrl+Right</kbd> |
| **Delete Word Left / Right** | <kbd>Ctrl+Backspace</kbd> / <kbd>Ctrl+Delete</kbd> |
| **Select by Character** | <kbd>Shift+Left</kbd> / <kbd>Shift+Right</kbd> / <kbd>Shift+Up/Down</kbd> |
| **Select to Line Start / End** | <kbd>Shift+Home</kbd> / <kbd>Shift+End</kbd> |
| **Quick Open File** | <kbd>Ctrl+P</kbd> |
| **Command Palette** | <kbd>Ctrl+Shift+P</kbd> |
| **Find in Current File** | <kbd>Ctrl+F</kbd> |
| **Global Search (Live Grep)** | <kbd>Ctrl+Shift+F</kbd> |
| **Toggle File Explorer Sidebar** | <kbd>Ctrl+B</kbd> |

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
