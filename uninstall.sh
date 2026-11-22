#!/usr/bin/env bash
# ==============================================================================
# Minimal Clean Uninstaller (Linux, macOS & WSL)
# Safely removes all Minimal symlinks, configs, desktop entries, and plugin cache
# ==============================================================================

set -e

BOLD="\033[1m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

NON_INTERACTIVE=false
for arg in "$@"; do
  case "$arg" in
    -y|--yes|-f|--force)
      NON_INTERACTIVE=true
      ;;
  esac
done

echo -e "${YELLOW}==>${RESET} ${BOLD}Minimal Uninstaller${RESET}"
echo "This will safely and completely remove Minimal from your system."

if [ "$NON_INTERACTIVE" = false ]; then
  read -p "Are you sure you want to proceed? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
  fi
fi

# 1. Remove CLI symlink
if [ -L "$HOME/.local/bin/minimal" ] || [ -f "$HOME/.local/bin/minimal" ]; then
  rm -f "$HOME/.local/bin/minimal"
  echo -e "  ${GREEN}✔${RESET} Removed executable link: ~/.local/bin/minimal"
fi

# 2. Remove Config link
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/minimal"
if [ -L "$CONFIG_DIR" ] || [ -d "$CONFIG_DIR" ]; then
  rm -rf "$CONFIG_DIR"
  echo -e "  ${GREEN}✔${RESET} Removed configuration: $CONFIG_DIR"
fi

# 3. Remove Data, State, and Cache
rm -rf "$HOME/.local/share/minimal"
rm -rf "$HOME/.local/state/minimal"
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/minimal"
echo -e "  ${GREEN}✔${RESET} Purged plugin data, state, and bytecode cache"

# 4. Remove Desktop Integration & Icons
APP_ENTRY="${XDG_DATA_HOME:-$HOME/.local/share}/applications/minimal.desktop"
if [ -f "$APP_ENTRY" ]; then
  rm -f "$APP_ENTRY"
  echo -e "  ${GREEN}✔${RESET} Removed desktop entry: $APP_ENTRY"
fi

rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/minimal.svg"
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/minimal.svg"

if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "${XDG_DATA_HOME:-$HOME/.local/share}/applications" 2>/dev/null || true
fi

echo -e "\n${BOLD}${GREEN}✔ Minimal has been completely removed from your system.${RESET}"
echo "Thank you for trying Minimal!"
