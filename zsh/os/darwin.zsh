# macOS-specific shell setup. Sourced by zsh/zshrc when `uname -s` is Darwin.
# Every line is a no-op if the Homebrew package is not installed.

export NVM_DIR="$HOME/.nvm"
[ -s /opt/homebrew/opt/nvm/nvm.sh ] && . /opt/homebrew/opt/nvm/nvm.sh
[ -s /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm ] && . /opt/homebrew/opt/nvm/etc/bash_completion.d/nvm

[ -d /opt/homebrew/opt/sqlite/bin ] && export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
