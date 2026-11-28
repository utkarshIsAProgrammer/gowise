#!/usr/bin/env bash

export HYDE_ACTIVATED=1
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

# Git Bash Environment & Profile
export MSYSTEM="MINGW64"

# Git branch parser with authentic Git Bash styling
parse_git_branch() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    local dirty
    dirty=$(git status --porcelain 2>/dev/null)
    if [ -n "$dirty" ]; then
      printf " \033[36m(\033[36m%s\033[31m *\033[36m)\033[0m" "$branch"
    else
      printf " \033[36m(%s)\033[0m" "$branch"
    fi
  fi
}

# Authentic 2-Line Git Bash Prompt:
# user@host (green) MINGW64 (purple) ~/path (yellow) (branch *) (cyan)
# $ (white)
export PS1='\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[0m\]$(parse_git_branch)\n\[\033[0m\]$ '

# Standard Git Bash convenience alias
alias cls='clear'

# Terminal commands to interact seamlessly with Minimal editor
_minimal_forward_open() {
  if [ -z "$NVIM" ]; then
    command minimal "$@"
    return
  fi
  if [ "$#" -eq 0 ]; then
    nvim --server "$NVIM" --remote-expr "luaeval('_G.focus_editor_from_terminal()')" 2>/dev/null || true
    return
  fi
  for target in "$@"; do
    if [ -n "$target" ] && [ "$target" != "--gui" ]; then
      local abs_path
      if [[ "$target" = /* ]]; then
        abs_path="$target"
      else
        abs_path="$(realpath -m "$target" 2>/dev/null || readlink -m "$target" 2>/dev/null || echo "$PWD/$target")"
      fi
      local escaped="${abs_path//\\/\\\\}"
      escaped="${escaped//\'/\\\'}"
      nvim --server "$NVIM" --remote-expr "luaeval('_G.open_file_from_terminal(\"'$escaped'\")')" 2>/dev/null || true
    fi
  done
}

minimal() {
  _minimal_forward_open "$@"
}

code() {
  _minimal_forward_open "$@"
}

neovide() {
  _minimal_forward_open "$@"
}

edit() {
  _minimal_forward_open "$@"
}

nvim() {
  if [ "$#" -gt 0 ] && [ -n "$NVIM" ]; then
    _minimal_forward_open "$@"
  else
    command nvim "$@"
  fi
}
