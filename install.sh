#!/usr/bin/env bash
# ==============================================================================
# Gowise Installer (Linux & macOS)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_PATH="$SCRIPT_DIR/bin/gowise"
TARGET_BIN="${HOME}/.local/bin"

echo -e "\033[1;36m==> Installing Gowise Code Editor...\033[0m"

# Ensure ~/.local/bin exists
mkdir -p "$TARGET_BIN"
chmod +x "$BIN_PATH"

# Symlink launcher
ln -sf "$BIN_PATH" "$TARGET_BIN/gowise"

# Ensure config directory symlink
USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/gowise"
mkdir -p "$(dirname "$USER_CONFIG")"
ln -sf "$SCRIPT_DIR/config" "$USER_CONFIG"

echo -e "\033[1;32m✔ Gowise installed successfully!\033[0m"
echo ""
echo "You can now run: gowise"
echo "(Make sure $TARGET_BIN is in your PATH)"
