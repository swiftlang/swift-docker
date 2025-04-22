FROM debian:12

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get -q install -y \
    binutils-gold \
    curl \
    gpg \
    libicu-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libsqlite3-dev \
    libncurses-dev \
    libpython3-dev \
    libxml2-dev \
    pkg-config \
    uuid-dev \
    tzdata \
    git \
    gcc \
    libstdc++-12-dev \
    && rm -r /var/lib/apt/lists/*


ARG SWIFT_SIGNING_KEY=E813C892820A6FA13755B268F167DF1ACF9CE069
ARG SWIFT_PLATFORM=debian12
ARG SWIFT_VERSION=6.1
ARG SWIFT_WEBROOT=https://download.swift.org/swift-6.1-branch
ARG SWIFT_WEBROOT="$SWIFT_WEBROOT/$SWIFT_PLATFORM"
ARG SWIFT_PREFIX=/opt/swift/${SWIFT_VERSION}

ENV SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_VERSION=$SWIFT_VERSION \
    SWIFT_WEBROOT=$SWIFT_WEBROOT \
    SWIFT_PREFIX=$SWIFT_PREFIX

RUN set -e; \
    ARCH_NAME="$(dpkg --print-architecture)"; \
    url=; \
    case "${ARCH_NAME##*-}" in \
        'amd64') \
            OS_ARCH_SUFFIX=''; \
            ;; \
        'arm64') \
            OS_ARCH_SUFFIX='-aarch64'; \
            ;; \
        *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac; \
    export $(curl -s ${SWIFT_WEBROOT}${OS_ARCH_SUFFIX}/latest-build.yml | grep 'download:' | sed 's/:[^:\/\/]/=/g') \
    && export $(curl -s ${SWIFT_WEBROOT}${OS_ARCH_SUFFIX}/latest-build.yml | grep 'download_signature:' | sed 's/:[^:\/\/]/=/g') \
    && export DOWNLOAD_DIR=$(echo $download | sed "s/-${SWIFT_PLATFORM}${OS_ARCH_SUFFIX}.tar.gz//g") \
    && echo $DOWNLOAD_DIR > .swift_tag \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL ${SWIFT_WEBROOT}${OS_ARCH_SUFFIX}/${DOWNLOAD_DIR}/${download} -o latest_toolchain.tar.gz \
    ${SWIFT_WEBROOT}${OS_ARCH_SUFFIX}/${DOWNLOAD_DIR}/${download} -o latest_toolchain.tar.gz.sig \
    && curl -fSsL --compressed https://swift.org/keys/all-keys.asc | gpg --import -  \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && mkdir -p $SWIFT_PREFIX \
    && tar -xzf latest_toolchain.tar.gz --directory $SWIFT_PREFIX --strip-components=1 \
    && chmod -R o+r $SWIFT_PREFIX/usr/lib/swift \
    && rm -rf "$GNUPGHOME" latest_toolchain.tar.gz.sig latest_toolchain.tar.gz

ENV PATH="${SWIFT_PREFIX}/usr/bin:${PATH}"

USER build-user

WORKDIR /home/build-user

# Print Installed Swift Version
RUN swift --version
