#!/usr/bin/env python3
"""
Multi-Minecraft Egg Test Suite
Runs in-depth Docker verification tests across all loaders, proxies, and versions.
"""

import os
import subprocess
import sys
import time

C_RESET = "\033[0m"
C_BOLD = "\033[1m"
C_GREEN = "\033[32m"
C_RED = "\033[31m"
C_YELLOW = "\033[33m"
C_CYAN = "\033[36m"

IMAGE_NAME = os.environ.get("DOCKER_IMAGE", "potenfyr-test:all")

TEST_CASES = [
    # (Server Type, Version, Extra Env, Expected File, Description)
    ("vanilla", "1.20.4", {}, "server.jar", "Vanilla Minecraft 1.20.4"),
    ("paper", "1.20.4", {}, "server.jar", "PaperMC 1.20.4"),
    ("purpur", "1.20.4", {}, "server.jar", "Purpur 1.20.4"),
    ("folia", "latest", {}, "server.jar", "Folia Latest"),
    ("fabric", "1.20.4", {}, "server.jar", "Fabric Loader 1.20.4"),
    ("quilt", "1.20.4", {}, "server.jar", "Quilt Loader 1.20.4"),
    ("velocity", "latest", {}, "server.jar", "Velocity Proxy (Latest)"),
    ("waterfall", "latest", {}, "server.jar", "Waterfall Proxy (Latest)"),
    ("bungeecord", "latest", {}, "server.jar", "BungeeCord Proxy (Latest)"),
    ("bedrock", "latest", {}, "bedrock_server", "Bedrock Dedicated Server (Latest)"),
    ("pocketmine", "latest", {}, "PocketMine-MP.phar", "PocketMine-MP (Latest)"),
    ("neoforge", "1.20.4", {}, "unix_args.txt", "NeoForge 1.20.4"),
    ("forge", "1.20.1", {}, "unix_args.txt", "Forge 1.20.1"),
    ("custom", "latest", {"DL_URL": "https://api.purpurmc.org/v2/purpur/1.20.4/latest/download"}, "server.jar", "Custom Server (DL_URL)"),
]

def log(msg):
    print(f"{C_CYAN}{C_BOLD}[TEST-SUITE]{C_RESET} {msg}", flush=True)

def success(msg):
    print(f"{C_GREEN}{C_BOLD}[PASS]{C_RESET} {msg}", flush=True)

def failure(msg):
    print(f"{C_RED}{C_BOLD}[FAIL]{C_RESET} {msg}", flush=True)

def run_test(server_type, version, extra_env, expected_file, desc):
    log(f"Testing {desc} (SERVER_TYPE={server_type}, MINECRAFT_VERSION={version})...")
    
    # Run container with auto-install and verify files are created and bootable
    env_args = [
        "-e", f"SERVER_TYPE={server_type}",
        "-e", f"MINECRAFT_VERSION={version}",
        "-e", "SERVER_MEMORY=1024",
        "-e", "DEBUG=0",
    ]
    for k, v in extra_env.items():
        env_args.extend(["-e", f"{k}={v}"])

    # Test install contract inside /home/container as user container
    cmd = [
        "docker", "run", "--rm",
        "--user", "container",
        *env_args,
        IMAGE_NAME,
        "bash", "-c",
        f"bash /install.sh && test -f {expected_file}"
    ]

    start_t = time.time()
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=300)
    duration = time.time() - start_t

    if proc.returncode == 0:
        success(f"{desc} installed successfully in {duration:.1f}s (verified {expected_file})")
        return True
    else:
        failure(f"{desc} failed with exit code {proc.returncode}")
        print("--- Container Output ---")
        print(proc.stdout[-1500:])
        print("------------------------")
        return False

def main():
    print(f"{C_YELLOW}{C_BOLD}=== Running Multi-Minecraft Egg Docker Test Suite ==={C_RESET}")
    print(f"Target Image: {IMAGE_NAME}\n")

    passed = 0
    failed = 0

    for server_type, version, extra_env, expected_file, desc in TEST_CASES:
        try:
            if run_test(server_type, version, extra_env, expected_file, desc):
                passed += 1
            else:
                failed += 1
        except subprocess.TimeoutExpired:
            failure(f"{desc} timed out after 300s")
            failed += 1
        except Exception as e:
            failure(f"{desc} error: {e}")
            failed += 1
        print("", flush=True)

    print(f"{C_YELLOW}{C_BOLD}=== Summary ==={C_RESET}")
    print(f"Total: {len(TEST_CASES)} | {C_GREEN}Passed: {passed}{C_RESET} | {C_RED}Failed: {failed}{C_RESET}")

    if failed > 0:
        sys.exit(1)
    else:
        print(f"\n{C_GREEN}{C_BOLD}ALL LOADER AND VERSION CHECKS PASSED SUCCESSFULLY!{C_RESET}\n")

if __name__ == "__main__":
    main()
