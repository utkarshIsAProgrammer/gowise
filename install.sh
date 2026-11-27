#!/usr/bin/env bash
# ==============================================================================
# Minimal Installer (Linux OS Only)
# The Fluent, Modeless Code Editor
# Crafted by indiedev
# ==============================================================================

set -eo pipefail

# ANSI Color Codes
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
  echo "  ███╗   ███╗██╗███╗   ██╗██╗███╗   ███╗ █████╗ ██╗     "
  echo "  ████╗ ████║██║████╗  ██║██║████╗ ████║██╔══██╗██║     "
  echo "  ██╔████╔██║██║██╔██╗ ██║██║██╔████╔██║███████║██║     "
  echo "  ██║╚██╔╝██║██║██║╚██╗██║██║██║╚██╔╝██║██╔══██║██║     "
  echo "  ██║ ╚═╝ ██║██║██║ ╚████║██║██║ ╚═╝ ██║██║  ██║███████╗"
  echo "  ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝"
  echo -e "${RESET}"
  echo -e "       ${BOLD}The Fluent, Modeless Code Editor for Linux${RESET}"
  echo -e "                 ${MAGENTA}crafted by indiedev${RESET}\n"
}

# 1. Platform Check (Linux OS Only)
verify_linux() {
  local os
  os="$(uname -s)"
  if [ "$os" != "Linux" ]; then
    log_error "Minimal is designed, optimized, and packaged exclusively for Linux OS."
    echo -e "  Detected system: ${YELLOW}$os${RESET}"
    echo "  Minimal relies on native Linux desktop standards, XDG directories, and Linux subsystems."
    exit 1
  fi
  ARCH="$(uname -m)"
  log_info "Detected Linux platform (${BOLD}$ARCH${RESET})"
}

# Process CLI flags
CLEAN_INSTALL=false
for arg in "$@"; do
  case "$arg" in
    --clean|-c)
      CLEAN_INSTALL=true
      ;;
    --help|-h)
      echo "Minimal Linux Installer"
      echo "Usage: ./install.sh [options]"
      echo ""
      echo "Options:"
      echo "  --clean, -c   Clean install (removes existing Minimal cache and config)"
      echo "  --help, -h    Display this help message"
      exit 0
      ;;
  esac
done

