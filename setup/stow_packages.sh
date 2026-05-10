#!/usr/bin/env bash
#
# Stows dotfile packages into $HOME based on which tools are installed.
# Backs up any conflicting existing files before stowing.
#
# Usage:
# 1. As a standalone script: bash stow_packages.sh
# 2. Source and call: source setup/stow_packages.sh && stow_packages

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
_BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
_BACKED_UP=0

_backup_file() {
    local target="$1"
    local rel="${target#"$HOME/"}"
    local dest="$_BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$target" "$dest"
    echo "  backup: ~/${rel} → ${dest}"
    _BACKED_UP=$(( _BACKED_UP + 1 ))
}

# Walk package files and remove or back up anything that would block stow.
_pre_stow() {
    local package="$1"
    local pkg_dir="$DOTFILES/$package"

    while IFS= read -r -d '' src; do
        local rel="${src#"$pkg_dir/"}"
        local dst="$HOME/$rel"

        [[ -e "$dst" || -L "$dst" ]] || continue

        if [[ -L "$dst" ]]; then
            local real
            real="$(readlink -f "$dst" 2>/dev/null || true)"
            # Already a symlink into our package — remove so stow can recreate it.
            if [[ "$real" == "$pkg_dir/"* ]]; then
                rm -f "$dst"
                continue
            fi
        fi

        _backup_file "$dst"
    done < <(find "$pkg_dir" -type f ! -name '.gitkeep' -print0)
}

_do_stow() {
    local package="$1"
    local pkg_dir="$DOTFILES/$package"

    if [[ ! -d "$pkg_dir" ]]; then
        echo "  package '${package}' not found, skipping."
        return 0
    fi

    echo "Stowing ${package}..."
    _pre_stow "$package"
    xstow -t "$HOME" -d "$DOTFILES" --ignore='^\.gitkeep$' "$package"
}

stow_packages() {
    if ! command -v xstow &>/dev/null; then
        echo "Error: xstow is not installed. Run install_xstow first." >&2
        return 1
    fi

    # scripts/ has no binary dependency — always stow.
    _do_stow scripts

    # Editor configs — stow whichever editors are present.
    command -v nvim &>/dev/null && _do_stow nvim
    command -v vim  &>/dev/null && _do_stow vim

    command -v tmux &>/dev/null && _do_stow tmux

    if [[ "$_BACKED_UP" -gt 0 ]]; then
        echo ""
        echo "Backed up ${_BACKED_UP} file(s) to: ${_BACKUP_DIR}"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    stow_packages
fi
