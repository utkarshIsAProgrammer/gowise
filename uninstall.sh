#!/usr/bin/env bash
# ==============================================================================
# Minimal Uninstaller (Linux OS Only)
# Safely removes Minimal editor links, configs, desktop entries, and cache
# ==============================================================================

set -eo pipefail

BOLD="\033[1m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

# Linux OS check
if [ "$(uname -s)" != "Linux" ]; then
  echo -e "${RED}✖ Error: Minimal uninstaller is for Linux OS only.${RESET}"
  exit 1
fi

NON_INTERACTIVE=false
for arg in "$@"; do
  case "$arg" in
    -y|--yes|-f|--force)
      NON_INTERACTIVE=true
      ;;
    -h|--help)
      echo "Minimal Linux Uninstaller"
      echo "Usage: ./uninstall.sh [options]"
      echo ""
      echo "Options:"
      echo "  -y, --yes, -f, --force   Non-interactive uninstall without prompt"
      echo "  -h, --help               Display this help message"
      exit 0
      ;;
  esac
done

echo -e "${CYAN}==>${RESET} ${BOLD}Minimal Linux Uninstaller${RESET}"
echo "This will safely and completely remove Minimal from your system."

if [ "$NON_INTERACTIVE" = false ]; then
  read -p "Are you sure you want to remove Minimal? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstallation cancelled."
    exit 0
  fi
fi

# 1. Remove CLI launcher
if [ -L "$HOME/.local/bin/minimal" ] || [ -f "$HOME/.local/bin/minimal" ]; then
  rm -f "$HOME/.local/bin/minimal"
  echo -e "  ${GREEN}✔${RESET} Removed launcher link: ~/.local/bin/minimal"
fi

# 2. Remove Config directory
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/minimal"
if [ -L "$CONFIG_DIR" ] || [ -d "$CONFIG_DIR" ]; then
  rm -rf "$CONFIG_DIR"
  echo -e "  ${GREEN}✔${RESET} Removed configuration: $CONFIG_DIR"
fi

# 3. Remove Data, Plugins, State, and Cache
rm -rf "$HOME/.local/share/minimal"
rm -rf "$HOME/.local/state/minimal"
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/minimal"
echo -e "  ${GREEN}✔${RESET} Purged data, plugins, and cache"

# 4. Remove Desktop Integration & Icons
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
if [ -f "$APP_DIR/minimal.desktop" ]; then
  rm -f "$APP_DIR/minimal.desktop"
  echo -e "  ${GREEN}✔${RESET} Removed application desktop entry"
fi
if [ -f "$HOME/Desktop/minimal.desktop" ]; then
  rm -f "$HOME/Desktop/minimal.desktop"
  echo -e "  ${GREEN}✔${RESET} Removed desktop shortcut"
fi

rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/minimal.png"
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/minimal.svg"
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/scalable/apps/minimal.svg"
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor/512x512/apps/minimal.png"
echo -e "  ${GREEN}✔${RESET} Removed application icons"

if command -v update-desktop-database &>/dev/null; then
  update-desktop-database "$APP_DIR" 2>/dev/null || true
fi
if command -v gtk-update-icon-cache &>/dev/null; then
  gtk-update-icon-cache -f -t "${XDG_DATA_HOME:-$HOME/.local/share}/icons" 2>/dev/null || true
fi

echo -e "\n${BOLD}${GREEN}✔ Minimal has been completely uninstalled from your Linux system.${RESET}"
