#!/bin/bash
#
# Multi Minecraft - Universal container entrypoint
#
# Responsibilities:
#   1. Load persisted settings from the server directory (.multi-mc.conf) so
#      choices made in the console survive restarts.
#   2. Set sane base environment (TZ, INTERNAL_IP, locale).
#   3. Automatically select the best available Java runtime for the server
#      (explicit JAVA_VERSION override -> auto-detection by Minecraft version).
#   4. Print a colored summary banner, then evaluate and execute the STARTUP
#      command provided by the panel (same contract as pterodactyl/yolks).
#
# This image ships Java 8, 11, 17, 21, 25 and 26 side by side so a single
# image can run literally every Minecraft version ever released (Alpha -> 26.x+).
# Future, snapshot, beta, alpha, and obsolete Java versions are also supported
# on-demand via dynamic installation. Slim per-Java variants are published too.

set -uo pipefail

# --- Colors -----------------------------------------------------------------
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_MAGENTA='\033[35m'
C_DIM='\033[2m'

log() { printf "${C_YELLOW}${C_BOLD}container@pterodactyl~${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$*"; }
warn() { printf "${C_YELLOW}${C_BOLD}container@pterodactyl~${C_RESET} ${C_YELLOW}${C_BOLD}[warn]${C_RESET} %s\n" "$*"; }
error() { printf "${C_YELLOW}${C_BOLD}container@pterodactyl~${C_RESET} ${C_RED}${C_BOLD}[error]${C_RESET} %s\n" "$*"; }

# --- Persisted settings ------------------------------------------------------
# .multi-mc.conf is a simple KEY=VALUE file written by the launcher (run.sh)
# whenever the user answers an interactive setup prompt. Values here only fill
# in variables that were NOT provided by the panel, so the panel always wins.
CONF_FILE="/home/container/.multi-mc.conf"

read_conf() { # key -> value (safe: no shell evaluation)
    [ -f "${CONF_FILE}" ] || return 1
    local val
    val=$(grep -E "^$1=" "${CONF_FILE}" 2>/dev/null | tail -n1 | cut -d= -f2-)
    [ -n "${val}" ] || return 1
    printf '%s' "${val}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

apply_conf() { # key : only fills in empty/unset environment variables
    local key="$1" val
    val=$(read_conf "${key}") || return 0
    # ${!key} is a safe indirect expansion; values are never evaluated.
    if [ -z "${!key-}" ]; then
        printf -v "${key}" '%s' "${val}"
        export "${key}"
    fi
}

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}' 2>/dev/null || echo "127.0.0.1")
export INTERNAL_IP

# Switch to the container's working directory.
cd /home/container 2>/dev/null || { error "Cannot enter /home/container"; exit 1; }

# Load persisted settings for anything the panel did not provide.
for _key in SERVER_TYPE MINECRAFT_VERSION BUILD_NUMBER LOADER_VERSION \
            SERVER_JARFILE JAVA_VERSION JAVA_FLAGS GC_TYPE MOTD MAX_PLAYERS \
            EXTRA_ARGS CUSTOM_COMMAND AUTO_UPDATE KEEP_BACKUP DEBUG \
            GITHUB_REPO GITHUB_TAG GITHUB_ASSET; do
    apply_conf "${_key}"
done
unset _key val

if [ "${DEBUG:-0}" = "1" ]; then
    warn "DEBUG mode enabled - printing resolved environment (secrets excluded):"
    env | grep -E '^(SERVER_|MINECRAFT|BUILD_|LOADER_|JAVA_|GC_|EXTRA_|CUSTOM_|AUTO_|KEEP_|MOTD|MAX_|ONLINE_|VIEW_|DIFFICULTY|GAMEMODE|PVP|GITHUB_|DEBUG|TZ|INTERNAL_IP)' | sort
fi

