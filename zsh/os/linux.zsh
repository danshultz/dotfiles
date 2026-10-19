# Linux-specific shell setup (Coder workspaces). Sourced by zsh/zshrc when
# `uname -s` is Linux. Add workspace-only PATH entries or tool init here.

# nvm installed per-user (https://github.com/nvm-sh/nvm) lives in ~/.nvm.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
