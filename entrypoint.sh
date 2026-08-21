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
# This image ships Java 8, 11, 16, 17, 21 and 25 side by side so a single
# image can run literally every Minecraft version ever released (1.0 -> 26.x).
# Slim per-Java variants are published too; on those images the same detection
# logic simply falls back to whatever JVM is installed.

set -uo pipefail

# --- Colors -----------------------------------------------------------------
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
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
    if [ -n "${JAVA_VERSION:-}" ] && [ -d "/opt/java/${JAVA_VERSION}" ]; then
        echo "${JAVA_VERSION}"
        return
    fi

    # Proxies / standalone Java applications use their own versioning scheme.
    case "${type}" in
        velocity | waterfall | bungeecord | nukkit | sponge* | glowstone | cuberite)
            echo "21"
            return
            ;;
    esac

    # Map Minecraft versions to their required Java generation:
    #   26.x+            -> Java 25 (first release to require it)
    #   1.20.5 - 1.21.x  -> Java 21
    #   1.17 - 1.20.4    -> Java 17
    #   anything older   -> Java 8
    case "${mc}" in
        latest | latest-snapshot)
            v="25"
            ;;
        2[0-9].*)
            v="25"
            ;;
        1.20.[5-9]* | 1.2[1-9]*)
            v="21"
            ;;
        1.17* | 1.18* | 1.19* | 1.20*)
            v="17"
            ;;
        1.1[0-6]* | 1.[0-9]*)
            v="8"
            ;;
        *)
            v="21"
            ;;
    esac

    # If the chosen JVM is missing (e.g. slim image variant), fall back to the
    # newest runtime that is actually installed.
    if [ -d "/opt/java/${v}" ]; then
        echo "${v}"
    else
        for cand in 25 21 17 16 11 8; do
            if [ -d "/opt/java/${cand}" ]; then
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
# Startup banner
# ---------------------------------------------------------------------------
BANNER=$(cat <<'ARTEOF'
 _   _   _   _   _  _____   ____  ____    __    _____  _____ 
| | | | | | | \ | ||  ___| / ___)|  _ \  / _|  |  ___||_   _|
| |_| | | | |  \| || |_   | |    | |_) || |_   | |_     | |  
|  _  | | | | |\  ||  _|  | |__  |  _ < |  _|  |  _|    | |  
|_| |_| |_| |_| \_||_|     \____)|_| \_\|_|    |_|      |_|  
 _   _  _   _  _      _____   _    ___   _____   ____   ____ 
| | | || | | || |    |_   _| | |  |___| |  ___| / ___) / ___)
| |_| || | | || |      | |   | |        | |_   | |  __| |  __ 
|  _  || |_| || |___   | |   | |        |  _|  | |__) | |__) 
|_| |_| \___/ |_____|  |_|   |_|        |_|     \____) \____)
ARTEOF
)

printf "${C_CYAN}${C_BOLD}%s${C_RESET}\n" "${BANNER}"
printf "${C_YELLOW}${C_DIM}%*s${C_RESET}\n" 62 "- By PotenFYR Studios"
printf "${C_CYAN}${C_BOLD}==========================================================================${C_RESET}\n"
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
printf "${C_CYAN}${C_BOLD}==========================================================================${C_RESET}\n"
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