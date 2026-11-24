#!/usr/bin/env bash

export SHELL=/bin/bash
export TERM=xterm-256color
export COLORTERM=truecolor
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
unset KITTY_PID KITTY_WINDOW_ID KITTY_PUBLIC_KEY KITTY_INSTALLATION_DIR TERMINFO STARSHIP_SHELL ZDOTDIR ZSH_AUTOSUGGEST_STRATEGY

# Source user's standard bashrc (paths/aliases/options) while skipping Zsh/Kitty prompt/line-editor shims
if [ -f "$HOME/.bashrc" ]; then
  if grep -qE 'blesh/ble\.sh|ble-attach|starship init bash' "$HOME/.bashrc" 2>/dev/null; then
    source <(sed -E \
      -e 's#^([[:space:]]*)(source|\.)[[:space:]]+.*blesh/ble\.sh.*#\1:#' \
      -e 's#^([[:space:]]*)ble-attach.*#\1:#' \
      -e 's#^([[:space:]]*)eval "\$\(starship init bash\)".*#\1:#' \
      "$HOME/.bashrc")
  else
    source "$HOME/.bashrc"
  fi
fi

# Re-assert Bash environment and reload pure Bash history
export SHELL=/bin/bash
export HISTFILE="$HOME/.bash_history"
shopt -s histappend 2>/dev/null || true
history -c
if [ -f "$HISTFILE" ]; then
  history -r "$HISTFILE"
fi

# Ensure standard Backspace and Ctrl+Arrows / Ctrl+Backspace / Ctrl+Delete work reliably in Bash readline
bind '"\C-?": backward-delete-char' 2>/dev/null || true
bind '"\e[1;5D": backward-word' 2>/dev/null || true
bind '"\e[1;5C": forward-word' 2>/dev/null || true
bind '"\e[3;5~": kill-word' 2>/dev/null || true
bind '"\e[127;5u": backward-kill-word' 2>/dev/null || true
bind '"\e\x7f": backward-kill-word' 2>/dev/null || true
bind '"\eb": backward-word' 2>/dev/null || true
bind '"\ef": forward-word' 2>/dev/null || true
bind '"\ed": kill-word' 2>/dev/null || true

# Unset any prompt commanders from external tools to ensure clean git profile
unset PROMPT_COMMAND

# Git branch parser with vibrant status colors
parse_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    local dirty
    dirty=$(git status --porcelain 2>/dev/null)
    if [ -n "$dirty" ]; then
      # Amber/Yellow branch with red star for uncommitted changes
      printf " \033[1;33m(\033[1;31m%s*\033[1;33m)\033[0m" "$branch"
    else
      # Emerald Green branch for clean git repo
      printf " \033[1;32m(%s)\033[0m" "$branch"
    fi
  fi
}

# Modern VS Code / Git terminal prompt
# [user@hostname:path] (branch*) $ 
export PS1='\[\033[1;36m\]\w\[\033[0m\]$(parse_git_branch) \[\033[1;32m\]\$ \[\033[0m\]'

# Terminal commands to interact seamlessly with Neovim editor
neovide() {
  for f in "$@"; do
    if [ -n "$NVIM" ]; then
      nvim --server "$NVIM" --remote-send "<Cmd>lua _G.open_file_from_terminal('$PWD/$f')<CR>" 2>/dev/null || true
    fi
  done
}

code() {
  neovide "$@"
}
