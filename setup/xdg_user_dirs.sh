#!/usr/bin/env bash
#
# Sets up XDG base directories per the XDG Base Directory Specification:
# https://specifications.freedesktop.org/basedir/latest/#variables
#
# For each user-writable base directory:
#   1. If the variable is unset/empty, set and export it to its spec default.
#   2. If the directory does not exist, create it (with correct permissions).
#
# Note: XDG_DATA_DIRS and XDG_CONFIG_DIRS are colon-separated search paths
# pointing to system directories; they are not created by this function.
#
# Usage:
# 1. As a standalone bash script: bash xdg_user_dirs.sh
# 2. Source file and user exported functions
#   source path/to/xdg_user_dirs.sh
#   setup_xdg_user_dirs
#   save_xdg_user_dir
# 3. One liner in .bashrc / .zshrc:
#   [ -f "$HOME/.config/xdg-vars" ] && source "$HOME/.config/xdg-vars" || path/to/xdg_user_dirs.sh

setup_xdg_user_dirs() {
    local had_error=0

    # -------------------------------------------------------------------------
    # Table: variable | default (relative to $HOME) | required permissions
    # Fields are separated by '|'.
    # -------------------------------------------------------------------------
    local -a entries=(
        "XDG_DATA_HOME   | .local/share  | 0700"
        "XDG_CONFIG_HOME | .config       | 0700"
        "XDG_STATE_HOME  | .local/state  | 0700"
        "XDG_CACHE_HOME  | .cache        | 0700"
        "XDG_BIN_HOME    | .local/bin    | 0700"
        "XDG_RUNTIME_DIR |               | 0700"  # no spec default; see below
    )

    local entry var default mode dir

    for entry in "${entries[@]}"; do
        var=$(    awk -F'|' '{gsub(/ /,"",$1); print $1}' <<< "$entry")
        default=$(awk -F'|' '{gsub(/^ +| +$/,"",$2); print $2}' <<< "$entry")
        mode=$(   awk -F'|' '{gsub(/ /,"",$3); print $3}' <<< "$entry")

        # ------------------------------------------------------------------
        # 1. Ensure the variable is set.
        # ------------------------------------------------------------------
        if [[ -z "${!var:-}" ]]; then
            if [[ -z "$default" ]]; then
                # XDG_RUNTIME_DIR has no spec-defined default.
                # Use /run/user/<uid> when available, else a fallback under /tmp.
                if [[ -d "/run/user/$(id -u)" ]]; then
                    dir="/run/user/$(id -u)"
                else
                    dir="/tmp/xdg-runtime-$(id -u)"
                    printf '[xdg] WARNING: /run/user/%s unavailable; ' "$(id -u)"
                    printf 'falling back to %s\n' "$dir" >&2
                fi
            else
                dir="$HOME/$default"
            fi
            export "$var"="$dir"
            printf '[xdg] %-20s unset  → exporting default: %s\n' "$var" "$dir"
        else
            dir="${!var}"
            # Reject relative paths as required by the spec.
            if [[ "$dir" != /* ]]; then
                printf '[xdg] ERROR: %s="%s" is not an absolute path; ignoring.\n' \
                    "$var" "$dir" >&2
                had_error=1
                continue
            fi
            printf '[xdg] %-20s set    → %s\n' "$var" "$dir"
        fi

        # ------------------------------------------------------------------
        # 2. Ensure the directory exists with the correct permissions.
        # ------------------------------------------------------------------
        if [[ ! -d "$dir" ]]; then
            if mkdir -m "$mode" -p "$dir"; then
                printf '[xdg]   created  %s  (mode %s)\n' "$dir" "$mode"
            else
                printf '[xdg]   ERROR: could not create %s\n' "$dir" >&2
                had_error=1
            fi
        else
            # Directory exists; enforce mode for XDG_RUNTIME_DIR (spec requirement).
            if [[ "$var" == "XDG_RUNTIME_DIR" ]]; then
                chmod 0700 "$dir" 2>/dev/null || {
                    printf '[xdg]   WARNING: could not set 0700 on %s\n' "$dir" >&2
                }
            fi
            printf '[xdg]   exists   %s\n' "$dir"
        fi
    done

    return $had_error
}

# Writes the current XDG base directory variables to $XDG_CONFIG_HOME/xdg-vars
# so the file can be sourced from .bashrc / .zshrc on login.
#
# Call this after setup_xdg_user_dirs (or any time the variables are set).
# XDG_RUNTIME_DIR is intentionally excluded: its lifetime is tied to the login
# session and must not be persisted to disk.
save_xdg_user_dirs() {
    # XDG_CONFIG_HOME must be set (and valid) before we can write anything.
    if [[ -z "${XDG_CONFIG_HOME:-}" ]]; then
        printf '[xdg] ERROR: XDG_CONFIG_HOME is not set; run setup_xdg_user_dirs first.\n' >&2
        return 1
    fi
    if [[ "$XDG_CONFIG_HOME" != /* ]]; then
        printf '[xdg] ERROR: XDG_CONFIG_HOME="%s" is not an absolute path.\n' \
            "$XDG_CONFIG_HOME" >&2
        return 1
    fi

    local out="$XDG_CONFIG_HOME/xdg-vars"

    # Persist only the stable, path-based variables — not XDG_RUNTIME_DIR,
    # whose value is session-scoped and managed by the OS (logind / PAM).
    local -a vars=(
        XDG_DATA_HOME
        XDG_CONFIG_HOME
        XDG_STATE_HOME
        XDG_CACHE_HOME
        XDG_BIN_HOME
    )

    # Check whether XDG_BIN_HOME is already present in PATH by splitting on ':'
    # and comparing each component individually (avoids false substring matches).
    local bin_home="${XDG_BIN_HOME:-$HOME/.local/bin}"
    local need_path_entry=true
    local _p _saved_IFS="$IFS"
    IFS=':'
    for _p in $PATH; do
        if [[ "$_p" == "$bin_home" ]]; then
            need_path_entry=false
            break
        fi
    done
    IFS="$_saved_IFS"

    if $need_path_entry; then
        printf '[xdg] XDG_BIN_HOME (%s) not in PATH → will be added in %s\n' \
            "$bin_home" "$out"
    else
        printf '[xdg] XDG_BIN_HOME (%s) already in PATH → no PATH change needed\n' \
            "$bin_home"
    fi

    {
        printf '# XDG Base Directory variables\n'
        printf '# Generated by xdg_user_dirs.sh on %s\n' "$(date -Iseconds)"
        printf '# Source this file from .bashrc / .zshrc, BEFORE any application\n'
        printf '# that relies on these paths.\n'
        printf '#\n'
        printf '# XDG_RUNTIME_DIR is intentionally absent: it is session-scoped\n'
        printf '# and must be provided by the OS (logind/PAM), not hardcoded.\n'
        printf '\n'
        local var
        for var in "${vars[@]}"; do
            if [[ -n "${!var:-}" ]]; then
                printf 'export %s="%s"\n' "$var" "${!var}"
            fi
        done
        printf '\n'
        if $need_path_entry; then
            # Use a case statement so the snippet stays idempotent when re-sourced:
            # it will not prepend the path a second time if PATH already contains it
            # (e.g. because the session restarted without regenerating this file).
            printf '# Prepend $XDG_BIN_HOME to $PATH if not already present.\n'
            printf 'case ":${PATH}:" in\n'
            printf '  *:"${XDG_BIN_HOME}":*) ;;\n'
            printf '  *) export PATH="${XDG_BIN_HOME}${PATH:+:${PATH}}" ;;\n'
            printf 'esac\n'
        else
            printf '# $XDG_BIN_HOME is already present in $PATH — no change needed.\n'
        fi
    } > "$out" || {
        printf '[xdg] ERROR: could not write to %s\n' "$out" >&2
        return 1
    }

    chmod 0600 "$out"
    printf '[xdg] saved XDG vars → %s\n' "$out"
    printf '[xdg] add the following line to your .bashrc / .zshrc:\n'
    printf '[xdg]   [ -f "%s" ] && source "%s"\n' "$out" "$out"
}

# Run immediately when executed as a script (not sourced).
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    setup_xdg_user_dirs && save_xdg_user_dirs
fi
