#!/usr/bin/env bash
# ==============================================================================
# Gowise Clean Uninstaller (Linux & macOS)
# Removes all Gowise symlinks, configs, and plugins safely
# ==============================================================================

set -e

BOLD="\033[1m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

echo -e "${YELLOW}==>${RESET} ${BOLD}Gowise Uninstaller${RESET}"
echo "This will safely remove Gowise from your system."
read -p "Are you sure you want to proceed? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Uninstallation cancelled."
  exit 0
fi

# 1. Remove CLI symlink
if [ -L "$HOME/.local/bin/gowise" ]; then
  rm -f "$HOME/.local/bin/gowise"
  echo -e "${GREEN}✔${RESET} Removed ~/.local/bin/gowise"
fi

# 2. Remove Config link
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/gowise"
if [ -L "$CONFIG_DIR" ]; then
  rm -f "$CONFIG_DIR"
  echo -e "${GREEN}✔${RESET} Removed config symlink at $CONFIG_DIR"
elif [ -d "$CONFIG_DIR" ]; then
  BACKUP="$CONFIG_DIR.uninstalled.$(date +%Y%m%d%H%M%S)"
  mv "$CONFIG_DIR" "$BACKUP"
  echo -e "${GREEN}✔${RESET} Backed up user config to $BACKUP"
fi

# 3. Remove Data and Cache
rm -rf "$HOME/.local/share/gowise"
rm -rf "$HOME/.local/state/gowise"
rm -rf "$HOME/.cache/gowise"
echo -e "${GREEN}✔${RESET} Cleaned data, state, and cache directories."

echo -e "\n${BOLD}${GREEN}✔ Gowise has been completely removed from your system.${RESET}"
echo "Thank you for trying Gowise!"
