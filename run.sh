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

# ---------------------------------------------------------------------------
# Persistent launcher logging (launch events + crash history for support)
# ---------------------------------------------------------------------------
ERROR_LOG="${SERVER_DIR}/error.log"

elog() { printf '[%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >> "${ERROR_LOG}" 2>/dev/null || true; }

if [ -f "${ERROR_LOG}" ] && [ "$(wc -c < "${ERROR_LOG}" 2>/dev/null || echo 0)" -gt 524288 ]; then
    mv -f "${ERROR_LOG}" "${ERROR_LOG}.old" 2>/dev/null || true
fi

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

elog "=== launch: type=${TYPE} mc=${MINECRAFT_VERSION:-latest} mem=${SERVER_MEMORY:-1024} java=${JAVA_VERSION:-auto} ==="
# Only log abnormal exits; graceful stops (0,130,143) are not errors
trap 'ec=$?; if [ "${ec}" -ne 0 ] && [ "${ec}" -ne 130 ] && [ "${ec}" -ne 143 ]; then elog "launcher terminated abnormally (code ${ec})"; fi; exit ${ec}' EXIT
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
# Graceful shutdown helpers (fixes stop/restart hanging for ALL languages)
# ---------------------------------------------------------------------------
# Panel sends "stop" via stdin, then SIGTERM, then SIGKILL.
# This unified handler works for every SERVER_TYPE.
SERVER_PID=""
CAT_PID=""
DRAIN_PID=""
TRANSLATOR_PID=""
FIFO_PATH="/tmp/mc-stdin.fifo"
FIFO_TRANSLATED="/tmp/mc-stdin-translated.fifo"
EXIT_STATUS=0
SHUTDOWN_INITIATED=0

cleanup_fifo() {
    rm -f "${FIFO_PATH}" "${FIFO_TRANSLATED}" 2>/dev/null || true
    if [ -n "${CAT_PID}" ]; then
        kill "${CAT_PID}" 2>/dev/null || true
        wait "${CAT_PID}" 2>/dev/null || true
        CAT_PID=""
    fi
    if [ -n "${DRAIN_PID}" ]; then
        kill "${DRAIN_PID}" 2>/dev/null || true
        wait "${DRAIN_PID}" 2>/dev/null || true
        DRAIN_PID=""
    fi
    if [ -n "${TRANSLATOR_PID}" ]; then
        kill "${TRANSLATOR_PID}" 2>/dev/null || true
        wait "${TRANSLATOR_PID}" 2>/dev/null || true
        TRANSLATOR_PID=""
    fi
}

# Send stop command to server via FIFO (only used by proxy types whose
# stdin is routed through the translation FIFO). Also arms the shutdown
# timer so the grace period starts counting no matter how shutdown was
# requested (panel signal, console "stop", or Kill button).
send_stop_command() {
    SHUTDOWN_INITIATED=1
    if [ -p "${FIFO_PATH:-}" ]; then
        case "${TYPE}" in
            bungeecord|waterfall|velocity) printf 'end\n' > "${FIFO_PATH}" 2>/dev/null || true ;;
            *) printf 'stop\n' > "${FIFO_PATH}" 2>/dev/null || true ;;
        esac
    else
        # No FIFO (direct-stdin servers): SIGTERM triggers the JVM shutdown
        # hooks, which save the world and stop the server cleanly.
        if [ -n "${SERVER_PID}" ] && kill -0 "${SERVER_PID}" 2>/dev/null; then
            kill -TERM "${SERVER_PID}" 2>/dev/null || true
        fi
    fi
}

# Signal handler: request graceful shutdown.
handle_signal() {
    local sig="$1"
    if [ "${SHUTDOWN_INITIATED}" -eq 1 ]; then
        return
    fi
    SHUTDOWN_INITIATED=1
    log "Received ${sig}, initiating graceful shutdown..."
    send_stop_command || true
}

trap 'handle_signal TERM' TERM
trap 'handle_signal INT' INT
trap - EXIT

