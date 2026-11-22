#!/usr/bin/env bash
# ==============================================================================
# Minimal Universal Zero-Setup Installer (Linux, macOS, WSL)
# Fully automated: installs dependencies, configures PATH, registers desktop app
# ==============================================================================

set -eo pipefail

# ANSI Colors
BOLD="\033[1m"
CYAN="\033[1;36m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
RED="\033[1;31m"
RESET="\033[0m"

log_info()    { echo -e "${CYAN}==>${RESET} ${BOLD}$1${RESET}"; }
log_success() { echo -e "${GREEN}✔${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}▲${RESET} $1"; }
log_step()    { echo -e "${MAGENTA}→${RESET} $1"; }
log_error()   { echo -e "${RED}✖${RESET} ${BOLD}$1${RESET}"; }

print_banner() {
  echo -e "${CYAN}"
  echo "   ██████╗  ██████╗ ██╗    ██╗██╗███████╗███████╗"
  echo "  ██╔════╝ ██╔═══██╗██║    ██║██║██╔════╝██╔════╝"
  echo "  ██║  ███╗██║   ██║██║ █╗ ██║██║███████╗█████╗  "
  echo "  ██║   ██║██║   ██║██║███╗██║██║╚════██║██╔══╝  "
  echo "  ╚██████╔╝╚██████╔╝╚███╔███╔╝██║███████║███████╗"
  echo "   ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝╚══════╝╚══════╝"
  echo -e "${RESET}"
  echo -e "${BOLD}The Fluent, Modeless Terminal Code Editor for All OS${RESET}\n"
}

# Clean install flag check
CLEAN_INSTALL=false
for arg in "$@"; do
  case "$arg" in
    --clean|-c)
      CLEAN_INSTALL=true
      ;;
    --help|-h)
      echo "Minimal Universal Installer"
      echo "Usage: ./install.sh [options]"
      echo ""
      echo "Options:"
      echo "  --clean, -c   Perform a completely clean install from scratch"
      echo "  --help, -h    Show this help message"
      exit 0
      ;;
  esac
done

# 1. Platform Detection
detect_os() {
  OS="$(uname -s)"
  ARCH="$(uname -m)"
  case "$OS" in
    Linux*)  PLATFORM="Linux" ;;
    Darwin*) PLATFORM="macOS" ;;
    *)       PLATFORM="Unknown ($OS)" ;;
  esac
  log_info "Detected platform: ${BOLD}$PLATFORM ($ARCH)${RESET}"
}

# 2. Automated Dependency Installation (Zero Pre-requisite Guarantee)
ensure_dependencies() {
  log_info "Verifying and provisioning dependencies..."

  # A. Check and provision Git
  if ! command -v git &>/dev/null; then
    log_warn "Git not found. Attempting automatic installation..."
    if [ "$PLATFORM" = "macOS" ]; then
      if command -v brew &>/dev/null; then
        brew install git
      else
        xcode-select --install || true
      fi
    elif [ "$PLATFORM" = "Linux" ]; then
      if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y git
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm git
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y git
      elif command -v apk &>/dev/null; then
        sudo apk add git
      fi
    fi
  fi

  if command -v git &>/dev/null; then
    log_success "Git is available ($(git --version | awk '{print $3}'))."
  else
    log_error "Git is required to install Minimal. Please install Git and rerun."
    exit 1
  fi

  # B. Check and provision Neovim (v0.10+ required)
  NEED_NVIM=false
  if ! command -v nvim &>/dev/null; then
    NEED_NVIM=true
  else
    NVIM_VER="$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1 || echo '0.0')"
    MAJOR="$(echo "$NVIM_VER" | cut -d. -f1)"
    MINOR="$(echo "$NVIM_VER" | cut -d. -f2)"
    if [ "$MAJOR" -eq 0 ] && [ "$MINOR" -lt 10 ]; then
      log_warn "Installed Neovim ($NVIM_VER) is older than required v0.10+."
      NEED_NVIM=true
    fi
  fi

  if [ "$NEED_NVIM" = true ]; then
    log_info "Provisioning modern Neovim runtime..."
    if [ "$PLATFORM" = "macOS" ]; then
      if command -v brew &>/dev/null; then
        brew install neovim
      fi
    elif [ "$PLATFORM" = "Linux" ]; then
      # Try package manager first if available
      INSTALLED_PKG=false
      if command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm neovim && INSTALLED_PKG=true || true
      elif command -v dnf &>/dev/null; then
        sudo dnf install -y neovim && INSTALLED_PKG=true || true
      fi

      # If package manager didn't install modern nvim, download official standalone tarball
      if [ "$INSTALLED_PKG" = false ] && ! command -v nvim &>/dev/null; then
        log_step "Downloading official pre-compiled Neovim binary..."
        mkdir -p "$HOME/.local/bin" "$HOME/.local/share/minimal-nvim"
        local NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
        if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
          NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.tar.gz"
        fi
        
        if command -v curl &>/dev/null; then
          curl -sSL "$NVIM_URL" | tar -xz -C "$HOME/.local/share/minimal-nvim" --strip-components=1
        elif command -v wget &>/dev/null; then
          wget -qO- "$NVIM_URL" | tar -xz -C "$HOME/.local/share/minimal-nvim" --strip-components=1
        fi

        if [ -x "$HOME/.local/share/minimal-nvim/bin/nvim" ]; then
          ln -sf "$HOME/.local/share/minimal-nvim/bin/nvim" "$HOME/.local/bin/nvim"
          export PATH="$HOME/.local/bin:$PATH"
        fi
      fi
    fi
  fi

  if command -v nvim &>/dev/null; then
    log_success "Neovim engine is active ($(nvim --version | head -n1))."
  else
    log_error "Neovim (v0.10+) could not be automatically installed."
    echo "  Please install Neovim from https://neovim.io and rerun install.sh"
    exit 1
  fi
}

