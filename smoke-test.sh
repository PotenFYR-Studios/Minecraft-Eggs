#!/bin/bash
# smoke-test.sh: verify run.sh panel behavior (start/stop) for all launch paths.
# Simulates what Pterodactyl does:
#   1. direct-stdin server (vanilla): panel writes "stop" to stdin -> clean exit 0
#   2. proxy (velocity): SIGTERM -> launcher sends translated "end" -> exit 0
set -u
RUNSH="$(cd "$(dirname "$0")" && pwd)/run.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/bin"
cat > "$WORK/bin/java" <<'EOF'
#!/bin/bash
echo "fake-java started pid $$"
while IFS= read -r line; do
    echo "console> $line"
    if [ "$line" = "stop" ] || [ "$line" = "end" ]; then
        echo "fake-java stopping gracefully"
        exit 0
    fi
done
echo "EOF-received"
exit 1
EOF
chmod +x "$WORK/bin/java"
touch "$WORK/server.jar"
cd "$WORK"

fail=0

echo "== test 1: vanilla, 'stop' via panel stdin =="
printf 'stop\n' | PATH="$WORK/bin:$PATH" SERVER_TYPE=vanilla bash "$RUNSH" \
    >"$WORK/t1.log" 2>&1
rc=$?
if [ "$rc" -eq 0 ] && grep -qa "console> stop" "$WORK/t1.log"; then
    echo "PASS: stdin delivered, launcher exit=$rc"
else
    echo "FAIL: exit=$rc; console line missing?"
    sed 's/\x1b\[[0-9;]*m//g' "$WORK/t1.log" | tail -6
    fail=1
fi

echo
echo "== test 2: velocity, SIGTERM graceful shutdown (translated 'end') =="
PATH="$WORK/bin:$PATH" SERVER_TYPE=velocity bash "$RUNSH" </dev/null \
    >"$WORK/t2.log" 2>&1 &
pid=$!
sleep 3
kill -TERM "$pid"
ok=""
for _ in $(seq 1 40); do
    kill -0 "$pid" 2>/dev/null || { ok=yes; break; }
    sleep 1
done
if [ "$ok" = yes ]; then
    wait "$pid"; vrc=$?
    if [ "$vrc" -eq 0 ] && grep -qa "console> end" "$WORK/t2.log"; then
        echo "PASS: SIGTERM handled, translated 'end' delivered, exit=$vrc"
    else
        echo "FAIL: exit=$vrc or missing 'console> end'"
        sed 's/\x1b\[[0-9;]*m//g' "$WORK/t2.log" | tail -6
        fail=1
    fi
else
    echo "FAIL: survived SIGTERM beyond grace window"
    kill -KILL "$pid" 2>/dev/null
    fail=1
fi

echo
echo "== test 3: kill-button path - server ignores stop, SIGTERM then SIGKILL, exit still 0 =="
mkdir -p "$WORK/stub"
printf '#!/bin/bash\ntrap "" TERM INT\nsleep 600\n' > "$WORK/stub/java"
chmod +x "$WORK/stub/java"
PATH="$WORK/stub:$WORK/bin:$PATH" SERVER_TYPE=paper bash "$RUNSH" </dev/null \
    >"$WORK/t3.log" 2>&1 &
pid=$!
sleep 3
kill -TERM "$pid"
t3ok=""
for _ in $(seq 1 75); do
    kill -0 "$pid" 2>/dev/null || { t3ok=yes; break; }
    sleep 1
done
if [ "$t3ok" = yes ]; then
    wait "$pid"; rc3=$?
    if [ "$rc3" -eq 0 ] && grep -qa "force killing" "$WORK/t3.log"; then
        echo "PASS: hung server SIGTERM->SIGKILL handled, launcher exit=0 (no false 'crashed')"
    else
        echo "FAIL: exit=$rc3 or missing force-kill step"
        sed 's/\x1b\[[0-9;]*m//g' "$WORK/t3.log" | tail -6
        fail=1
    fi
else
    echo "FAIL: survived kill sequence beyond grace window"
    kill -KILL "$pid" 2>/dev/null
    fail=1
fi

echo
[ "$fail" -eq 0 ] && echo "ALL TESTS PASSED" || echo "SOME TESTS FAILED"
exit $fail