# Launch the server as a background child so signals land on the launcher,
# which orchestrates graceful shutdown (console command -> SIGTERM -> SIGKILL).
#
#   translate=0 : server inherits the panel's stdin DIRECTLY (same contract
#                 as official Pterodactyl yolks) - the panel's "stop" command
#                 reaches the server console natively. No FIFOs involved.
#   translate=1 : BungeeCord-family proxies expect "end" instead of "stop".
#                 A translator reads panel stdin and writes converted lines
#                 into a FIFO the server reads. The parent keeps the FIFO's
#                 write end open (fd 3) so the server never sees a premature
#                 EOF, and closing it later terminates the translator cleanly.
launch_with_fifo() {
    local cmd="$1"
    local translate="$2"

    if [ "${translate}" != "1" ]; then
        TRANSLATOR_PID=""
        CAT_PID=""
        # CRITICAL: an async (background) command in a non-job-control shell
        # gets its stdin redirected to /dev/null by POSIX rules. Without the
        # explicit `<&0` the server would never receive the panel's console
        # input ("stop"/"end") and would see instant EOF instead.
        bash -c "exec ${cmd}" <&0 &
        SERVER_PID=$!
    else
        rm -f "${FIFO_PATH}" 2>/dev/null || true
        mkfifo "${FIFO_PATH}" 2>/dev/null || true
        # Keep a READER on the FIFO at all times so writes to it never block:
        # this background cat consumes anything nobody else reads (EOF-safe).
        cat < "${FIFO_PATH}" > /dev/null &
        DRAIN_PID=$!
        # Translator: panel stdin -> FIFO (stop -> end for BungeeCord-family)
        # If panel stdin EOFs early (non-interactive runs), the translator
        # exits; the drain reader above keeps the FIFO usable.
        ( while IFS= read -r line || [ -n "${line}" ]; do
              [ "${line}" = "stop" ] && line="end"
              printf '%s\n' "${line}"
          done > "${FIFO_PATH}" ) &
        TRANSLATOR_PID=$!
        # Hold the write end open so the server doesn't see EOF early.
        exec 3>"${FIFO_PATH}" 2>/dev/null || true
        ( bash -c "exec ${cmd}" < "${FIFO_PATH}" ) &
        SERVER_PID=$!
    fi
    # Wait for server. Grace-period timers only start counting once a
    # shutdown has been initiated (stop command / signal), never at startup.
    # 30s grace (console stop), then SIGTERM, then SIGKILL 15s later. Panels
    # typically force-kill the container ~60s after Stop, so this finishes
    # well inside that window while still giving big servers time to save.
    local grace_count=0
    local grace_max=30  # seconds of grace after stop before SIGTERM
    while kill -0 "${SERVER_PID}" 2>/dev/null; do
        sleep 1
        if [ "${SHUTDOWN_INITIATED}" -eq 1 ]; then
            grace_count=$((grace_count + 1))
            if [ "${grace_count}" -eq "${grace_max}" ]; then
                log "Server not responding to stop command after ${grace_max}s, sending SIGTERM..."
                kill -TERM "${SERVER_PID}" 2>/dev/null || true
            fi
            if [ "${grace_count}" -ge $((grace_max + 15)) ]; then
                warn "Server still running, force killing (SIGKILL)..."
                kill -KILL "${SERVER_PID}" 2>/dev/null || true
                sleep 1
                break
            fi
        fi
    done
    
    wait "${SERVER_PID}" 2>/dev/null
    EXIT_STATUS=$?

    # Close our held write end and clean up helper processes
    exec 3>&- 2>/dev/null || true
    if [ -n "${DRAIN_PID}" ]; then
        kill "${DRAIN_PID}" 2>/dev/null || true
        wait "${DRAIN_PID}" 2>/dev/null || true
        DRAIN_PID=""
    fi
    if [ -n "${TRANSLATOR_PID}" ]; then
        kill "${TRANSLATOR_PID}" 2>/dev/null || true
        wait "${TRANSLATOR_PID}" 2>/dev/null || true
        TRANSLATOR_PID=""
    fi
    rm -f "${FIFO_PATH}" "${FIFO_TRANSLATED}" 2>/dev/null || true
    return ${EXIT_STATUS}
}

