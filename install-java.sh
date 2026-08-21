#!/bin/bash
#
# Multi Minecraft - Universal Java runtime installer
#
# Downloads and extracts any Adoptium / OpenJDK JRE or JDK into /opt/java/<version>.
#
# Usage: install-java.sh <version> [arch:x64|aarch64]
#
# Supports:
#   - Official GA releases: 8, 11, 16, 17, 21, 25, 26, ...
#   - Early Access (EA) / Snapshot / Beta / Alpha builds for future versions (27, 28...)
#   - Both JRE and JDK builds (automatic fallback if no standalone JRE exists)
#   - Auto-detection of CPU architecture (x64 / aarch64)

set -euo pipefail

VERSION="${1:-}"
ARCH="${2:-}"

if [ -z "${VERSION}" ]; then
    echo "Usage: install-java.sh <version> [arch]" >&2
    exit 1
fi

if [ -z "${ARCH}" ]; then
    case "$(uname -m)" in
        x86_64|amd64) ARCH="x64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac
fi

TARGET_DIR="/opt/java/${VERSION}"

# If already installed and functional, return immediately
if [ -x "${TARGET_DIR}/bin/java" ]; then
    echo "Java ${VERSION} is already installed at ${TARGET_DIR}"
    exit 0
fi

echo "Resolving and installing Java runtime ${VERSION} (${ARCH})..."

TMP_TAR="/tmp/java_${VERSION}_$$.tar.gz"
trap 'rm -f "${TMP_TAR}"' EXIT

CANDIDATE_URLS=(
    # 1. Adoptium GA JRE (General Availability)
    "https://api.adoptium.net/v3/binary/latest/${VERSION}/ga/linux/${ARCH}/jre/hotspot/normal/eclipse"
    # 2. Adoptium GA JDK (covers versions like 16 that only have JDK packages)
    "https://api.adoptium.net/v3/binary/latest/${VERSION}/ga/linux/${ARCH}/jdk/hotspot/normal/eclipse"
    # 3. Adoptium Early Access (EA) / Beta / Snapshot JRE
    "https://api.adoptium.net/v3/binary/latest/${VERSION}/ea/linux/${ARCH}/jre/hotspot/normal/eclipse"
    # 4. Adoptium Early Access (EA) / Beta / Snapshot JDK (for upcoming versions)
    "https://api.adoptium.net/v3/binary/latest/${VERSION}/ea/linux/${ARCH}/jdk/hotspot/normal/eclipse"
)

DOWNLOADED=0
for url in "${CANDIDATE_URLS[@]}"; do
    if curl -fsSL --retry 2 --connect-timeout 10 -A "MultiMinecraftEgg-JavaInstaller/1.0" -o "${TMP_TAR}" "${url}" 2>/dev/null; then
        if gzip -t "${TMP_TAR}" 2>/dev/null; then
            DOWNLOADED=1
            break
        else
            rm -f "${TMP_TAR}"
        fi
    fi
done

if [ "${DOWNLOADED}" -ne 1 ]; then
    echo "ERROR: Could not find or download Java ${VERSION} for ${ARCH} (tried GA/EA JRE & JDK)." >&2
    exit 1
fi

mkdir -p "${TARGET_DIR}"
tar -xzf "${TMP_TAR}" -C "${TARGET_DIR}" --strip-components=1
chmod +x "${TARGET_DIR}/bin/"* 2>/dev/null || true

echo "Successfully installed Java ${VERSION}:"
"${TARGET_DIR}/bin/java" -version 2>&1 | head -n 1