#!/usr/bin/env bash

export TERM=xterm-256color
export COLORTERM=truecolor

# Source user's standard bashrc if available
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

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
