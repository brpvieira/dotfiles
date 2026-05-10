#!/usr/bin/env bash

set -euo pipefail
DOTFILES="$HOME/dotfiles"

get_dotfiles() {
    local dest=$DOTFILES
    local repo_url="https://github.com/brpvieira/dotfiles"
    local zip_url="${repo_url}/archive/refs/heads/master.zip"

    if [ -d "$dest" ]; then
        echo "Dotfiles directory already exists at ${dest}, skipping."
        return 0
    fi

    if command -v git &>/dev/null; then
        echo "git detected. Cloning dotfiles into ${dest}..."
        git clone "$repo_url" "$dest"
    else
        echo "git not found. Downloading dotfiles archive..."
        local tmp_zip
        tmp_zip="$(mktemp /tmp/dotfiles-XXXXXX.zip)"

        if command -v curl &>/dev/null; then
            curl -fsSL "$zip_url" -o "$tmp_zip"
        elif command -v wget &>/dev/null; then
            wget -q "$zip_url" -O "$tmp_zip"
        else
            echo "Error: neither curl nor wget found. Cannot download dotfiles." >&2
            return 1
        fi

        echo "Extracting dotfiles into ${dest}..."
        local tmp_dir
        tmp_dir="$(mktemp -d /tmp/dotfiles-XXXXXX)"
        unzip -q "$tmp_zip" -d "$tmp_dir"
        # The zip contains a single top-level folder (dotfiles-master); move its contents
        mv "$tmp_dir/dotfiles-master" "$dest"
        rm -rf "$tmp_zip" "$tmp_dir"
    fi

    echo "Dotfiles ready at ${dest}."
}

get_dotfiles

pushd $DOTFILES > /dev/null 2>&1

    source setup/xdg_user_dirs.sh
    setup_xdg_user_dirs && save_xdg_user_dirs

    source setup/install_tools.sh
    check_eslint
    check_jq
    check_ripgrep
    check_xmllint
    check_tmux
    check_editor
    install_xstow

popd > /dev/null 2>&1
