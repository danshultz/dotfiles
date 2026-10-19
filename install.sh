#!/bin/sh
# Link this repo's config files into $HOME.
#
# Safe to re-run: existing correct links are left alone, stale symlinks are
# replaced, and real files that would be overwritten are moved to
# ~/.dotfiles-backup/<timestamp>/ first. Never prompts, so Coder can run it
# unattended (it auto-runs install.sh after cloning the dotfiles repo).
#
# Assumes zsh, vim and git are already installed; installs nothing.
set -eu

DOTFILES=$(cd "$(dirname "$0")" && pwd -P)
BACKUP_ROOT="$HOME/.dotfiles-backup"
BACKUP_DIR=""

log() { printf '%s\n' "$*"; }

backup() {
  # backup <abs path>: move a real file or dir aside, keeping its path under $HOME.
  if [ -z "$BACKUP_DIR" ]; then
    BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
  fi
  backup_rel=${1#"$HOME"/}
  mkdir -p "$BACKUP_DIR/$(dirname "$backup_rel")"
  mv "$1" "$BACKUP_DIR/$backup_rel"
  log "backed up $1 -> $BACKUP_DIR/$backup_rel"
}

link() {
  # link <repo-relative src> <home-relative dest>
  link_src="$DOTFILES/$1"
  link_dest="$HOME/$2"
  if [ ! -e "$link_src" ]; then
    log "error: missing source $link_src"
    exit 1
  fi
  if [ -L "$link_dest" ]; then
    if [ "$(readlink "$link_dest")" = "$link_src" ]; then
      log "ok        $link_dest"
      return
    fi
    rm "$link_dest"   # stale or foreign symlink; its target still exists elsewhere
  elif [ "$link_dest" -ef "$link_src" ]; then
    # Already the same file, reached through a symlinked parent (e.g. ~/bin -> repo/bin).
    # Backing it up would move the repo's own file.
    log "ok        $link_dest (same file)"
    return
  elif [ -e "$link_dest" ]; then
    backup "$link_dest"
  fi
  mkdir -p "$(dirname "$link_dest")"
  ln -s "$link_src" "$link_dest"
  log "linked    $link_dest -> $link_src"
}

retire() {
  # retire <home-relative path>: remove a stale symlink or back up a real file.
  retire_dest="$HOME/$1"
  if [ -L "$retire_dest" ]; then
    rm "$retire_dest"
    log "removed   $retire_dest (stale symlink)"
  elif [ -e "$retire_dest" ]; then
    backup "$retire_dest"
  fi
}

log "dotfiles: $DOTFILES ($(uname -s))"

# shell
link zsh/zshrc    .zshrc
link zsh/zprofile .zprofile

# git
link git/gitconfig        .gitconfig
link git/gitignore_global .gitignore

# vim: the whole directory. Vim reads ~/.vim/vimrc itself, so a ~/.vimrc
# would only shadow it.
retire .vimrc
link vim .vim

# misc
link ruby/gemrc .gemrc
link ruby/irbrc .irbrc
link ack/ackrc  .ackrc

# scripts, linked one by one so unrelated files in ~/bin are untouched
for f in "$DOTFILES"/bin/*; do
  link "bin/$(basename "$f")" "bin/$(basename "$f")"
done

# vim plugins are git submodules (if a plugin URL ever changes in
# .gitmodules, run `git submodule sync` once by hand)
if [ -e "$DOTFILES/.git" ] && command -v git > /dev/null 2>&1; then
  git -C "$DOTFILES" submodule update --init
fi

# help tags for the plugins; non-fatal, and stdin is /dev/null so it can never block
if command -v vim > /dev/null 2>&1; then
  vim -es -i NONE -c 'silent! helptags ALL' -c 'qa!' < /dev/null > /dev/null 2>&1 || true
fi

if [ -n "$BACKUP_DIR" ]; then
  log "backups in $BACKUP_DIR"
fi
log "done"