# ---------------------------------------------------------------------------
# Java runtime auto-selection
# ---------------------------------------------------------------------------
detect_java() {
    local type="${SERVER_TYPE:-}"
    local mc="${MINECRAFT_VERSION:-}"
    local v=""

    type="${type,,}"

    # Non-Java server types don't need a JVM.
    case "${type}" in
        bedrock | pocketmine)
            echo ""
            return
            ;;
    esac

    # Explicit override always wins (egg variable JAVA_VERSION).
    if [ -n "${JAVA_VERSION:-}" ]; then
        if [ ! -d "/opt/java/${JAVA_VERSION}" ] && command -v install-java.sh >/dev/null 2>&1; then
            log "Java ${JAVA_VERSION} requested but not present; downloading runtime on-demand..."
            install-java.sh "${JAVA_VERSION}" >&2 || true
        fi
        if [ -d "/opt/java/${JAVA_VERSION}" ]; then
            echo "${JAVA_VERSION}"
            return
        fi
    fi

    # Proxies / standalone Java applications use their own versioning scheme.
    case "${type}" in
        velocity | waterfall | bungeecord | nukkit | sponge* | glowstone | cuberite)
            echo "21"
            return
            ;;
    esac

    # Map Minecraft versions to their required Java generation:
    #   Future 27.x+     -> Java 27+
    #   26.x / 26w*      -> Java 26
    #   20.x - 25.x      -> Java 25
    #   1.20.5 - 1.21.x  -> Java 21
    #   1.17 - 1.20.4    -> Java 17
    #   anything older   -> Java 8 (including Alpha, Beta, Classic, InDev, Infdev)
    case "${mc}" in
        latest | latest-snapshot)
            v="26"
            ;;
        [3-9][0-9].* | 2[7-9].*)
            v=$(echo "${mc}" | cut -d. -f1)
            ;;
        26.*)
            v="26"
            ;;
        2[0-5].*)
            v="25"
            ;;
        2[6-9]w* | [3-9][0-9]w*)
            v="26"
            ;;
        25w*)
            v="25"
            ;;
        24w*)
            v="21"
            ;;
        20w4[5-9]* | 20w5* | 2[1-3]w*)
            v="17"
            ;;
        1.20.[5-9]* | 1.2[1-9]*)
            v="21"
            ;;
        1.17* | 1.18* | 1.19* | 1.20 | 1.20.[1-4]*)
            v="17"
            ;;
        a1.* | b1.* | c0.* | in-* | rd-* | inf-* | 1.1[0-6]* | 1.[0-9]*)
            v="8"
            ;;
        *)
            v="21"
            ;;
    esac

    # Check if target runtime is installed; if not, attempt on-demand installation
    if [ -d "/opt/java/${v}" ]; then
        echo "${v}"
    else
        if command -v install-java.sh >/dev/null 2>&1; then
            install-java.sh "${v}" >&2 2>/dev/null || true
            if [ -d "/opt/java/${v}" ]; then
                echo "${v}"
                return
            fi
        fi

        # Fall back to newest runtime installed in /opt/java
        local cand
        for cand in $(find /opt/java -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort -V -r); do
            if [ -x "/opt/java/${cand}/bin/java" ]; then
                echo "${cand}"
                return
            fi
        done
        echo ""
    fi
}

JAVA_SELECTED="$(detect_java)"
if [ -n "${JAVA_SELECTED}" ]; then
    export JAVA_HOME="/opt/java/${JAVA_SELECTED}"
    export PATH="/opt/java/${JAVA_SELECTED}/bin:${PATH}"
fi

