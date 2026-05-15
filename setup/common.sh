#!/usr/bin/env bash

# Shared helpers for setup scripts.

# Prints the absolute path of the user's login shell (e.g. /usr/bin/zsh).
# Tries dscl (macOS), getent (Linux with LDAP/NIS), then /etc/passwd.
get_login_shell() {
    if command -v dscl &>/dev/null; then
        dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}'
    elif command -v getent &>/dev/null; then
        getent passwd "$(id -un)" | cut -d: -f7
    else
        grep "^$(id -un):" /etc/passwd | cut -d: -f7
    fi
}
