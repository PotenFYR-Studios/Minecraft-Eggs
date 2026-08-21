#!/bin/bash
#
# Downloads and extracts a Temurin (Adoptium) JRE into /opt/java/<version>.
#
# Usage: install-java.sh <major-version> <arch:x64|aarch64>
set -euo pipefail

VERSION="$1"
ARCH="$2"

echo "Installing Temurin JRE ${VERSION} (${ARCH})..."

curl -fsSL "https://api.adoptium.net/v3/binary/latest/${VERSION}/ga/linux/${ARCH}/jre/hotspot/normal/eclipse" \
    -o "/tmp/jre${VERSION}.tar.gz"

mkdir -p "/opt/java/${VERSION}"
tar -xzf "/tmp/jre${VERSION}.tar.gz" -C "/opt/java/${VERSION}" --strip-components=1
rm -f "/tmp/jre${VERSION}.tar.gz"

"/opt/java/${VERSION}/bin/java" -version 2>&1 | head -n 1