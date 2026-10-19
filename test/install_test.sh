#!/bin/sh
# End-to-end test for install.sh against a throwaway $HOME.
# Usage: sh test/install_test.sh
# Never touches the real home directory.
set -u

DOTFILES=$(cd "$(dirname "$0")/.." && pwd -P)
T=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-test.XXXXXX")
export HOME="$T"
fail=0

ok()   { printf 'ok   %s\n' "$1"; }
bad()  { printf 'FAIL %s\n' "$1"; fail=1; }
check_link() {
  # check_link <home-relative dest> <repo-relative src>
  if [ -L "$HOME/$1" ] && [ "$(readlink "$HOME/$1")" = "$DOTFILES/$2" ]; then
    ok "$1 -> $2"
  else
    bad "$1 should link to $DOTFILES/$2 (got: $(readlink "$HOME/$1" 2>/dev/null || echo 'not a symlink'))"
  fi
}

# Seed pre-existing state the installer must cope with:
#   a real .zshrc (must be backed up, not clobbered)
#   a stale ~/.vimrc and ~/.vim pointing at the old vimconfig repo (must be replaced)
#   an unrelated script in ~/bin (must be left alone)
printf 'echo old zshrc\n' > "$HOME/.zshrc"
mkdir -p "$HOME/old-vimconfig" "$HOME/bin"
ln -s "$HOME/old-vimconfig" "$HOME/.vim"
ln -s "$HOME/old-vimconfig/vimrc" "$HOME/.vimrc"
printf '#!/bin/sh\n' > "$HOME/bin/keep-me"

echo "# first run"
sh "$DOTFILES/install.sh" > "$T/run1.out" 2>&1 || bad "install.sh exited non-zero on first run"
sed 's/^/  | /' "$T/run1.out"

check_link .zshrc            zsh/zshrc
check_link .zprofile         zsh/zprofile
check_link .gitconfig        git/gitconfig
check_link .gitignore        git/gitignore_global
check_link .vim              vim
check_link .gemrc            ruby/gemrc
check_link .irbrc            ruby/irbrc
check_link .ackrc            ack/ackrc
check_link bin/git-ai-commit     bin/git-ai-commit
check_link bin/git-ai-commit-msg bin/git-ai-commit-msg

if [ ! -e "$HOME/.vimrc" ] && [ ! -L "$HOME/.vimrc" ]; then ok ".vimrc stale symlink removed"; else bad ".vimrc should be gone so ~/.vim/vimrc is used"; fi
[ -f "$HOME/bin/keep-me" ] && ok "unrelated ~/bin file kept" || bad "~/bin/keep-me was removed"

backup=$(find "$HOME/.dotfiles-backup" -name .zshrc 2>/dev/null | head -1)
if [ -n "$backup" ] && grep -q 'old zshrc' "$backup"; then ok "real .zshrc backed up to $backup"; else bad "real .zshrc was not backed up"; fi
[ "$(find "$HOME/.dotfiles-backup" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" = 1 ] && ok "one backup dir" || bad "expected exactly one backup dir"

echo "# second run (idempotent)"
sh "$DOTFILES/install.sh" > "$T/run2.out" 2>&1 || bad "install.sh exited non-zero on second run"
grep -q -E '^(linked|backed up)' "$T/run2.out" && bad "second run changed something: $(grep -E '^(linked|backed up)' "$T/run2.out" | head -3)" || ok "second run made no changes"
[ "$(find "$HOME/.dotfiles-backup" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" = 1 ] && ok "no new backup dir on second run" || bad "second run created another backup dir"

echo "# shell and editor load through the links"
zsh -ic 'echo "$DOTFILES"; whence -w be' > "$T/zsh.out" 2>&1
grep -q "^$DOTFILES\$" "$T/zsh.out" && ok "zshrc resolves DOTFILES" || bad "zshrc did not resolve DOTFILES: $(cat "$T/zsh.out")"
grep -q 'be: alias' "$T/zsh.out" && ok "zsh aliases defined" || bad "zsh alias be missing"

if command -v vim > /dev/null 2>&1; then
  vim --not-a-term -i NONE -c "call writefile([\$MYVIMRC, get(g:, 'colors_name', '')], '$T/vim.out')" -c 'qa!' < /dev/null > /dev/null 2>&1
  # Vim reports the symlink-resolved path, so match on the repo-relative tail.
  grep -q -E "^($HOME/.vim|$DOTFILES/vim)/vimrc\$" "$T/vim.out" && ok "vim reads ~/.vim/vimrc" || bad "vim did not read ~/.vim/vimrc: $(cat "$T/vim.out" 2>/dev/null)"
  grep -q '^zenburn$' "$T/vim.out" && ok "vim colorscheme zenburn" || bad "zenburn not active"
  tags=$(find "$DOTFILES/vim/pack/plugins/start" -path '*/doc/tags' | wc -l | tr -d ' ')
  [ "$tags" -gt 0 ] && ok "helptags generated ($tags files)" || bad "no doc/tags generated"
fi

echo "# ~/bin that is itself a symlink into the repo must leave repo files alone"
# Uses a scratch copy of the repo (no .git, no plugins) so a bug here cannot
# move tracked files out of the real checkout.
SCRATCH="$T/scratch-repo"
mkdir -p "$SCRATCH/vim"
cp "$DOTFILES/install.sh" "$SCRATCH/"
for d in zsh git ruby ack bin; do cp -R "$DOTFILES/$d" "$SCRATCH/"; done
cp -R "$DOTFILES/vim/colors" "$SCRATCH/vim/"
cp "$DOTFILES/vim/vimrc" "$SCRATCH/vim/"
H2="$T/home2"
mkdir -p "$H2"
ln -s "$SCRATCH/bin" "$H2/bin"
HOME="$H2" sh "$SCRATCH/install.sh" > "$T/run3.out" 2>&1 || bad "install.sh failed when ~/bin is a symlink into the repo: $(tail -2 "$T/run3.out")"
if [ -f "$SCRATCH/bin/git-ai-commit" ] && [ ! -L "$SCRATCH/bin/git-ai-commit" ]; then ok "repo bin/git-ai-commit left in place"; else bad "repo bin/git-ai-commit was moved or replaced by a symlink"; fi
[ -L "$H2/bin" ] && [ "$(readlink "$H2/bin")" = "$SCRATCH/bin" ] && ok "~/bin symlink kept" || bad "~/bin symlink was replaced"
[ -e "$H2/.dotfiles-backup" ] && bad "a backup was taken when nothing needed replacing" || ok "no spurious backup"

echo
if [ "$fail" = 0 ]; then echo "PASS (home was $T)"; else echo "FAIL (home was $T)"; fi
exit "$fail"