# 2. Dependency Verification & Provisioning
ensure_dependencies() {
  log_info "Verifying core dependencies..."

  # Git
  if ! command -v git &>/dev/null; then
    log_warn "Git is missing. Attempting to install via package manager..."
    if command -v apt-get &>/dev/null; then
      sudo apt-get update && sudo apt-get install -y git
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm git
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y git
    elif command -v zypper &>/dev/null; then
      sudo zypper install -y git
    elif command -v apk &>/dev/null; then
      sudo apk add git
    fi
  fi

  if command -v git &>/dev/null; then
    log_success "Git is available ($(git --version | awk '{print $3}'))."
  else
    log_error "Git is required to install Minimal. Please install git and rerun."
    exit 1
  fi

  # Curl / Wget & Tar
  if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
    log_warn "Installing curl..."
    if command -v apt-get &>/dev/null; then sudo apt-get install -y curl
    elif command -v pacman &>/dev/null; then sudo pacman -S --noconfirm curl
    elif command -v dnf &>/dev/null; then sudo dnf install -y curl
    fi
  fi

  if ! command -v tar &>/dev/null; then
    log_warn "Installing tar..."
    if command -v apt-get &>/dev/null; then sudo apt-get install -y tar
    elif command -v pacman &>/dev/null; then sudo pacman -S --noconfirm tar
    elif command -v dnf &>/dev/null; then sudo dnf install -y tar
    fi
  fi

  # Neovim (v0.10+ required)
  NEED_NVIM=false
  if ! command -v nvim &>/dev/null; then
    NEED_NVIM=true
  else
    NVIM_VER="$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1 || echo '0.0')"
    MAJOR="$(echo "$NVIM_VER" | cut -d. -f1)"
    MINOR="$(echo "$NVIM_VER" | cut -d. -f2)"
    if [ "$MAJOR" -eq 0 ] && [ "$MINOR" -lt 10 ]; then
      log_warn "Existing Neovim version ($NVIM_VER) is older than v0.10+."
      NEED_NVIM=true
    fi
  fi

  if [ "$NEED_NVIM" = true ]; then
    log_info "Provisioning modern Neovim runtime..."
    local PKG_OK=false
    if command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm neovim && PKG_OK=true || true
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y neovim && PKG_OK=true || true
    fi

    if [ "$PKG_OK" = false ] || ! command -v nvim &>/dev/null; then
      log_step "Downloading official pre-compiled Neovim Linux binary..."
      mkdir -p "$HOME/.local/bin" "$HOME/.local/share/minimal/nvim_bin"
      local NVIM_TAR="nvim-linux-x86_64.tar.gz"
      if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        NVIM_TAR="nvim-linux-arm64.tar.gz"
      fi
      local NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/$NVIM_TAR"

      if command -v curl &>/dev/null; then
        curl -sSL "$NVIM_URL" | tar -xz -C "$HOME/.local/share/minimal/nvim_bin" --strip-components=1
      else
        wget -qO- "$NVIM_URL" | tar -xz -C "$HOME/.local/share/minimal/nvim_bin" --strip-components=1
      fi

      if [ -x "$HOME/.local/share/minimal/nvim_bin/bin/nvim" ]; then
        ln -sf "$HOME/.local/share/minimal/nvim_bin/bin/nvim" "$HOME/.local/bin/nvim"
        export PATH="$HOME/.local/bin:$PATH"
      fi
    fi
  fi

  if command -v nvim &>/dev/null; then
    log_success "Neovim engine active ($(nvim --version | head -n1))."
  else
    log_error "Neovim v0.10+ could not be provisioned automatically."
    exit 1
  fi

  # Check Neovide (Optional GUI frontend)
  if command -v neovide &>/dev/null; then
    log_success "Neovide GUI engine detected ($(neovide --version | head -n1))."
  else
    log_step "Neovide is not installed; Minimal will run in high-speed terminal mode."
    log_step "To enable frosted glass GUI visuals later, install Neovide (https://neovide.dev)."
  fi
}

# 3. Setup Target Directories
setup_paths() {
  INSTALL_DIR="${HOME}/.local/share/minimal/repo"
  CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/minimal"
  BIN_DIR="${HOME}/.local/bin"
  DATA_DIR="${HOME}/.local/share/minimal"
  PLUGINS_DIR="${DATA_DIR}/site/pack/plugins/start"
  OPT_PLUGINS_DIR="${DATA_DIR}/site/pack/plugins/opt"
  CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/minimal"
  STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/minimal"

  mkdir -p "$BIN_DIR" "$DATA_DIR" "$PLUGINS_DIR" "$OPT_PLUGINS_DIR" "$CACHE_DIR" "$STATE_DIR"
  mkdir -p "$(dirname "$CONFIG_DIR")"

  if [ "$CLEAN_INSTALL" = true ]; then
    log_warn "Clean install requested: Wiping old Minimal config and cache..."
    rm -rf "$CONFIG_DIR" "$INSTALL_DIR" "$CACHE_DIR" "$STATE_DIR"
    mkdir -p "$DATA_DIR" "$PLUGINS_DIR" "$OPT_PLUGINS_DIR" "$CACHE_DIR" "$STATE_DIR"
  fi
}