# ---------------------------------------------------------------------------
# Non-Java server types (now with graceful shutdown for all)
# ---------------------------------------------------------------------------
case "${TYPE}" in
    bedrock)
        [ ! -f ./bedrock_server ] && { error "bedrock_server executable not found in $(pwd)"; sleep 3; exit 1; }
        chmod +x ./bedrock_server 2>/dev/null || true
        log "Executing: ./bedrock_server (LD_LIBRARY_PATH=.)"
        launch_with_fifo "env LD_LIBRARY_PATH=. ./bedrock_server" 0
        EXIT_STATUS=$?
        if [ ${EXIT_STATUS} -ne 0 ] && [ ${EXIT_STATUS} -ne 130 ] && [ ${EXIT_STATUS} -ne 143 ]; then
            elog "=== CRASH: exit=${EXIT_STATUS} type=${TYPE} ==="
            print_crash_diagnostics "${EXIT_STATUS}" 2>/dev/null || true
        else
            elog "=== server process exited cleanly (code ${EXIT_STATUS}) ==="
        fi
        exit ${EXIT_STATUS}
        ;;
    pocketmine)
        [ ! -f ./PocketMine-MP.phar ] && { error "PocketMine-MP.phar not found in $(pwd)"; sleep 3; exit 1; }
        log "Executing: php PocketMine-MP.phar"
        launch_with_fifo "php ./PocketMine-MP.phar --no-wizard" 0
        EXIT_STATUS=$?
        if [ ${EXIT_STATUS} -ne 0 ] && [ ${EXIT_STATUS} -ne 130 ] && [ ${EXIT_STATUS} -ne 143 ]; then
            elog "=== CRASH: exit=${EXIT_STATUS} type=${TYPE} ==="
            print_crash_diagnostics "${EXIT_STATUS}" 2>/dev/null || true
        else
            elog "=== server process exited cleanly (code ${EXIT_STATUS}) ==="
        fi
        exit ${EXIT_STATUS}
        ;;
    custom)
        if [ -n "${CUSTOM_COMMAND:-}" ]; then
            log "Executing custom command: ${CUSTOM_COMMAND}"
            # Custom commands may be any language; try graceful stop then SIGTERM
            launch_with_fifo "${CUSTOM_COMMAND}" 0
            EXIT_STATUS=$?
            if [ ${EXIT_STATUS} -ne 0 ] && [ ${EXIT_STATUS} -ne 130 ] && [ ${EXIT_STATUS} -ne 143 ]; then
                elog "=== CRASH: exit=${EXIT_STATUS} type=${TYPE} ==="
            else
                elog "=== server process exited cleanly (code ${EXIT_STATUS}) ==="
            fi
            exit ${EXIT_STATUS}
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

