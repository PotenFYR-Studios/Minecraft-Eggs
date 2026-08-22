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

# --- Colors -----------------------------------------------------------------
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_DIM='\033[2m'

PANEL_NAME="${PANEL_NAME:-${P_SERVER_UUID:+pterodactyl}}"
PANEL_NAME="${PANEL_NAME:-panel}"

log() { printf "${C_YELLOW}${C_BOLD}container@${PANEL_NAME}~${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$*"; }
warn() { printf "${C_YELLOW}${C_BOLD}container@${PANEL_NAME}~${C_RESET} ${C_YELLOW}${C_BOLD}[warn]${C_RESET} %s\n" "$*"; }
error() { printf "${C_YELLOW}${C_BOLD}container@${PANEL_NAME}~${C_RESET} ${C_RED}${C_BOLD}[error]${C_RESET} %s\n" "$*"; }

if [ -d /home/container ]; then
    cd /home/container 2>/dev/null || true
else
    cd "$(pwd)" 2>/dev/null || true
fi
SERVER_DIR="$(pwd)"

# Ensure Java runtime is in PATH even if run.sh is invoked directly
if ! command -v java >/dev/null 2>&1; then
    for cand in /opt/java/*/bin/java ~/.java/*/bin/java ./java/bin/java; do
        if [ -x "${cand}" ]; then
            JAVA_BIN_DIR="$(dirname "${cand}")"
            export PATH="${JAVA_BIN_DIR}:${PATH}"
            export JAVA_HOME="$(dirname "${JAVA_BIN_DIR}")"
            break
        fi
    done
fi

# --- Persisted settings ------------------------------------------------------
CONF_FILE="${CONF_FILE:-${SERVER_DIR}/.multi-mc.conf}"

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

prompt_value() { # question default : ask on the console if interactive, fall back to default
    local q="$1" def="$2" ans
    if [ ! -t 0 ]; then
        # Daemon / non-interactive environment: use default immediately
        printf '%s' "${def}"
        return 0
    fi
    # The question goes to stderr so $(...) captures only the answer.
    printf "${C_CYAN}${C_BOLD}?${C_RESET} %s ${C_DIM}[default: %s, 15s timeout]${C_RESET}: " "${q}" "${def}" >&2
    if IFS= read -r -t 15 ans; then
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
# Validation & defaults (auto-fill empty values)
# ---------------------------------------------------------------------------
TYPE=$(echo "${SERVER_TYPE:-vanilla}" | tr '[:upper:]' '[:lower:]')
[ -z "${TYPE}" ] && TYPE="vanilla"

if ! is_valid_type "${TYPE}"; then
    warn "Server type '${TYPE}' is not supported by this egg; defaulting to 'vanilla'."
    TYPE="vanilla"
    write_conf SERVER_TYPE "${TYPE}"
    export SERVER_TYPE="${TYPE}"
fi

MINECRAFT_VERSION="${MINECRAFT_VERSION:-latest}"
[ -z "${MINECRAFT_VERSION}" ] && MINECRAFT_VERSION="latest"

if [ "${TYPE}" = "custom" ] && [ -z "${CUSTOM_COMMAND:-}" ]; then
    CUSTOM_COMMAND="java -Xms128M -Xmx${SERVER_MEMORY:-1024}M -jar ${SERVER_JARFILE:-server.jar}"
    write_conf CUSTOM_COMMAND "${CUSTOM_COMMAND}"
    export CUSTOM_COMMAND="${CUSTOM_COMMAND}"
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

SERVER_PORT="${SERVER_PORT:-${PORT:-${ALLOCATION_PORT:-${SERVER_PORT_0:-25565}}}}"
SERVER_MEMORY="${SERVER_MEMORY:-${MEMORY:-${MEM_SIZE:-${P_SERVER_MEMORY:-1024}}}}"
SERVER_IP="${SERVER_IP:-${IP:-${P_SERVER_IP:-0.0.0.0}}}"
SERVER_JARFILE="${SERVER_JARFILE:-${JARFILE:-server.jar}}"
MEMORY=${SERVER_MEMORY}

# ---------------------------------------------------------------------------
# Auto-installation if server files are not found
# ---------------------------------------------------------------------------
auto_install_if_needed() {
    local need_install=0
    case "${TYPE}" in
        bedrock)
            [ ! -f ./bedrock_server ] && need_install=1
            ;;
        pocketmine)
            [ ! -f ./PocketMine-MP.phar ] && need_install=1
            ;;
        *)
            if [ ! -f "${SERVER_JARFILE:-server.jar}" ] && [ ! -f unix_args.txt ]; then
                local cand_jar
                cand_jar=$(ls *.jar 2>/dev/null | grep -v 'installer' | head -n1)
                if [ -n "${cand_jar}" ]; then
                    SERVER_JARFILE="${cand_jar}"
                else
                    need_install=1
                fi
            fi
            ;;
    esac

    if [ "${need_install}" = "1" ]; then
        log "Server files not found in $(pwd). Running automatic installation for ${TYPE} (${MINECRAFT_VERSION})..."
        if [ -x /usr/local/bin/install.sh ]; then
            bash /usr/local/bin/install.sh || warn "Installer exited with code $?"
        elif [ -f ./install.sh ]; then
            bash ./install.sh || warn "Installer exited with code $?"
        elif [ -x /install.sh ]; then
            bash /install.sh || warn "Installer exited with code $?"
        elif command -v install.sh >/dev/null 2>&1; then
            install.sh || warn "Installer exited with code $?"
        fi
    fi
}

auto_install_if_needed

# ---------------------------------------------------------------------------
# Non-Java server types
# ---------------------------------------------------------------------------
case "${TYPE}" in
    bedrock)
        [ ! -f ./bedrock_server ] && { error "bedrock_server executable not found in $(pwd)"; sleep 3; exit 1; }
        chmod +x ./bedrock_server 2>/dev/null || true
        exec env LD_LIBRARY_PATH=. ./bedrock_server
        ;;
    pocketmine)
        [ ! -f ./PocketMine-MP.phar ] && { error "PocketMine-MP.phar not found in $(pwd)"; sleep 3; exit 1; }
        exec php ./PocketMine-MP.phar --no-wizard
        ;;
    custom)
        if [ -n "${CUSTOM_COMMAND:-}" ]; then
            log "Executing custom command: ${CUSTOM_COMMAND}"
            exec bash -c "${CUSTOM_COMMAND}"
        fi
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
    if [ ! -f "${SERVER_JARFILE:-server.jar}" ]; then
        cand_jar=$(ls *.jar 2>/dev/null | grep -v 'installer' | head -n1)
        if [ -n "${cand_jar}" ]; then
            warn "Configured jar '${SERVER_JARFILE:-server.jar}' not found, but found '${cand_jar}'. Launching with '${cand_jar}'."
            SERVER_JARFILE="${cand_jar}"
        else
            error "Server jar file '${SERVER_JARFILE:-server.jar}' was not found in $(pwd)!"
            error "Please check server settings or trigger Reinstall Server in your panel."
            sleep 3
            exit 1
        fi
    fi
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