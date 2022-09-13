FROM ubuntu:20.04 AS base
LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get -q install -y \
    binutils \
    git \
    unzip \
    gnupg2 \
    libc6-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgcc-9-dev \
    libpython3.8 \
    libsqlite3-0 \
    libstdc++-9-dev \
    libxml2-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    zlib1g-dev \
    && rm -r /var/lib/apt/lists/*

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little

# gpg --keyid-format LONG -k FAF6989E1BC16FEA
# pub   rsa4096/FAF6989E1BC16FEA 2019-11-07 [SC] [expires: 2021-11-06]
#       8A7495662C3CD4AE18D95637FAF6989E1BC16FEA
# uid                 [ unknown] Swift Automatic Signing Key #3 <swift-infrastructure@swift.org>
ARG SWIFT_SIGNING_KEY=8A7495662C3CD4AE18D95637FAF6989E1BC16FEA
ARG SWIFT_PLATFORM=ubuntu
ARG OS_MAJOR_VER=20
ARG OS_MIN_VER=04
ARG SWIFT_WEBROOT=https://download.swift.org/development

# This is a small trick to enable if/else for arm64 and amd64.
# Because of https://bugs.swift.org/browse/SR-14872 we need adjust tar options.
FROM base AS base-amd64
ARG OS_ARCH_SUFFIX=

FROM base AS base-arm64
ARG OS_ARCH_SUFFIX=-aarch64

FROM base-$TARGETARCH AS final

ARG OS_VER=$SWIFT_PLATFORM$OS_MAJOR_VER.$OS_MIN_VER$OS_ARCH_SUFFIX
ARG PLATFORM_WEBROOT="$SWIFT_WEBROOT/$SWIFT_PLATFORM$OS_MAJOR_VER$OS_MIN_VER$OS_ARCH_SUFFIX"

RUN echo "${PLATFORM_WEBROOT}/latest-build.yml"

RUN set -e; \
    # - Grab curl here so we cache better up above
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get -q update && apt-get -q install -y curl && rm -rf /var/lib/apt/lists/* \
    # - Latest Toolchain info
    && export $(curl -s ${PLATFORM_WEBROOT}/latest-build.yml | grep 'download:' | sed 's/:[^:\/\/]/=/g')  \
    && export $(curl -s ${PLATFORM_WEBROOT}/latest-build.yml | grep 'download_signature:' | sed 's/:[^:\/\/]/=/g')  \
    && export DOWNLOAD_DIR=$(echo $download | sed "s/-${OS_VER}.tar.gz//g") \
    && echo $DOWNLOAD_DIR > .swift_tag \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL ${PLATFORM_WEBROOT}/${DOWNLOAD_DIR}/${download} -o latest_toolchain.tar.gz \
        ${PLATFORM_WEBROOT}/${DOWNLOAD_DIR}/${download_signature} -o latest_toolchain.tar.gz.sig \
    && curl -fSsL https://swift.org/keys/all-keys.asc | gpg --import -  \
    && gpg --batch --verify latest_toolchain.tar.gz.sig latest_toolchain.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && tar -xzf latest_toolchain.tar.gz --directory / --strip-components=1 \
    && chmod -R o+r /usr/lib/swift \
    && rm -rf "$GNUPGHOME" latest_toolchain.tar.gz.sig latest_toolchain.tar.gz \
    && apt-get purge --auto-remove -y curl

# Print Installed Swift Version
RUN swift --version

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' \
    >> /etc/bash.bashrc; \
    echo " ################################################################\n" \
    "#\t\t\t\t\t\t\t\t#\n" \
    "# Swift Nightly Docker Image\t\t\t\t\t#\n" \
    "# Tag: $(cat .swift_tag)\t\t\t#\n" \
    "#\t\t\t\t\t\t\t\t#\n"  \
    "################################################################\n" > /etc/motd
