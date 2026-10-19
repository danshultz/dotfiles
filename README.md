# dotfiles

Shell, git and Vim configuration for my Mac and for Linux [Coder](https://coder.com)
workspaces. One script symlinks everything into `$HOME`; it has no dependencies
beyond `sh`, `git`, `zsh` and `vim`, and installs nothing itself.

## Layout

| Directory | Contents | Linked to |
|---|---|---|
| `zsh/` | `zshrc`, `zprofile`, and `os/{darwin,linux}.zsh` sourced by OS | `~/.zshrc`, `~/.zprofile` |
| `git/` | `gitconfig` and the global `gitignore_global` | `~/.gitconfig`, `~/.gitignore` |
| `vim/` | `vimrc`, `colors/`, and plugins as submodules in `pack/plugins/start/` | `~/.vim` |
| `ruby/` | `gemrc`, `irbrc` | `~/.gemrc`, `~/.irbrc` |
| `ack/` | `ackrc` | `~/.ackrc` |
| `bin/` | scripts, linked one file at a time | `~/bin/<name>` |
| `macos/iterm2/` | iTerm2 profile and preferences exports | imported by hand, see below |
| `install.sh` | the linker | |
| `test/install_test.sh` | end-to-end test against a throwaway `$HOME` | |

Files drop their leading dot inside the repo so they are easy to see and edit.
`install.sh` holds the explicit list of what links where.

Vim reads `~/.vim/vimrc` on its own, so there is no `~/.vimrc` link. Don't
create one; it would shadow the real config.

## Install on a Mac

```sh
git clone git@github.com:danshultz/dotfiles.git ~/dev/dotfiles
~/dev/dotfiles/install.sh
exec zsh
```

Any real file the script would overwrite is moved to
`~/.dotfiles-backup/<timestamp>/` first. Re-running is safe and prints `ok`
for links that are already right.

iTerm2 settings are not symlinked. Import `macos/iterm2/Profiles.json` via
Settings > Profiles > Other Actions > Import JSON Profiles, and point
Settings > General > Settings > "Load settings from a custom folder" at
`macos/iterm2/` if you want the full preferences file.

## Install on Coder

```sh
coder dotfiles https://github.com/danshultz/dotfiles.git
```

Coder clones the repo and runs `install.sh` automatically, and re-running the
command pulls and re-applies. Workspace templates can also prompt for the
dotfiles URL at creation time and do this for you. The HTTPS URL avoids
needing a GitHub SSH key in the workspace; the Vim plugin submodules are all
HTTPS as well.

Two things the workspace image must provide:

- zsh as the login shell, or neither `.zshrc` nor `.zprofile` is read.
- `git-lfs`, if you work in repos that use LFS. `gitconfig` sets
  `filter.lfs.required = true`, so git refuses to check out LFS content
  without it. Override in `~/.gitconfig.local` if you need pointer files instead.

## Machine-specific settings

Two untracked files are sourced if present, so secrets and one-off settings
never land in the repo:

- `~/.zshrc.local`, sourced at the end of `zshrc`. Put API keys and
  work-only PATH entries here.
- `~/.gitconfig.local`, included at the end of `gitconfig`. Put signing keys,
  an email override, or a mergetool here.

Avoid `git config --global ...`. Git rewrites `~/.gitconfig` by renaming a
temp file over it, which replaces the symlink with a plain copy. Edit
`git/gitconfig` or `~/.gitconfig.local` instead. If it happens anyway, the next
`install.sh` run backs the copy up and restores the link. Tools that do this
behind your back include `git lfs install` and `gh auth setup-git`.

## Adding a dotfile

1. Put the file in the directory for its tool (or make a new one).
2. Add a `link <repo path> <home path>` line to `install.sh`.
3. Run `./install.sh`, then `sh test/install_test.sh` if you changed the script.

## Vim plugins

Plugins are native Vim 8 packages: each is a git submodule in
`vim/pack/plugins/start/`, loaded automatically with no plugin manager.

```sh
# add
git submodule add https://github.com/<owner>/<repo>.git vim/pack/plugins/start/<name>
git config -f .gitmodules submodule.vim/pack/plugins/start/<name>.ignore dirty

# update one plugin to its latest commit, then commit the new pin
git submodule update --remote vim/pack/plugins/start/<name>

# remove
git submodule deinit -f vim/pack/plugins/start/<name>
git rm vim/pack/plugins/start/<name>
rm -rf .git/modules/vim/pack/plugins/start/<name>

# after changing a plugin URL in .gitmodules
git submodule sync
```

`ignore = dirty` keeps the `doc/tags` files that `install.sh` generates from
showing up in `git status`.

## Testing

```sh
sh test/install_test.sh
```

Runs `install.sh` twice against a temporary `$HOME`, checks every link, the
backup of a pre-existing file, that the second run changes nothing, and that
zsh and Vim load through the links. To try the Linux path, run the same test
inside an Ubuntu container with `git`, `zsh` and `vim` installed.
