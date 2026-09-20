#!/bin/bash
# Sandbox test for the git-sync engine embedded in run.sh (Minecraft egg).
# Fully hermetic: exercises the engine against local file:// repositories, so
# no network access and no credential helpers are ever involved.
set -u
cd "$(dirname "$0")/.." || exit 1

# Never let a host credential helper pop a dialog or hang the suite.
export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=/bin/true
export GCM_INTERACTIVE=never
export GIT_CONFIG_SYSTEM=/dev/null

SANDBOX=$(mktemp -d)
export SERVER_DIR="${SANDBOX}/server"
mkdir -p "${SERVER_DIR}"
REPO="${SANDBOX}/repo.git"
WT="${SANDBOX}/wt"
PASS=0; FAIL=0
t_pass() { echo "  PASS: $1"; PASS=$((PASS+1)); }
t_fail() { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
G="git -c user.email=test@potenfyr.in -c user.name=SyncTest -c commit.gpgsign=false"

# Minimal logging stubs (names used by the engine inside run.sh)
log()  { printf '[log] %s\n' "$*"; }
ok()   { printf '[ok] %s\n' "$*"; }
warn() { printf '[warn] %s\n' "$*" >&2; }
info() { printf '[info] %s\n' "$*"; }
error() { printf '[error] %s\n' "$*" >&2; }
phase() { printf '\n== %s ==\n' "$*"; }
_egg_error_log() { :; }

python3 tests/extract_funcs.py run.sh > "${SANDBOX}/functions.sh" || exit 1
# Load the launcher's top-level functions (definitions only - sourcing has no
# side effects) so the real sync engine code under test is exercised.
# shellcheck disable=SC1090
source "${SANDBOX}/functions.sh"
# The protected-path list is a top-level assignment (not a function), so the
# function extractor does not carry it over - pull it from run.sh directly.
# shellcheck disable=SC1091
eval "$(sed -n "/^_PF_SYNC_PROTECTED='/,/'\$/p" run.sh)"
[ -n "${_PF_SYNC_PROTECTED:-}" ] || { echo "FATAL: protected list missing"; exit 1; }

commit() { # commit FILE CONTENT MSG
    mkdir -p "${WT}/$(dirname "$1")" 2>/dev/null || true
    printf '%s\n' "$2" > "${WT}/$1"
    ${G} -C "${WT}" add -A >/dev/null
    ${G} -C "${WT}" commit -qm "$3" >/dev/null
    git -C "${WT}" push -q origin HEAD >/dev/null 2>&1
}

echo "== Minecraft git sync engine tests (hermetic) =="

${G} init -q --bare -b main "${REPO}"
${G} clone -q "${REPO}" "${WT}" 2>/dev/null
commit "plugins/Essentials/Essentials.jar" "fake-jar" "c1"
commit "bukkit.yml" "settings: {}" "c1"

echo "--- T1: no repo configured (must be a silent no-op) ---"
sync_git_repo && t_pass "no-op returns zero" || t_fail "no-op failed"

echo "--- T2: first sync via file:// URL (local repo) ---"
GIT_REPO_URL="file://${REPO}"
sync_git_repo || t_fail "sync returned nonzero"
[ -f "${SERVER_DIR}/plugins/Essentials/Essentials.jar" ] && t_pass "plugin file synced (deep path)" || t_fail "plugin file missing"
[ -f "${SERVER_DIR}/bukkit.yml" ] && t_pass "config synced" || t_fail "config missing"
[ -s "${SERVER_DIR}/.git-sync/manifest" ] && t_pass "file-level manifest written" || t_fail "manifest missing"

echo "--- T3: second run with no new commit (up to date) ---"
out=$(sync_git_repo 2>&1)
printf '%s' "${out}" | grep -qi "up to date" && t_pass "reports up to date" || t_fail "no up-to-date message"

echo "--- T4: protected paths never touched by repo content ---"
printf "server-port=25565\n" > "${SERVER_DIR}/server.properties"
printf "eula=true\n" > "${SERVER_DIR}/eula.txt"
mkdir -p "${SERVER_DIR}/world/playerdata"
echo "inv" > "${SERVER_DIR}/world/playerdata/uuid.dat"
commit "server.properties" "hacked=true" "try overwrite"
commit "world/playerdata/uuid.dat" "stolen" "try overwrite world"
sync_git_repo || t_fail "sync failed with protected content"
grep -q "server-port=25565" "${SERVER_DIR}/server.properties" && t_pass "server.properties preserved" || t_fail "server.properties overwritten"
grep -q "eula=true" "${SERVER_DIR}/eula.txt" && t_pass "eula.txt preserved" || t_fail "eula.txt overwritten"
grep -q "inv" "${SERVER_DIR}/world/playerdata/uuid.dat" && t_pass "world data preserved" || t_fail "world data overwritten"

echo "--- T5: server-written state inside synced dirs survives updates ---"
mkdir -p "${SERVER_DIR}/plugins/Essentials/userdata"
echo '{"money":42}' > "${SERVER_DIR}/plugins/Essentials/userdata/steve.json"
commit "plugins/Essentials/Essentials.jar" "fake-jar-v2" "c2 plugin update"
sync_git_repo || t_fail "plugin update sync failed"
grep -q "fake-jar-v2" "${SERVER_DIR}/plugins/Essentials/Essentials.jar" && t_pass "plugin updated" || t_fail "plugin not updated"
grep -q '{"money":42}' "${SERVER_DIR}/plugins/Essentials/userdata/steve.json" && t_pass "plugin userdata preserved" || t_fail "plugin userdata wiped"

echo "--- T6: upstream deletion propagates per-file ---"
${G} -C "${WT}" rm -q bukkit.yml >/dev/null 2>&1
commit "plugins/Essentials/Essentials.jar" "fake-jar-v3" "c3"
sync_git_repo || t_fail "deletion sync failed"
[ ! -e "${SERVER_DIR}/bukkit.yml" ] && t_pass "upstream deletion propagated" || t_fail "deleted file still present"

echo "--- T7: unreachable repo keeps files, returns non-zero ---"
GIT_REPO_URL="https://127.0.0.1:1/nope.git"
sync_git_repo >/dev/null 2>&1 && t_fail "unreachable repo reported success" || t_pass "failure signalled (non-zero)"
grep -q "fake-jar-v3" "${SERVER_DIR}/plugins/Essentials/Essentials.jar" && t_pass "files kept" || t_fail "files lost"

echo "--- T8: branch switch ---"
${G} -C "${WT}" checkout -qb test
commit "plugins/Other/other.jar" "other" "branch c1"
${G} -C "${WT}" checkout -q main
GIT_REPO_URL="file://${REPO}"
GIT_BRANCH="test"
sync_git_repo || t_fail "branch switch failed"
[ -f "${SERVER_DIR}/plugins/Other/other.jar" ] && t_pass "branch content synced" || t_fail "branch switch failed"

echo "--- T9: GIT_PRESERVE_ENV keeps live .env credentials across updates ---"
GIT_BRANCH=""
mkdir -p "${SERVER_DIR}/plugins/Essentials"
printf 'DB_PASSWORD=live-secret\n' > "${SERVER_DIR}/.env"
printf 'PLUGIN_KEY=live-plugin-secret\n' > "${SERVER_DIR}/plugins/Essentials/.env"
commit ".env" "DB_PASSWORD=repo-override" "c4 repo env"
commit "plugins/Essentials/.env" "PLUGIN_KEY=repo-plugin-override" "c4 plugin env"
sync_git_repo || t_fail ".env update sync failed"
grep -q "live-secret" "${SERVER_DIR}/.env" && t_pass "root .env preserved (old credentials win)" || t_fail "root .env clobbered"
grep -q "live-plugin-secret" "${SERVER_DIR}/plugins/Essentials/.env" && t_pass "sub-path .env restored in its original location" || t_fail "sub-path .env clobbered"

echo "--- T10: GIT_PRESERVE_ENV=0 lets the repository's .env win ---"
GIT_PRESERVE_ENV=0
commit "plugins/Essentials/.env" "PLUGIN_KEY=repo-plugin-new" "c5 repo env update"
sync_git_repo || t_fail "opt-out sync failed"
grep -q "repo-plugin-new" "${SERVER_DIR}/plugins/Essentials/.env" && t_pass "repo .env wins when opted out" || t_fail "repo .env not applied"
unset GIT_PRESERVE_ENV

echo "--- T11: GIT_EXCLUDE keeps user paths out of the sync ---"
GIT_EXCLUDE="plugins/Other"
commit "plugins/Other/other.jar" "should-not-land" "c6 excluded"
commit "plugins/Essentials/Essentials.jar" "fake-jar-v4" "c6 tracked update"
sync_git_repo || t_fail "exclusion sync failed"
grep -q "should-not-land" "${SERVER_DIR}/plugins/Other/other.jar" && t_fail "GIT_EXCLUDE ignored" || t_pass "excluded path never installed"
grep -q "fake-jar-v4" "${SERVER_DIR}/plugins/Essentials/Essentials.jar" && t_pass "non-excluded paths still sync" || t_fail "exclusion broke normal sync"
unset GIT_EXCLUDE

rm -rf "${SANDBOX}"
echo
echo "Results: $PASS passed, $FAIL failed"
[ "${FAIL}" -eq 0 ]
