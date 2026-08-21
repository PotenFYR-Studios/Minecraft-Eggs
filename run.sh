#!/bin/bash
#
# Multi Minecraft - universal server launcher
#
# This script is the single entry point for every server type the egg
# supports. It dispatches to the right binary based on the SERVER_TYPE
# environment variable that the panel injects (or that the user answered in
# the console on first run).
#
# Interactive setup:
#   If a required setting is missing or invalid, the launcher asks for it in
#   the console and persists the answer in .multi-mc.conf so every later
#   start just works. The panel's own variables always take precedence.
#
# Environment variables consumed (injected by the panel / egg):
#   SERVER_TYPE      vanilla|paper|spigot|purpur|folia|forge|neoforge|fabric|
#                    quilt|mohist|magma|bungeecord|velocity|waterfall|bedrock|
#                    nukkit|pocketmine|github|custom
#   SERVER_JARFILE   jar file name to launch (Java servers)
#   SERVER_MEMORY    allocated memory in MB (Java servers)
#   JAVA_FLAGS       JVM arguments (default: Aikar's tuned G1GC set;
#                    empty = GC_TYPE picks the tuning)
#   GC_TYPE          auto|g1gc|zgc|parallel (used when JAVA_FLAGS is empty)
#   EXTRA_ARGS       extra arguments appended after the jar (e.g. --nogui)
#   CUSTOM_COMMAND   raw command to execute when SERVER_TYPE=custom
#
# Optional escape hatch: if a file named "run.custom.sh" exists in the server
# directory it is executed instead of the logic below. All environment
# variables above remain available.

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

cd /home/container 2>/dev/null || true

# --- Persisted settings ------------------------------------------------------
CONF_FILE="${CONF_FILE:-/home/container/.multi-mc.conf}"

write_conf() { # key value : upsert a KEY=VALUE line (no shell evaluation on read)
    local key="$1" value="$2" tmp
    tmp="$(mktemp)"
    if [ -f "${CONF_FILE}" ]; then
        awk -v k="${key}" -v v="${value}" \
            'BEGIN { FS = "="; OFS = "=" }
             $1 == k { found = 1; print k, v; next }
             { print }
             END { if (!found) print k, v }' "${CONF_FILE}" > "${tmp}"
    else
        printf '%s=%s\n' "${key}" "${value}" > "${tmp}"
    fi
    mv "${tmp}" "${CONF_FILE}"
    chmod 600 "${CONF_FILE}" 2>/dev/null || true
}

prompt_value() { # question default : ask on the console, fall back to default
    local q="$1" def="$2" ans
    # The question goes to stderr so $(...) captures only the answer.
    printf "${C_CYAN}${C_BOLD}?${C_RESET} %s ${C_DIM}[default: %s, 120s timeout]${C_RESET}: " "${q}" "${def}" >&2
    if IFS= read -r -t 120 ans; then
        ans="${ans:-${def}}"
    else
        printf "${C_DIM}(no input - using default)${C_RESET}\n" >&2
        ans="${def}"
    fi
    printf '\n' >&2
    printf '%s' "${ans}"
}

VALID_TYPES="vanilla paper spigot purpur folia forge neoforge fabric quilt mohist magma bungeecord velocity waterfall bedrock nukkit pocketmine github custom"

is_valid_type() { case " ${VALID_TYPES} " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# ---------------------------------------------------------------------------
# Interactive validation (first run / broken configuration)
# ---------------------------------------------------------------------------
TYPE=$(echo "${SERVER_TYPE:-vanilla}" | tr '[:upper:]' '[:lower:]')

if ! is_valid_type "${TYPE}"; then
    warn "Server type '${TYPE}' is not supported by this egg."
    TYPE=$(prompt_value "Select a server type" "vanilla")
    if ! is_valid_type "${TYPE}"; then
        error "Invalid server type '${TYPE}'; falling back to 'vanilla'."
        TYPE="vanilla"
    fi
    write_conf SERVER_TYPE "${TYPE}"
    export SERVER_TYPE="${TYPE}"
    log "Saved server type '${TYPE}' in ${CONF_FILE} (delete this file to reset)"
fi

if [ -z "${MINECRAFT_VERSION:-}" ]; then
    warn "Minecraft version is empty."
    MINECRAFT_VERSION=$(prompt_value "Minecraft version (e.g. 1.21.4, 26.1, latest)" "latest")
    write_conf MINECRAFT_VERSION "${MINECRAFT_VERSION}"
    export MINECRAFT_VERSION="${MINECRAFT_VERSION}"
    log "Saved Minecraft version '${MINECRAFT_VERSION}' in ${CONF_FILE}"
fi

if [ "${TYPE}" = "custom" ] && [ -z "${CUSTOM_COMMAND:-}" ]; then
    warn "Server type is 'custom' but no command was provided."
    CUSTOM_COMMAND=$(prompt_value "Custom launch command" "java -Xmx1024M -jar server.jar")
    write_conf CUSTOM_COMMAND "${CUSTOM_COMMAND}"
    export CUSTOM_COMMAND="${CUSTOM_COMMAND}"
    log "Saved custom command in ${CONF_FILE}"
fi

if [ "${TYPE}" = "github" ]; then
    if [ -z "${GITHUB_REPO:-}" ]; then
        warn "Server type is 'github' but no repository was provided."
        GITHUB_REPO=$(prompt_value "GitHub repository (owner/name)" "")
        if [ -n "${GITHUB_REPO}" ]; then
            write_conf GITHUB_REPO "${GITHUB_REPO}"
            export GITHUB_REPO="${GITHUB_REPO}"
            log "Saved GitHub repository '${GITHUB_REPO}' in ${CONF_FILE}"
        fi
    fi
    if [ -z "${GITHUB_TAG:-}" ]; then
        GITHUB_TAG=$(prompt_value "GitHub release tag (or 'latest')" "latest")
        write_conf GITHUB_TAG "${GITHUB_TAG}"
        export GITHUB_TAG="${GITHUB_TAG}"
        log "Saved GitHub release tag '${GITHUB_TAG}' in ${CONF_FILE}"
    fi
fi

if [ -n "${JAVA_VERSION:-}" ]; then
    if ! echo "${JAVA_VERSION}" | grep -qE '^(https?://[A-Za-z0-9._~:/?#\[\]@!$&'\''()*+,;=%-]+|[A-Za-z0-9_.-]+)$'; then
        warn "JAVA_VERSION '${JAVA_VERSION}' has an invalid format; using auto-detection."
        unset JAVA_VERSION
    fi
