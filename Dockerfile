# =============================================================================
#  Multi Minecraft - Universal runtime image
#
#  Default (JAVA_VERSION=all): ships Java 8, 11, 16, 17, 21 and 25 side by
#  side so ONE image can run every Minecraft server ever released. The
#  entrypoint auto-selects the correct JVM per server type / version.
#
#  Slim variants: build with --build-arg JAVA_VERSION=8|11|16|17|21|25 to get
#  a single-JVM image for maximum lightness.
#
#  The image intentionally contains ONLY the JRE (servers never need a JDK at
#  runtime). The Spigot/BuildTools path downloads a temporary JDK at install
#  time, keeping this image as small as possible.
# =============================================================================

ARG JAVA_VERSION=all

FROM ubuntu:jammy

ARG JAVA_VERSION=all
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Base tooling + PHP (PocketMine-MP) + native libraries (Bedrock dedicated server)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        jq \
        unzip \
        xz-utils \
        tzdata \
        iproute2 \
        locales \
        php8.1-cli \
        php8.1-curl \
        php8.1-mbstring \
        php8.1-xml \
        php8.1-bcmath \
        php8.1-gmp \
        libcurl4 \
        libssl3 \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8 || true

# Adoptium's binary API uses x64 / aarch64 arch names.
RUN case "${TARGETARCH}" in \
        amd64) echo "x64" > /tmp/ptero-arch ;; \
        arm64) echo "aarch64" > /tmp/ptero-arch ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac

COPY install-java.sh /usr/local/bin/install-java.sh
RUN chmod +x /usr/local/bin/install-java.sh

# Java 8 - required by anything up to 1.16.5 (and nearly every legacy modpack).
RUN if [ "${JAVA_VERSION}" = "all" ] || [ "${JAVA_VERSION}" = "8" ]; then \
        install-java.sh 8 "$(cat /tmp/ptero-arch)"; \
    fi

# Java 11 - used by several older Forge / modded environments.
RUN if [ "${JAVA_VERSION}" = "all" ] || [ "${JAVA_VERSION}" = "11" ]; then \
        install-java.sh 11 "$(cat /tmp/ptero-arch)"; \
    fi

# Java 16 - the original requirement for Minecraft 1.17.
RUN if [ "${JAVA_VERSION}" = "all" ] || [ "${JAVA_VERSION}" = "16" ]; then \
        install-java.sh 16 "$(cat /tmp/ptero-arch)"; \
    fi

# Java 17 - Minecraft 1.18 through 1.20.4.
RUN if [ "${JAVA_VERSION}" = "all" ] || [ "${JAVA_VERSION}" = "17" ]; then \
        install-java.sh 17 "$(cat /tmp/ptero-arch)"; \
    fi

# Java 21 - Minecraft 1.20.5 through 1.21.x (LTS, most common today).
RUN if [ "${JAVA_VERSION}" = "all" ] || [ "${JAVA_VERSION}" = "21" ]; then \
        install-java.sh 21 "$(cat /tmp/ptero-arch)"; \
    fi

# Java 25 - required by Minecraft 26.x and every future release (LTS).
RUN if [ "${JAVA_VERSION}" = "all" ] || [ "${JAVA_VERSION}" = "25" ]; then \
        install-java.sh 25 "$(cat /tmp/ptero-arch)"; \
    fi

RUN rm -f /tmp/ptero-arch /usr/local/bin/install-java.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/run.sh

WORKDIR /home/container

# Pterodactyl Wings starts the container without overriding CMD/ENTRYPOINT and
# injects the egg's startup command through the STARTUP environment variable
# (see entrypoint.sh for the exact contract).
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD []