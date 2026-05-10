# dotfiles

Personal development environment configuration and bootstrap scripts. Run a single command on any new host to clone the repo, install tools, and symlink configs into place.

## Quick start

```sh
curl -fsSL https://raw.githubusercontent.com/brpvieira/dotfiles/master/setup/install.sh | bash
```

## What it does

1. **Clones the repo** into `~/dotfiles` (falls back to zip download if git is unavailable)
2. **Sets up XDG base directories** (`~/.config`, `~/.local/share`, `~/.local/bin`, etc.) and writes `~/.config/xdg-vars` for shell sourcing
3. **Installs tools** — skips anything already present, supports Homebrew (macOS) and apt/apt-get (Debian/Ubuntu)
4. **Installs terminfo** — compiles a patched `xterm-256color` entry via `tic`, backing up any existing user entry first
5. **Stows configs** — symlinks each package into `$HOME` via xstow, backing up conflicting files to `~/.dotfiles-backup/`

## Tools installed

| Tool | Purpose |
|---|---|
| `jq` | JSON processor |
| `ripgrep` | Fast grep replacement |
| `xmllint` | XML linting (via libxml2) |
| `tmux` | Terminal multiplexer |
| `vim` / `nvim` | Editor (prefers nvim if neither is present) |
| `eslint` | JS/TS linter (requires Node.js) |
| `xstow` | GNU stow-compatible symlink manager |

## Config packages

| Package | Symlinks to |
|---|---|
| `nvim/` | `~/.config/nvim/` — Neovim config (lazy.nvim, LSP, Telescope, Treesitter) |
| `vim/` | `~/.vim/`, `~/.vimrc` — Vim config with custom colorscheme |
| `tmux/` | `~/.tmux.conf` |
| `scripts/` | `~/.local/` — Utility scripts |

## Terminfo

`terminfo/alacritty.terminfo` and `terminfo/xterm-256color.terminfo` are reference copies of the `xterm-256color` terminfo entry. The bootstrap compiles `alacritty.terminfo` into `~/.terminfo/x/xterm-256color`. To install manually:

```sh
tic -x terminfo/alacritty.terminfo
```

## Re-running

All setup steps are idempotent — tools already installed are skipped, and stow removes existing dotfile symlinks before recreating them.
