export PATH="/usr/local/sbin:/usr/local/bin:$PATH:/usr/local/android-sdk-macosx/platform-tools:~/bin:/usr/local/share/npm/bin"

# source ~/bin/git-completion.bash
if [ -f $(brew --prefix)/etc/bash_completion ]; then
 . $(brew --prefix)/etc/bash_completion
fi
if [ -f $(brew --prefix nvm)/nvm.sh ]; then
  export NVM_DIR=~/.nvm
  . $(brew --prefix nvm)/nvm.sh
fi

if [ -d $(brew --prefix postgresql@9.6)/bin ]; then
  export PATH="$(brew --prefix postgresql@9.6)/bin:$PATH"
fi

if which direnv > /dev/null; then eval "$(direnv hook $0)"; fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

# because command-t, VI will segfault
EDITOR=vim

txtblk='\e[0;30m' # Black - Regular
txtred='\e[0;31m' # Red
txtgrn='\e[0;32m' # Green
txtylw='\e[0;33m' # Yellow
txtblu='\e[0;34m' # Blue
txtpur='\e[0;35m' # Purple
txtcyn='\e[0;36m' # Cyan
txtwht='\e[0;37m' # White
bldblk='\e[1;30m' # Black - Bold
bldred='\e[1;31m' # Red
bldgrn='\e[1;32m' # Green
bldylw='\e[1;33m' # Yellow
bldblu='\e[1;34m' # Blue
bldpur='\e[1;35m' # Purple
bldcyn='\e[1;36m' # Cyan
bldwht='\e[1;37m' # White
unkblk='\e[4;30m' # Black - Underline
undred='\e[4;31m' # Red
undgrn='\e[4;32m' # Green
undylw='\e[4;33m' # Yellow
undblu='\e[4;34m' # Blue
undpur='\e[4;35m' # Purple
undcyn='\e[4;36m' # Cyan
undwht='\e[4;37m' # White
bakblk='\e[40m'   # Black - Background
bakred='\e[41m'   # Red
badgrn='\e[42m'   # Green
bakylw='\e[43m'   # Yellow
bakblu='\e[44m'   # Blue
bakpur='\e[45m'   # Purple
bakcyn='\e[46m'   # Cyan
bakwht='\e[47m'   # White
txtrst='\e[0m'    # Text Reset

# RVM Script
function __my_rvm_ruby_version {
  local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
  [ "$gemset" != "" ] && gemset="@$gemset"
  local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')
  [ "$version" == "1.8.7" ] && version=""
  local full="$version$gemset"
  [ "$full" != "" ] && echo "($full)"
}

function __parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function __parse_hg_branch() {
  hg branch 2> /dev/null | sed 's/\(.*\)/(\1)/'
}

#PS1="\h:\W\u\$ "
PS1="[\u|\W]\[$txtylw\]\$(__my_rvm_ruby_version)\[$txtcyn\]\$(__parse_hg_branch)\$(__parse_git_branch)\[$txtrst\]\$ "

#aliases
alias be="bundle exec"
alias pg.start="pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start"
alias pg.stop="pg_ctl -D /usr/local/var/postgres stop -s -m fast"

alias mongo.start="mongod run --config /usr/local/etc/mongod.conf"

alias redis.start="redis-server > /dev/null &"
function redis.stop {
  ps -ax |grep redis-server|awk 'NR==1{print $1}'|xargs kill
}

alias postgres.stop="sudo launchctl stop homebrew.mxcl.postgresql.plist"
alias postgres.start="sudo launchctl start homebrew.mxcl.postgresql.plist"
alias clean_git_branches='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'
alias stage_cop="git status --porcelain --untracked-files=no | awk '{print \$2}' | xargs bundle exec rubocop -aD"
alias prettyjson="python -m json.tool"

alias create_ruby_ctags='ctags -R --languages=ruby --exclude=.git --exclude=log --exclude=.bundle . $(bundle list --paths)'

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
  . /usr/local/bin/virtualenvwrapper.sh
  export WORKON_HOME=~/.envs
fi