# ---------------------------------------------------------------------------
# Server process execution & automated crash diagnostics
# ---------------------------------------------------------------------------
print_crash_diagnostics() {
    local code="$1"
    local divider
    divider=$(printf '%*s' 62 '' | tr ' ' '=')
    local sub_divider
    sub_divider=$(printf '%*s' 62 '' | tr ' ' '-')

    printf "\n${C_RED}${C_BOLD}%s${C_RESET}\n" "${divider}"
    printf "${C_RED}${C_BOLD}  [CRASH DETECTED] Server process terminated abnormally (Exit code: %s)${C_RESET}\n" "${code}"
    printf "${C_RED}${C_BOLD}%s${C_RESET}\n" "${divider}"
    
    printf "  ${C_YELLOW}${C_BOLD}Context Summary:${C_RESET}\n"
    printf "  • Software   : %s (%s)\n" "${TYPE}" "${MINECRAFT_VERSION:-latest}"
    printf "  • Java       : %s\n" "$(java -version 2>&1 | head -n1 || echo 'Java not found')"
    printf "  • Memory     : %s MB\n" "${SERVER_MEMORY:-1024}"
    printf "  • Directory  : %s\n" "${SERVER_DIR:-$(pwd)}"
    printf "  • Disk Free  : %s\n" "$(df -h . 2>/dev/null | awk 'NR==2 {print $4}' || echo 'unknown')"

    printf "${C_DIM}%s${C_RESET}\n" "${sub_divider}"
    printf "  ${C_GREEN}${C_BOLD}Automated Diagnostics:${C_RESET}\n"

    # 1. Check EULA
    if [ -f eula.txt ] && grep -qi "eula=false" eula.txt; then
        printf "  ${C_YELLOW}⚠ EULA Not Accepted:${C_RESET} eula.txt contains eula=false. Accept EULA in panel or set eula=true.\n"
    elif [ ! -f eula.txt ] && [ "${TYPE}" != "bedrock" ] && [ "${TYPE}" != "pocketmine" ] && [ "${TYPE}" != "velocity" ] && [ "${TYPE}" != "waterfall" ] && [ "${TYPE}" != "bungeecord" ]; then
        printf "  ${C_YELLOW}⚠ EULA Missing:${C_RESET} Server exited on initial startup to generate eula.txt. Accept EULA and start again.\n"
    fi

    # 2. Check Out of Memory
    if [ "${code}" -eq 137 ]; then
        printf "  ${C_RED}⚠ Out Of Memory (OOM Killer):${C_RESET} Container exceeded memory limit (${SERVER_MEMORY:-1024} MB). Increase server memory in panel.\n"
    fi

    # 3. Check for crash reports / latest logs
    if [ -d crash-reports ]; then
        local latest_crash
        latest_crash=$(ls -t crash-reports/crash-*.txt 2>/dev/null | head -n1)
        if [ -n "${latest_crash}" ]; then
            printf "  ${C_YELLOW}⚠ Crash Report Found:${C_RESET} %s\n" "${latest_crash}"
            printf "  ${C_DIM}----------------------------------------${C_RESET}\n"
            grep -E '^(Description|Caused by|java\.lang\.)' "${latest_crash}" 2>/dev/null | head -n6 | sed 's/^/    /'
            printf "  ${C_DIM}----------------------------------------${C_RESET}\n"
        fi
    elif [ -f logs/latest.log ]; then
        local error_lines
        error_lines=$(grep -iE '(error|exception|fatal|failed)' logs/latest.log 2>/dev/null | tail -n5)
        if [ -n "${error_lines}" ]; then
            printf "  ${C_YELLOW}⚠ Recent Errors in logs/latest.log:${C_RESET}\n"
            printf "${C_DIM}%s${C_RESET}\n" "${error_lines}" | sed 's/^/    /'
        fi
    fi

    printf "${C_DIM}%s${C_RESET}\n" "${sub_divider}"
    printf "  ${C_GREEN}${C_BOLD}Next Steps to Resolve:${C_RESET}\n"
    printf "  1. Inspect full log output above for specific mod/plugin incompatibilities.\n"
    printf "  2. If Java version mismatch occurs, select compatible JAVA_VERSION in panel Variables.\n"
    printf "  3. Trigger 'Reinstall Server' if server files or libraries are corrupted.\n"
    printf "  4. Full launcher/crash history is saved in error.log (panel File Manager).\n"
    printf "${C_RED}${C_BOLD}%s${C_RESET}\n\n" "${divider}"
}

# Unified Java launch with graceful shutdown for ALL Java types.
# BungeeCord-family proxies use "end" instead of "stop" - translated automatically.
case "${TYPE}" in
    bungeecord | waterfall | velocity)
        launch_with_fifo "${JAVA_CMD}" 1
        EXIT_STATUS=$?
        ;;
    *)
        launch_with_fifo "${JAVA_CMD}" 0
        EXIT_STATUS=$?
        ;;
esac

if [ ${EXIT_STATUS} -ne 0 ] && [ ${EXIT_STATUS} -ne 130 ] && [ ${EXIT_STATUS} -ne 143 ]; then
    elog "=== CRASH: exit=${EXIT_STATUS} type=${TYPE} mc=${MINECRAFT_VERSION:-latest} ==="
    elog "java=$(java -version 2>&1 | head -n1) | flags_source=${FLAGS_SOURCE:-JAVA_FLAGS} mem=${SERVER_MEMORY:-1024}"
    elog "command=${JAVA_CMD}"
    [ -f eula.txt ] && elog "eula: $(grep -i '^eula' eula.txt 2>/dev/null | head -n1)"
    if [ -f logs/latest.log ]; then
        elog "--- last errors from logs/latest.log ---"
        grep -iE '(error|exception|fatal|failed)' logs/latest.log 2>/dev/null | tail -n20 >> "${ERROR_LOG}" 2>/dev/null || true
    fi
    print_crash_diagnostics "${EXIT_STATUS}"
    elog "--- end crash diagnostics ---"
else
    elog "=== server process exited cleanly (code ${EXIT_STATUS}) ==="
fi

exit ${EXIT_STATUS}