fi

if [ "${DEBUG:-0}" = "1" ]; then
    log "DEBUG: TYPE=${TYPE} MC=${MINECRAFT_VERSION:-} BUILD=${BUILD_NUMBER:-} LOADER=${LOADER_VERSION:-}"
    log "DEBUG: JAR=${SERVER_JARFILE:-server.jar} JAVA=${JAVA_VERSION:-auto} MEM=${SERVER_MEMORY:-1024}"
    log "DEBUG: CONF_FILE=${CONF_FILE} GC=${GC_TYPE:-auto}"
fi

# User-provided launcher override (ultimate escape hatch).
if [ -f ./run.custom.sh ]; then
    exec bash ./run.custom.sh
fi

MEMORY=${SERVER_MEMORY:-1024}

# ---------------------------------------------------------------------------
# Non-Java server types
# ---------------------------------------------------------------------------
case "${TYPE}" in
    bedrock)
        # Bedrock Dedicated Server ships its own shared libraries.
        exec env LD_LIBRARY_PATH=. ./bedrock_server
        ;;
    pocketmine)
        # PocketMine-MP runs on the PHP runtime shipped inside the image.
        exec php ./PocketMine-MP.phar --no-wizard
        ;;
    custom)
        exec bash -c "${CUSTOM_COMMAND:-java -Xmx1024M -jar server.jar}"
        ;;
esac

# Everything below is a Java server.
# GC tuning: an explicit JAVA_FLAGS value (the egg default is Aikar's tuned
# G1GC set) always wins. When JAVA_FLAGS is empty, GC_TYPE picks the tuning:
# 'auto' = Aikar G1GC, 'zgc' = ZGC (great for 8GB+ allocations on Java 21+),
# 'parallel' = ParallelGC.
GC_TYPE=$(echo "${GC_TYPE:-auto}" | tr '[:upper:]' '[:lower:]')
FLAGS_SOURCE="JAVA_FLAGS"
if [ -z "${JAVA_FLAGS:-}" ]; then
    FLAGS_SOURCE="GC_TYPE=${GC_TYPE}"
    case "${GC_TYPE}" in
        zgc)
            JAVA_FLAGS="-XX:+UseZGC -XX:+ZGenerational -XX:+ParallelRefProcEnabled -XX:-OmitStackTraceInFastThrow"
            ;;
        parallel)
            JAVA_FLAGS="-XX:+UseParallelGC -XX:+ParallelRefProcEnabled -XX:+DisableExplicitGC"
            ;;
        *)
            JAVA_FLAGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"
            ;;
    esac
fi
EXTRA_ARGS="${EXTRA_ARGS:-}"

# Modern Forge / NeoForge servers launch through a generated unix_args.txt.
if [ -f unix_args.txt ] && { [ "${TYPE}" = "forge" ] || [ "${TYPE}" = "neoforge" ]; }; then
    JAVA_CMD="java -Xms128M -Xmx${MEMORY}M ${JAVA_FLAGS} @unix_args.txt nogui ${EXTRA_ARGS}"
else
    JAVA_CMD="java -Xms128M -Xmx${MEMORY}M ${JAVA_FLAGS} -jar ${SERVER_JARFILE:-server.jar} ${EXTRA_ARGS}"
fi

log "Executing: ${JAVA_CMD}"
log "JVM flags source: ${FLAGS_SOURCE}"

# BungeeCord-family proxies stop with "end" instead of "stop". Translate the
# panel's stop command on the fly so one stop command works for every type.
case "${TYPE}" in
    bungeecord | waterfall | velocity)
        (while IFS= read -r line; do
            if [ "${line}" = "stop" ]; then line="end"; fi
            printf '%s\n' "${line}"
        done) | bash -c "${JAVA_CMD}"
        exit "${PIPESTATUS[1]:-$?}"
        ;;
esac

exec bash -c "${JAVA_CMD}"