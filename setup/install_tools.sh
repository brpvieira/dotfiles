#!/usr/bin/env bash

# ---------------------------------------------------------------------------
# Low-level package manager helpers
# ---------------------------------------------------------------------------

brew_install() {
    local pkg="$1"
    brew install "$pkg"
}

apt_install() {
    local pkg="$1"
    local apt_cmd
    if command -v apt &>/dev/null; then
        apt_cmd="apt"
    elif command -v apt-get &>/dev/null; then
        apt_cmd="apt-get"
    else
        return 1
    fi

    if [ "$(id -u)" -ne 0 ]; then
        sudo "$apt_cmd" install -y "$pkg"
    else
        "$apt_cmd" install -y "$pkg"
    fi
}

# pkg_install <brew_pkg> <apt_pkg>
# Tries brew first, then apt/apt-get. Returns 1 if no manager found.
pkg_install() {
    local brew_pkg="$1"
    local apt_pkg="$2"

    if command -v brew &>/dev/null; then
        brew_install "$brew_pkg"
    elif command -v apt &>/dev/null || command -v apt-get &>/dev/null; then
        apt_install "$apt_pkg"
    else
        return 1
    fi
}

# ensure_tool <binary> <brew_pkg> <apt_pkg>
# Checks whether <binary> is on PATH; installs via pkg_install if not.
ensure_tool() {
    local binary="$1"
    local brew_pkg="$2"
    local apt_pkg="$3"

    if command -v "$binary" &>/dev/null; then
        echo "${binary} is already installed, skipping."
        return 0
    fi

    echo "${binary} not found. Installing..."
    if pkg_install "$brew_pkg" "$apt_pkg"; then
        echo "${binary} installed successfully."
    else
        echo "Warning: could not install ${binary} — no supported package manager found." >&2
    fi
}

# ---------------------------------------------------------------------------
# xstow-specific installer (needs the brew tap before install)
# ---------------------------------------------------------------------------

install_with_brew() {
    echo "Homebrew detected. Installing xstow via brew..."
    brew tap rspeed/xstow
    brew_install xstow
}

install_with_apt() {
    local apt_cmd="$1"
    echo "apt detected. Installing xstow via ${apt_cmd}..."
    if [ "$(id -u)" -ne 0 ]; then
        sudo "$apt_cmd" update
        sudo "$apt_cmd" install -y xstow
    else
        "$apt_cmd" update
        "$apt_cmd" install -y xstow
    fi
}

install_xstow() {
    if command -v brew &>/dev/null; then
        install_with_brew
    elif command -v apt &>/dev/null; then
        install_with_apt apt
    elif command -v apt-get &>/dev/null; then
        install_with_apt apt-get
    else
        echo "Error: no supported package manager found (brew, apt, or apt-get)." >&2
        echo "Please install xstow manually." >&2
        return 1
    fi

    echo "xstow installed successfully."
}

check_eslint() {
    if ! command -v node &>/dev/null; then
        echo "Warning: Node.js is not installed. Skipping eslint setup." >&2
        return 0
    fi

    echo "Node.js detected ($(node --version))."

    if npm list -g --depth=0 eslint &>/dev/null 2>&1; then
        echo "eslint is already installed globally, skipping."
    else
        echo "eslint not found globally. Installing via npm..."
        npm install -g eslint
        echo "eslint installed successfully."
    fi
}

check_jq()      { ensure_tool jq       jq          jq;          }
check_ripgrep() { ensure_tool rg       ripgrep     ripgrep;     }
check_xmllint() { ensure_tool xmllint  libxml2     libxml2-utils; }

check_tmux()    { ensure_tool tmux     tmux        tmux;        }

check_editor() {
    if command -v nvim &>/dev/null; then
        echo "nvim is already installed, skipping."
        return 0
    fi

    if command -v vim &>/dev/null; then
        echo "vim is already installed, skipping."
        return 0
    fi

    echo "Neither nvim nor vim found. Installing vim..."
    if pkg_install vim vim; then
        echo "vim installed successfully."
    else
        echo "Warning: could not install vim — no supported package manager found." >&2
    fi
}

# Run immediately when executed as a script (not sourced).

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    check_eslint
    check_jq
    check_ripgrep
    check_xmllint
    check_tmux
    check_editor
fi