# ---------------------------------------------------------------------------
# Startup banner (Calvin S font, ANSI gradient colors)
# ---------------------------------------------------------------------------
BANNER='\033[1;33m.        :    ::: :::.    :::. .,::::::     .,-:::::   :::::::..      ::;.      .-:::::'\'' ::::::::::::      .        :     ...    :::  :::      :::::::::::: :::      .,::::::     .,-:::::/     .,-:::::/  \033[0m\n\033[1;37m;;,.    ;;;   ;;; `;;;;,  `;;; ;;;;'\'''\'''\'''\''   ,;;;'\''````'\''   ;;;;``;;;;     ;;`;;     ;;;'\'''\'''\'''\''  ;;;;;;;;'\'''\'''\'''\''      ;;,.    ;;;    ;;     ;;;  ;;;      ;;;;;;;;'\'''\'''\'''\'' ;;;      ;;;;'\'''\'''\'''\''   ,;;-'\''````'\''    ,;;-'\''````'\''   \033[0m\n\033[1;34m[[[[, ,[[[[,  [[[   [[[[[. `[[  [[cccc    [[[           [[[,/[[['\''    '\''[[ '\''[[,   [[[,,==       [[           [[[[, ,[[[[,  [['\''     [[[  [[[           [[      [[[       [[cccc    [[[   [[[[[[/ [[[   [[[[[[/\033[0m\n\033[1;36m$$$$$$$$"$$$  $$$   $$$ "Y$c$$  $$""""    $$$           $$$$$$c     c$$$cc$$$c  `$$$"``       $$           $$$$$$$$"$$$  $$      $$$  $$'\''           $$      $$$ cccc  $$""""    "$$c.    "$$  "$$c.    "$$ \033[0m\n\033[0;33m888 Y88" 888o 888   888    Y88  888oo,__  `88bo,__,o,   888b "88bo,  888   888,  888          88,          888 Y88" 888o 88    .d888 o88oo,.__      88,     888       888oo,__   `Y8bo,,,o88o  `Y8bo,,,o88o\033[0m\n\033[1;30mMMM  M'\''  "MMM MMM   MMM     YM  """"YUMMM   "YUMMMMMP"  MMMM   "W"   YMM   ""`   "MM,         MMM          MMM  M'\''  "MMM  "YmmMMMM"" """"YUMMM      MMM     MMM       """"YUMMM    `'\''YMUP"YMM    `'\''YMUP"YMM\033[0m'

printf '%b' "${BANNER}"
printf '\n'
printf "${C_YELLOW}${C_DIM}%*s${C_RESET}\n" 176 "- By PotenFYR Studios"
printf "${C_CYAN}${C_BOLD}%s${C_RESET}\n" "$(printf '%*s' 176 '' | tr ' ' '=')"
printf "${C_GREEN}%-22s${C_RESET} %s\n" "Server type:"  "${SERVER_TYPE:-vanilla}"
printf "${C_GREEN}%-22s${C_RESET} %s\n" "MC version:"   "${MINECRAFT_VERSION:-latest}"
if [ -n "${JAVA_SELECTED}" ]; then
    printf "${C_GREEN}%-22s${C_RESET} %s %s\n" "Java:" "${JAVA_SELECTED}" "(auto-selected)"
    "${JAVA_HOME}/bin/java" -version 2>&1 | head -n1 | sed 's/^/                      /'
else
    printf "${C_GREEN}%-22s${C_RESET} %s\n" "Java:" "not required for this server type"
fi
printf "${C_GREEN}%-22s${C_RESET} %sM\n" "Memory:" "${SERVER_MEMORY:-1024}"
printf "${C_GREEN}%-22s${C_RESET} %s\n" "Server jar:" "${SERVER_JARFILE:-server.jar}"
printf "${C_GREEN}%-22s${C_RESET} %s\n" "IP / port:" "${INTERNAL_IP}:${SERVER_PORT:-25565}"
printf "${C_CYAN}${C_BOLD}%s${C_RESET}\n" "$(printf '%*s' 176 '' | tr ' ' '=')"
printf "${C_DIM}Tip: tune performance via JAVA_FLAGS / GC_TYPE, pass server args via EXTRA_ARGS,\n"
printf "     and install from any GitHub release with SERVER_TYPE=github.${C_RESET}\n"

# ---------------------------------------------------------------------------
# Startup command evaluation (yolks-compatible)
# ---------------------------------------------------------------------------
# Convert all of the "{{VARIABLE}}" parts of the command into the expected
# shell variable format of "${VARIABLE}" before evaluating the string.
PARSED=$(printf '%s' "${STARTUP:-}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | sed 's/"/\\"/g')
eval "PARSED=\"${PARSED}\""

log "${PARSED:-bash run.sh}"
# shellcheck disable=SC2086
exec env ${PARSED:-bash run.sh}