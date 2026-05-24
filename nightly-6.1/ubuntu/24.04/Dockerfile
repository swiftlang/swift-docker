FROM ubuntu:24.04
LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get -q install -y \
    binutils \
    curl \
    git \
    gnupg2 \
    libc6-dev \
    libcurl4-openssl-dev \
    libncurses5-dev       \
    libedit2 \
    libgcc-13-dev \
    libpython3-dev \
    libsqlite3-0 \
    libstdc++-13-dev \
    libxml2-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    zlib1g-dev \
    && rm -r /var/lib/apt/lists/*

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little

# gpg --keyid-format LONG -k F167DF1ACF9CE069
# pub   rsa4096/F167DF1ACF9CE069 2021-11-08 [SC] [expires: 2025-11-09]
#       E813C892820A6FA13755B268F167DF1ACF9CE069
# uid                 [ unknown] Swift Automatic Signing Key #4 <swift-infrastructure@forums.swift.org>
ARG SWIFT_SIGNING_KEY=E813C892820A6FA13755B268F167DF1ACF9CE069
ARG SWIFT_PLATFORM=ubuntu
ARG OS_MAJOR_VER=24
ARG OS_MIN_VER=04
ARG SWIFT_VERSION=6.1
ARG SWIFT_WEBROOT=https://download.swift.org/swift-6.1-branch
ARG SWIFT_PREFIX=/opt/swift/${SWIFT_VERSION}

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    OS_MAJOR_VER=$OS_MAJOR_VER \
    OS_MIN_VER=$OS_MIN_VER \
    OS_VER=$SWIFT_PLATFORM$OS_MAJOR_VER.$OS_MIN_VER \
    SWIFT_WEBROOT="$SWIFT_WEBROOT/$SWIFT_PLATFORM$OS_MAJOR_VER$OS_MIN_VER" \
    SWIFT_PREFIX=$SWIFT_PREFIX

RUN echo "${SWIFT_WEBROOT}/latest-build.yml"

RUN set -e; \
    export $(curl -s ${SWIFT_WEBROOT}/latest-build.yml | grep 'download:' | sed 's/:[^:\/\/]/=/g')  \
    && export $(curl -s ${SWIFT_WEBROOT}/latest-build.yml | grep 'download_signature:' | sed 's/:[^:\/\/]/=/g')  \
    && export DOWNLOAD_DIR=$(echo $download | sed "s/-${OS_VER}.tar.gz//g") \
    && echo $DOWNLOAD_DIR > .swift_tag \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL ${SWIFT_WEBROOT}/${DOWNLOAD_DIR}/${download} -o latest_toolchain.tar.gz \
    ${SWIFT_WEBROOT}/${DOWNLOAD_DIR}/${download_signature} -o latest_toolchain.tar.gz.sig \
    && curl -fSsL --compressed https://swift.org/keys/all-keys.asc | gpg --import -  \
    && gpg --batch --verify latest_toolchain.tar.gz.sig latest_toolchain.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && mkdir -p $SWIFT_PREFIX \
    && tar -xzf latest_toolchain.tar.gz --directory $SWIFT_PREFIX --strip-components=1 \
    && chmod -R o+r $SWIFT_PREFIX/usr/lib/swift \
    # This is a compatibility workaround for those who expect `swift` to be in `/usr/bin/`.
    && ln -sf $SWIFT_PREFIX/usr/bin/* /usr/bin/ \
    && rm -rf "$GNUPGHOME" latest_toolchain.tar.gz.sig latest_toolchain.tar.gz \
    && apt-get purge --auto-remove -y curl

ENV PATH="${SWIFT_PREFIX}/usr/bin:${PATH}"
ENV LD_LIBRARY_PATH="${SWIFT_PREFIX}/usr/lib/swift/linux"

# Print Installed Swift Version
RUN swift --version

RUN echo "[ -n \"\${TERM:-}\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bash.bashrc; \
    ( \
      printf "################################################################\n"; \
      printf "# %-60s #\n" ""; \
      printf "# %-60s #\n" "Swift Nightly Docker Image"; \
      printf "# %-60s #\n" "Tag: $(cat .swift_tag)"; \
      printf "# %-60s #\n" ""; \
      printf "################################################################\n" \
    ) > /etc/motd