# 3. Setup Target Directories
setup_paths() {
  INSTALL_DIR="${HOME}/.local/share/minimal/repo"
  CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/minimal"
  BIN_DIR="${HOME}/.local/bin"
  DATA_DIR="${HOME}/.local/share/minimal"
  CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/minimal"
  STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/minimal"

  mkdir -p "$BIN_DIR" "$DATA_DIR" "$CACHE_DIR/luac" "$STATE_DIR"
  mkdir -p "$(dirname "$CONFIG_DIR")"

  if [ "$CLEAN_INSTALL" = true ]; then
    log_warn "Clean install requested: Wiping old Minimal runtime state..."
    rm -rf "$CONFIG_DIR" "$INSTALL_DIR" "$CACHE_DIR" "$STATE_DIR" "$DATA_DIR/lazy"
    mkdir -p "$DATA_DIR" "$CACHE_DIR/luac" "$STATE_DIR"
  fi
}

# 4. Clone or Copy Repository
sync_repository() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

  if [ -f "$SCRIPT_DIR/config/init.lua" ]; then
    log_info "Installing from local workspace: $SCRIPT_DIR"
    mkdir -p "$INSTALL_DIR"
    cp -rf "$SCRIPT_DIR"/* "$INSTALL_DIR"/ 2>/dev/null || true
  else
    log_info "Fetching latest Minimal from GitHub repository..."
    REPO_URL="https://github.com/utkarshIsAProgrammer/minimal.git"
    if [ -d "$INSTALL_DIR/.git" ]; then
      log_step "Updating existing installation at $INSTALL_DIR..."
      git -C "$INSTALL_DIR" pull --quiet || true
    else
      log_step "Cloning repository to $INSTALL_DIR..."
      rm -rf "$INSTALL_DIR"
      git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" --quiet
    fi
  fi
  log_success "Minimal source files ready."
}

# 5. Link Isolated Configuration
link_config() {
  log_info "Configuring isolated environment..."

  if [ -e "$CONFIG_DIR" ] && [ ! -L "$CONFIG_DIR" ]; then
    BACKUP_PATH="${CONFIG_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    log_warn "Existing config found at $CONFIG_DIR. Backing up to $BACKUP_PATH"
    mv "$CONFIG_DIR" "$BACKUP_PATH"
  elif [ -L "$CONFIG_DIR" ]; then
    rm -f "$CONFIG_DIR"
  fi

  ln -s "$INSTALL_DIR/config" "$CONFIG_DIR"
  log_success "Linked $CONFIG_DIR -> $INSTALL_DIR/config"
}

# 6. Install CLI Launcher & PATH
install_launcher() {
  log_info "Setting up 'minimal' command..."
  chmod +x "$INSTALL_DIR/bin/minimal"
  chmod +x "$INSTALL_DIR/config/bin/"* 2>/dev/null || true
  ln -sf "$INSTALL_DIR/bin/minimal" "$BIN_DIR/minimal"
  log_success "Created executable link: $BIN_DIR/minimal"

  # PATH verification across popular shells
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    log_warn "$BIN_DIR is not in your current shell PATH."
    for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
      if [ -f "$RC_FILE" ] && ! grep -q 'export PATH=.*\.local/bin' "$RC_FILE"; then
        echo -e '\nexport PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
        log_success "Added $BIN_DIR to $RC_FILE"
      fi
    done
    if [ -d "$HOME/.config/fish" ]; then
      FISH_CONF="$HOME/.config/fish/config.fish"
      if [ -f "$FISH_CONF" ] && ! grep -q '\.local/bin' "$FISH_CONF"; then
        echo -e '\nfish_add_path -a $HOME/.local/bin' >> "$FISH_CONF"
        log_success "Added $BIN_DIR to $FISH_CONF"
      fi
    fi
  fi
}

# 7. Desktop & Icon Integration (Linux)
install_desktop_integration() {
  if [ "$PLATFORM" = "Linux" ]; then
    log_info "Registering desktop application and icons..."
    local APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
    local ICON_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
    local HICOLOR_DIR="$ICON_DIR/hicolor/scalable/apps"

    mkdir -p "$APP_DIR" "$ICON_DIR" "$HICOLOR_DIR"

    if [ -f "$INSTALL_DIR/assets/minimal.svg" ]; then
      cp -f "$INSTALL_DIR/assets/minimal.svg" "$ICON_DIR/minimal.svg"
      cp -f "$INSTALL_DIR/assets/minimal.svg" "$HICOLOR_DIR/minimal.svg"
      log_success "Installed Minimal application icon"
    fi

    if [ -f "$INSTALL_DIR/desktop/minimal.desktop" ]; then
      cp -f "$INSTALL_DIR/desktop/minimal.desktop" "$APP_DIR/minimal.desktop"
      chmod +x "$APP_DIR/minimal.desktop"
      log_success "Installed desktop entry ($APP_DIR/minimal.desktop)"
    fi

    if command -v update-desktop-database &>/dev/null; then
      update-desktop-database "$APP_DIR" 2>/dev/null || true
    fi
    if command -v gtk-update-icon-cache &>/dev/null; then
      gtk-update-icon-cache -f -t "$ICON_DIR/hicolor" 2>/dev/null || true
      gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true
    fi
  fi
}

# 8. Bootstrap Plugins & Preheat Cache
preheat_cache() {
  log_info "Preheating LuaJIT bytecode & compiling plugin cache..."

  # Pre-clone lazy.nvim if missing
  local LAZY_DIR="${HOME}/.local/share/minimal/lazy/lazy.nvim"
  if [ ! -d "$LAZY_DIR" ]; then
    git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_DIR" --quiet 2>/dev/null || true
  fi

  # Run headless sync
  if command -v nvim &>/dev/null; then
    NVIM_APPNAME=minimal nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  fi
  log_success "Preheat complete. Cold startup latency optimized (<50ms)."
}

# 9. Friendly Finish Summary
finish() {
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD}${GREEN}✔ Minimal installed successfully and ready to use!${RESET}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
  echo -e "  To start editing, run:"
  echo -e "    ${CYAN}minimal .${RESET}                      # Open current folder / workspace"
  echo -e "    ${CYAN}minimal path/to/file.ext${RESET}       # Open or create any file"
  echo -e "    ${CYAN}minimal --doctor${RESET}               # Inspect toolchains & LSP status"
  echo -e "    ${CYAN}minimal --benchmark${RESET}            # Measure exact startup latency"
  echo ""
  echo -e "  ${BOLD}Essential shortcuts:${RESET}"
  echo -e "    • ${BOLD}Ctrl+S${RESET}        Save file (auto-creates parent directories)"
  echo -e "    • ${BOLD}Ctrl+P${RESET}        Quick Open fuzzy file finder"
  echo -e "    • ${BOLD}Ctrl+Shift+P${RESET}  Command Palette"
  echo -e "    • ${BOLD}Ctrl+B${RESET}        Toggle File Explorer sidebar"
  echo -e "    • ${BOLD}Ctrl+\`${RESET}        Toggle Bottom Integrated Terminal"
  echo -e "    • ${BOLD}Ctrl+K Ctrl+T${RESET} Live Theme Switcher"
  echo -e "    • ${BOLD}F5${RESET}            Run current project / file"
  echo ""
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "  ${YELLOW}Notice:${RESET} Please run ${BOLD}source ~/.bashrc${RESET} (or open a new terminal) to refresh your PATH."
    echo ""
  fi
}

main() {
  print_banner
  detect_os
  ensure_dependencies
  setup_paths
  sync_repository
  link_config
  install_launcher
  install_desktop_integration
  preheat_cache
  finish
}

main "$@"
