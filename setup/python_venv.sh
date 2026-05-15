#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Sets up a profile-wide Python virtual environment at $XDG_DATA_HOME/venv.
#
# Usage:
# 1. As a standalone script: bash python_venv.sh
# 2. Sourced and called from another script:
#      source path/to/python_venv.sh
#      setup_python_venv

setup_python_venv() {
    local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    local venv_dir="$data_home/venv"

    if ! command -v python3 &>/dev/null; then
        printf '[venv] ERROR: python3 not found; cannot create venv.\n' >&2
        return 1
    fi

    if [[ -d "$venv_dir" ]]; then
        printf '[venv] venv already exists at %s, skipping.\n' "$venv_dir"
        return 0
    fi

    printf '[venv] creating venv at %s (python %s)...\n' \
        "$venv_dir" "$(python3 --version 2>&1 | awk '{print $2}')"

    if python3 -m venv "$venv_dir"; then
        printf '[venv] venv created successfully.\n'
    else
        printf '[venv] ERROR: failed to create venv at %s.\n' "$venv_dir" >&2
        return 1
    fi

    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    local requirements="$config_home/python/requirements.txt"

    if [[ -f "$requirements" ]]; then
        printf '[venv] installing dependencies from %s...\n' "$requirements"
        if "$venv_dir/bin/pip" install -r "$requirements"; then
            printf '[venv] dependencies installed successfully.\n'
        else
            printf '[venv] ERROR: failed to install dependencies from %s.\n' "$requirements" >&2
            return 1
        fi
    fi
}

configure_venv_rc() {
    local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    local activate="$data_home/venv/bin/activate"

    local login_shell
    login_shell="$(get_login_shell)"

    local rc
    case "$login_shell" in
        */zsh)  rc="$HOME/.zshrc"  ;;
        */bash) rc="$HOME/.bashrc" ;;
        *)
            printf '[venv] WARNING: login shell "%s" not recognised; add to your rc file manually:\n' "$login_shell" >&2
            printf '[venv]   [ -f "%s" ] && source "%s"\n' "$activate" "$activate" >&2
            return 0
            ;;
    esac

    if grep -qF 'venv/bin/activate' "$rc" 2>/dev/null; then
        printf '[venv] activate line already present in %s\n' "$rc"
        return 0
    fi

    printf '\n# Profile-wide Python venv — managed by dotfiles/setup/python_venv.sh\n' >> "$rc"
    printf '[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/venv/bin/activate" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/venv/bin/activate"\n' >> "$rc"
    printf '[venv] added activate line to %s\n' "$rc"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    setup_python_venv
    configure_venv_rc
fi