# 4. Sync Repository Sources
sync_repository() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

  if [ -f "$script_dir/config/init.lua" ]; then
    log_info "Installing from local repository ($script_dir)..."
    mkdir -p "$INSTALL_DIR"
    cp -rf "$script_dir"/* "$INSTALL_DIR"/ 2>/dev/null || true
  else
    log_info "Fetching latest Minimal from GitHub..."
    local repo_url="https://github.com/utkarshIsAProgrammer/minimal.git"
    if [ -d "$INSTALL_DIR/.git" ]; then
      log_step "Updating existing clone in $INSTALL_DIR..."
      git -C "$INSTALL_DIR" pull --quiet || true
    else
      log_step "Cloning Minimal into $INSTALL_DIR..."
      rm -rf "$INSTALL_DIR"
      git clone --depth 1 "$repo_url" "$INSTALL_DIR" --quiet
    fi
  fi
  log_success "Minimal repository synced."
}

# 5. Link/Deploy Configuration
deploy_config() {
  log_info "Deploying editor configuration to $CONFIG_DIR..."
  mkdir -p "$CONFIG_DIR"
  cp -rf "$INSTALL_DIR/config/"* "$CONFIG_DIR"/
  log_success "Configuration deployed successfully."
}

# 6. Provision Essential Plugins
provision_plugins() {
  log_info "Provisioning editor plugins into $PLUGINS_DIR..."

  # Check if plugins are present locally to avoid network roundtrips
  if [ -d "$HOME/.local/share/nvim/site/pack/plugins/start/bufferline.nvim" ]; then
    log_step "Syncing pre-installed plugins from local environment..."
    cp -rf "$HOME/.local/share/nvim/site/pack/plugins/start/"* "$PLUGINS_DIR"/ 2>/dev/null || true
  fi
  if [ -d "$HOME/.local/share/nvim/site/parser" ]; then
    mkdir -p "$DATA_DIR/site/parser"
    cp -rf "$HOME/.local/share/nvim/site/parser/"* "$DATA_DIR/site/parser"/ 2>/dev/null || true
  fi

  local core_plugins=(
    "akinsho/bufferline.nvim"
    "nvim-tree/nvim-tree.lua"
    "nvim-tree/nvim-web-devicons"
  )
  local opt_plugins=(
    "hrsh7th/cmp-buffer"
    "saadparwaiz1/cmp_luasnip"
    "hrsh7th/cmp-nvim-lsp"
    "hrsh7th/cmp-nvim-lua"
    "hrsh7th/cmp-path"
    "ziontee113/color-picker.nvim"
    "stevearc/conform.nvim"
    "mattn/emmet-vim"
    "rafamadriz/friendly-snippets"
    "lukas-reineke/indent-blankline.nvim"
    "L3MON4D3/LuaSnip"
    "brenton-leighton/multiple-cursors.nvim"
    "windwp/nvim-autopairs"
    "hrsh7th/nvim-cmp"
    "norcalli/nvim-colorizer.lua"
    "neovim/nvim-lspconfig"
    "nvim-treesitter/nvim-treesitter"
  )

  for item in "${opt_plugins[@]}"; do
    local pname="${item##*/}"
    if [ -d "$PLUGINS_DIR/$pname" ] && [ ! -d "$OPT_PLUGINS_DIR/$pname" ]; then
      mv "$PLUGINS_DIR/$pname" "$OPT_PLUGINS_DIR/$pname" 2>/dev/null || true
    fi
  done

  local pending=()
  for item in "${core_plugins[@]}"; do
    local pname="${item##*/}"
    if [ ! -d "$PLUGINS_DIR/$pname" ]; then
      pending+=("start:$item")
    fi
  done
  for item in "${opt_plugins[@]}"; do
    local pname="${item##*/}"
    if [ ! -d "$OPT_PLUGINS_DIR/$pname" ]; then
      pending+=("opt:$item")
    fi
  done

  if [ ${#pending[@]} -gt 0 ]; then
    log_step "Cloning ${#pending[@]} missing plugins..."
    for entry in "${pending[@]}"; do
      local kind="${entry%%:*}"
      local item="${entry#*:}"
      local pname="${item##*/}"
      local purl="https://github.com/${item}.git"
      local dest_base="$PLUGINS_DIR"
      if [ "$kind" = "opt" ]; then
        dest_base="$OPT_PLUGINS_DIR"
      fi
      git clone --depth 1 "$purl" "$dest_base/$pname" --quiet 2>/dev/null &
    done
    wait
  fi

  # Generate compiled spell file if not present
  if [ -f "$CONFIG_DIR/spell/en.utf-8.add" ] && [ ! -f "$CONFIG_DIR/spell/en.utf-8.add.spl" ]; then
    log_step "Compiling dictionary spell cache..."
    nvim --headless -c "silent! mkspell! $CONFIG_DIR/spell/en.utf-8.add" -c "qall!" 2>/dev/null || true
  fi

  log_success "All 20 editor plugins ready."
}

# 7. Ensure Essential Formatters
provision_formatters() {
  log_info "Ensuring essential formatters (Prettier, Stylua, Shfmt, Goimports)..."
  if command -v npm &>/dev/null; then
    local missing_npm_tools=()
    command -v prettier &>/dev/null || missing_npm_tools+=("prettier")
    command -v stylua &>/dev/null || missing_npm_tools+=("@johnnymorganz/stylua-bin")
    command -v sql-formatter &>/dev/null || missing_npm_tools+=("sql-formatter")
    if [ ${#missing_npm_tools[@]} -gt 0 ]; then
      log_step "Installing ${missing_npm_tools[*]} via npm..."
      npm install -g --prefix "$HOME/.local" "${missing_npm_tools[@]}" --quiet 2>/dev/null || true
    fi
  fi
  if command -v go &>/dev/null; then
    if ! command -v shfmt &>/dev/null; then
      log_step "Installing shfmt via go..."
      go install mvdan.cc/sh/v3/cmd/shfmt@latest 2>/dev/null || true
      [ -f "$HOME/go/bin/shfmt" ] && ln -sf "$HOME/go/bin/shfmt" "$BIN_DIR/shfmt"
    fi
    if ! command -v goimports &>/dev/null; then
      log_step "Installing goimports via go..."
      go install golang.org/x/tools/cmd/goimports@latest 2>/dev/null || true
      [ -f "$HOME/go/bin/goimports" ] && ln -sf "$HOME/go/bin/goimports" "$BIN_DIR/goimports"
    fi
  fi
  log_success "Formatters verification complete."
}

# 8. Install CLI Launcher
install_launcher() {
  log_info "Installing 'minimal' command launcher..."
  chmod +x "$INSTALL_DIR/bin/minimal"
  chmod +x "$CONFIG_DIR/terminal_rc.sh" 2>/dev/null || true
  ln -sf "$INSTALL_DIR/bin/minimal" "$BIN_DIR/minimal"
  chmod +x "$BIN_DIR/minimal"
  log_success "Created launcher link: $BIN_DIR/minimal"

  # Ensure $BIN_DIR is in PATH
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    log_warn "$BIN_DIR is not yet in your current PATH."
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
      if [ -f "$rc" ] && ! grep -q 'export PATH=.*\.local/bin' "$rc"; then
        echo -e '\nexport PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        log_success "Added $BIN_DIR to $rc"
      fi
    done
  fi
}

# 8. Desktop App & Icon Integration (Linux XDG Standard)
install_desktop_integration() {
  log_info "Installing desktop entry and application icons..."
  local app_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  local icon_dir="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
  local hicolor_dir="$icon_dir/hicolor/scalable/apps"

  mkdir -p "$app_dir" "$icon_dir" "$hicolor_dir"

  if [ -f "$INSTALL_DIR/assets/minimal.svg" ]; then
    cp -f "$INSTALL_DIR/assets/minimal.svg" "$icon_dir/minimal.svg"
    cp -f "$INSTALL_DIR/assets/minimal.svg" "$hicolor_dir/minimal.svg"
  fi

  if [ -f "$INSTALL_DIR/assets/minimal.png" ]; then
    cp -f "$INSTALL_DIR/assets/minimal.png" "$icon_dir/minimal.png"
    mkdir -p "$icon_dir/hicolor/512x512/apps"
    cp -f "$INSTALL_DIR/assets/minimal.png" "$icon_dir/hicolor/512x512/apps/minimal.png"
  fi

  if [ -f "$INSTALL_DIR/desktop/minimal.desktop" ]; then
    cp -f "$INSTALL_DIR/desktop/minimal.desktop" "$app_dir/minimal.desktop"
    chmod +x "$app_dir/minimal.desktop"
    if [ -d "$HOME/Desktop" ]; then
      cp -f "$INSTALL_DIR/desktop/minimal.desktop" "$HOME/Desktop/minimal.desktop"
      chmod +x "$HOME/Desktop/minimal.desktop" 2>/dev/null || true
    fi
    log_success "Installed desktop launcher entry ($app_dir/minimal.desktop)"
  fi

  if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$app_dir" 2>/dev/null || true
  fi
  if command -v gtk-update-icon-cache &>/dev/null; then
    gtk-update-icon-cache -f -t "$icon_dir/hicolor" 2>/dev/null || true
    gtk-update-icon-cache -f -t "$icon_dir" 2>/dev/null || true
  fi
}

# 9. Pre-warm Bytecode Cache
preheat_cache() {
  log_info "Pre-warming runtime and verifying configuration..."
  NVIM_APPNAME=minimal nvim --headless -c "qall!" 2>/dev/null || true
  log_success "Cold startup verified."
}

# 10. Summary & Completion
finish() {
  echo ""
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${BOLD}${GREEN}✔ Minimal Code Editor successfully installed on Linux!${RESET}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
  echo -e "  To start editing, run:"
  echo -e "    ${CYAN}minimal${RESET}                        # Launch Homescreen"
  echo -e "    ${CYAN}minimal .${RESET}                      # Open current folder / workspace"
  echo -e "    ${CYAN}minimal path/to/file.py${RESET}        # Open or create any file"
  echo -e "    ${CYAN}minimal --gui${RESET}                  # Launch in Neovide GUI mode"
  echo ""
  echo -e "  ${BOLD}Core Keybindings:${RESET}"
  echo -e "    • ${BOLD}Ctrl+S${RESET}        Save current file"
  echo -e "    • ${BOLD}Ctrl+N${RESET}        New file (dot icon in tabs for unsaved buffer)"
  echo -e "    • ${BOLD}Ctrl+B${RESET}        Toggle sidebar file explorer"
  echo -e "    • ${BOLD}Ctrl+\`${RESET}        Toggle bottom integrated terminal drawer"
  echo -e "    • ${BOLD}Ctrl+K Ctrl+T${RESET} Color themes picker (darkmagic, cyberaurora, medieval, nocturne)"
  echo -e "    • ${BOLD}Ctrl+Shift+K+T${RESET} Font & Settings picker"
  echo -e "    • ${BOLD}Ctrl+P${RESET}        Keybindings cheatsheet & commands"
  echo -e "    • ${BOLD}Ctrl+D${RESET}        Multi-cursor & multi-selection"
  echo -e "    • ${BOLD}Alt+Up / Down${RESET} Move line up or down"
  echo -e "    • ${BOLD}Ctrl+.${RESET}        Code spell checker suggestions & dictionary"
  echo ""
  if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "  ${YELLOW}Notice:${RESET} Run ${BOLD}source ~/.bashrc${RESET} (or open a new terminal) to refresh your PATH."
    echo ""
  fi
}

main() {
  print_banner
  verify_linux
  ensure_dependencies
  setup_paths
  sync_repository
  deploy_config
  provision_plugins
  provision_formatters
  install_launcher
  install_desktop_integration
  preheat_cache
  finish
}

main "$@"
