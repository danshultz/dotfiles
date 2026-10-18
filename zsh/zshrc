EDITOR=vim

[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion


function __parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

setopt PROMPT_SUBST
PROMPT='%(?.%F{green}√.%F{red}?%?)%f %F{cyan}🌿$(__parse_git_branch)%f %B%F{240}%1~%f%b %# '

# export PATH="/usr/local/opt/sqlite/bin:$PATH"
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# . /usr/local/opt/asdf/libexec/asdf.sh

# Load rbenv automatically by appending
# the following to ~/.zshrc:
eval "$(rbenv init - zsh)"

alias be="bundle exec"
alias clean_git_branches='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
