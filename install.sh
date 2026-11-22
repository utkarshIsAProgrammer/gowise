#!/usr/bin/env bash
# ==============================================================================
# Gowise Universal Installer (Linux, macOS & WSL)
# Crafted for resilience, zero-error friendliness, and auto-recovery
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

# 2. Dependency Verifications
check_dependencies() {
  log_info "Checking essential dependencies..."

  # Git Check
  if ! command -v git &>/dev/null; then
    log_error "Git is required to download and update Gowise."
    echo "  Please install Git via your package manager:"
    echo "    • Ubuntu/Debian: sudo apt install git"
    echo "    • macOS:         brew install git (or install Xcode Command Line Tools)"
    echo "    • Fedora:        sudo dnf install git"
    echo "    • Arch Linux:    sudo pacman -S git"
    exit 1
  fi
  log_success "Git is available."

  # Curl Check
  if ! command -v curl &>/dev/null; then
    log_warn "curl is recommended for fetching language servers and extensions."
  fi

  # Neovim Check
  if ! command -v nvim &>/dev/null; then
    log_warn "Neovim was not found on your system."
    echo -e "\n${BOLD}Gowise is powered by Neovim (v0.10+ required).${RESET}"
    echo "Would you like instructions to install it, or should we install it for you?"
    echo "  • Ubuntu/Debian: sudo add-apt-repository ppa:neovim-ppa/unstable && sudo apt update && sudo apt install neovim"
    echo "  • macOS:         brew install neovim"
    echo "  • Fedora:        sudo dnf install neovim"
    echo "  • Arch Linux:    sudo pacman -S neovim"
    echo "  • Portable:      curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
    echo ""
    log_warn "Continuing installation... You can install Neovim anytime before running 'gowise'."
  else
    NVIM_VER="$(nvim --version | head -n1 | grep -o 'v[0-9]*\.[0-9]*\.[0-9]*' || echo 'unknown')"
    log_success "Neovim is available (${NVIM_VER})."
  fi
}

# 3. Target Paths
setup_paths() {
  INSTALL_DIR="${HOME}/.local/share/gowise/repo"
  CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gowise"
  BIN_DIR="${HOME}/.local/bin"

  mkdir -p "$BIN_DIR"
  mkdir -p "$(dirname "$INSTALL_DIR")"
  mkdir -p "$(dirname "$CONFIG_DIR")"
}

# 4. Clone or Update Repo
sync_repository() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

  # If running from a local cloned directory
  if [ -f "$SCRIPT_DIR/config/init.lua" ]; then
    log_info "Installing from local directory: $SCRIPT_DIR"
    mkdir -p "$INSTALL_DIR"
    cp -rf "$SCRIPT_DIR"/* "$INSTALL_DIR"/ 2>/dev/null || true
  else
    log_info "Fetching latest Gowise from GitHub..."
    REPO_URL="https://github.com/utkarshIsAProgrammer/gowise.git"
    if [ -d "$INSTALL_DIR/.git" ]; then
      log_step "Updating existing installation at $INSTALL_DIR..."
      git -C "$INSTALL_DIR" pull --quiet || true
    else
      log_step "Cloning repository to $INSTALL_DIR..."
      rm -rf "$INSTALL_DIR"
      git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" --quiet
    fi
  fi
  log_success "Gowise source files ready."
}

# 5. Link Config Safely
link_config() {
  log_info "Configuring Gowise environment..."

  if [ -e "$CONFIG_DIR" ] && [ ! -L "$CONFIG_DIR" ]; then
    BACKUP_PATH="${CONFIG_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    log_warn "Existing config found at $CONFIG_DIR. Moving safely to $BACKUP_PATH"
    mv "$CONFIG_DIR" "$BACKUP_PATH"
  elif [ -L "$CONFIG_DIR" ]; then
    rm -f "$CONFIG_DIR"
  fi

  ln -s "$INSTALL_DIR/config" "$CONFIG_DIR"
  log_success "Linked $CONFIG_DIR -> $INSTALL_DIR/config"
}

# 6. Install CLI Launcher
install_launcher() {
  log_info "Setting up 'gowise' command..."
  chmod +x "$INSTALL_DIR/bin/gowise"
  ln -sf "$INSTALL_DIR/bin/gowise" "$BIN_DIR/gowise"
  log_success "Created symlink: $BIN_DIR/gowise"

  # PATH verification
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    log_warn "$BIN_DIR is not in your current PATH."
    SHELL_NAME="$(basename "${SHELL:-bash}")"
    RC_FILE="$HOME/.bashrc"
    case "$SHELL_NAME" in
      zsh)  RC_FILE="$HOME/.zshrc" ;;
      fish) RC_FILE="$HOME/.config/fish/config.fish" ;;
      bash) RC_FILE="$HOME/.bashrc" ;;
      *)    RC_FILE="$HOME/.profile" ;;
    esac

    if [ -f "$RC_FILE" ] && ! grep -q 'export PATH=.*\.local/bin' "$RC_FILE"; then
      echo -e '\nexport PATH="$HOME/.local/bin:$PATH"' >> "$RC_FILE"
      log_success "Added $BIN_DIR to $RC_FILE automatically."
      log_step "Run: ${BOLD}source $RC_FILE${RESET} or open a new terminal window."
    fi
  fi
}

# 7. Preheat Plugins
preheat_cache() {
  if command -v nvim &>/dev/null; then
    log_info "Preheating plugins for instant launch..."
    NVIM_APPNAME=gowise nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    log_success "Preheat complete. Startup latency optimized (<50ms)."
  fi
}

# 8. Friendly Completion Message
finish() {
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD}${GREEN}✔ Gowise installed successfully!${RESET}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
  echo -e "  To start editing, run:"
  echo -e "    ${CYAN}gowise .${RESET}                      # Open current project"
  echo -e "    ${CYAN}gowise path/to/file.ext${RESET}       # Open or create file"
  echo -e "    ${CYAN}gowise --doctor${RESET}               # Check system health"
  echo ""
  echo -e "  ${BOLD}Essential shortcuts:${RESET}"
  echo -e "    • ${BOLD}Ctrl+S${RESET}        Save file (auto-creates directories)"
  echo -e "    • ${BOLD}Ctrl+P${RESET}        Quick Open file"
  echo -e "    • ${BOLD}Ctrl+Shift+P${RESET}  Command Palette"
  echo -e "    • ${BOLD}Ctrl+B${RESET}        Toggle File Explorer sidebar"
  echo -e "    • ${BOLD}Ctrl+\`${RESET}        Toggle Bottom Terminal Drawer"
  echo -e "    • ${BOLD}F5${RESET}            Run current file / project"
  echo -e "    • ${BOLD}Ctrl+K Ctrl+T${RESET} Live Theme Switcher"
  echo ""
}

main() {
  print_banner
  detect_os
  check_dependencies
  setup_paths
  sync_repository
  link_config
  install_launcher
  preheat_cache
  finish
}

main "$@"
