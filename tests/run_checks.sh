#!/bin/bash
# Multi-Minecraft Egg - Shell Docker Validation Suite
set -uo pipefail

IMAGE="${DOCKER_IMAGE:-potenfyr-test:all}"

echo -e "\033[1;33m=== Multi-Minecraft Egg Docker Test Suite ===\033[0m"
echo -e "Testing Image: \033[36m${IMAGE}\033[0m\n"

PASSED=0
FAILED=0

test_loader() {
    local type="$1" ver="$2" file="$3" desc="$4"
    echo -e "\033[1;36m[CHECK]\033[0m Testing ${desc} (${type} ${ver})..."
    if docker run --rm --user container \
        -e "SERVER_TYPE=${type}" \
        -e "MINECRAFT_VERSION=${ver}" \
        -e "SERVER_MEMORY=1024" \
        "${IMAGE}" \
        bash -c "bash /install.sh && test -f ${file}"; then
        echo -e "\033[1;32m[PASS]\033[0m ${desc} verified (${file} exists)\n"
        ((PASSED++))
    else
        echo -e "\033[1;31m[FAIL]\033[0m ${desc} failed\n"
        ((FAILED++))
    fi
}

test_loader "vanilla" "1.20.4" "server.jar" "Vanilla 1.20.4"
test_loader "paper" "1.20.4" "server.jar" "Paper 1.20.4"
test_loader "purpur" "1.20.4" "server.jar" "Purpur 1.20.4"
test_loader "folia" "latest" "server.jar" "Folia Latest"
test_loader "fabric" "1.20.4" "server.jar" "Fabric 1.20.4"
test_loader "quilt" "1.20.4" "server.jar" "Quilt 1.20.4"
test_loader "velocity" "latest" "server.jar" "Velocity Latest"
test_loader "waterfall" "latest" "server.jar" "Waterfall Latest"
test_loader "bungeecord" "latest" "server.jar" "BungeeCord Latest"
test_loader "bedrock" "latest" "bedrock_server" "Bedrock Latest"
test_loader "pocketmine" "latest" "PocketMine-MP.phar" "PocketMine-MP Latest"

echo -e "\033[1;33m=== Test Summary ===\033[0m"
echo -e "Passed: \033[32m${PASSED}\033[0m | Failed: \033[31m${FAILED}\033[0m"

if [ "${FAILED}" -gt 0 ]; then
    exit 1
fi
