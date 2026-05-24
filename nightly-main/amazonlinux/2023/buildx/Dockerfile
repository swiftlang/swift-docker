FROM amazonlinux:2023 AS base
LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

RUN dnf -y install \
  binutils \
  gcc \
  git \
  unzip \
  glibc-static \
  gzip \
  libbsd \
  libcurl-devel \
  libedit \
  libicu \
  libstdc++-static \
  libuuid \
  libxml2-devel \
  openssl-devel \
  tar \
  tzdata

# Bug: https://github.com/amazonlinux/amazon-linux-2023/issues/243
RUN dnf -y swap gnupg2-minimal gnupg2-full

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little

ARG SWIFT_SIGNING_KEY=E813C892820A6FA13755B268F167DF1ACF9CE069
ARG SWIFT_PLATFORM=amazonlinux2023
ARG SWIFT_VERSION=6.4
ARG SWIFT_WEBROOT=https://download.swift.org/development
ARG SWIFT_WEBROOT="$SWIFT_WEBROOT/$SWIFT_PLATFORM"
ARG SWIFT_PREFIX=/opt/swift/${SWIFT_VERSION}

# This is a small trick to enable if/else for arm64 and amd64.
# Because of https://bugs.swift.org/browse/SR-14872 we need adjust tar options.
FROM base AS base-amd64
ARG OS_ARCH_SUFFIX=

FROM base AS base-arm64
ARG OS_ARCH_SUFFIX=-aarch64

FROM base-$TARGETARCH AS final

ARG PLATFORM_WEBROOT="$SWIFT_WEBROOT$OS_ARCH_SUFFIX"

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_WEBROOT=$SWIFT_WEBROOT \
    SWIFT_PREFIX=$SWIFT_PREFIX

RUN echo "${PLATFORM_WEBROOT}/latest-build.yml"

RUN set -e; \
    export $(curl -s ${PLATFORM_WEBROOT}/latest-build.yml | grep 'download:' | sed 's/:[^:\/\/]/=/g') \
    && export $(curl -s ${PLATFORM_WEBROOT}/latest-build.yml | grep 'download_signature:' | sed 's/:[^:\/\/]/=/g') \
    && export DOWNLOAD_DIR=$(echo $download | sed "s/-${SWIFT_PLATFORM}${OS_ARCH_SUFFIX}.tar.gz//g") \
    && echo $DOWNLOAD_DIR > .swift_tag \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL ${PLATFORM_WEBROOT}/${DOWNLOAD_DIR}/${download} -o latest_toolchain.tar.gz \
    ${PLATFORM_WEBROOT}/${DOWNLOAD_DIR}/${download_signature} -o latest_toolchain.tar.gz.sig \
    && curl -fSsL --compressed https://swift.org/keys/all-keys.asc | gpg --import - \
    && gpg --batch --verify latest_toolchain.tar.gz.sig latest_toolchain.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && mkdir -p $SWIFT_PREFIX \
    && tar -xzf latest_toolchain.tar.gz --directory $SWIFT_PREFIX --strip-components=1 \
    && chmod -R o+r $SWIFT_PREFIX/usr/lib/swift \
    # This is a compatibility workaround for those who expect `swift` to be in `/usr/bin/`.
    && ln -sf $SWIFT_PREFIX/usr/bin/* /usr/bin/ \
    && rm -rf "$GNUPGHOME" latest_toolchain.tar.gz.sig latest_toolchain.tar.gz

ENV PATH="${SWIFT_PREFIX}/usr/bin:${PATH}"
ENV LD_LIBRARY_PATH="${SWIFT_PREFIX}/usr/lib/swift/linux"

# Print Installed Swift Version
RUN swift --version

RUN echo "[ -n \"\${TERM:-}\" -a -r /etc/motd ] && cat /etc/motd" >> /etc/bashrc; \
    ( \
      printf "################################################################\n"; \
      printf "# %-60s #\n" ""; \
      printf "# %-60s #\n" "Swift Nightly Docker Image"; \
      printf "# %-60s #\n" "Tag: $(cat .swift_tag)"; \
      printf "# %-60s #\n" ""; \
      printf "################################################################\n" \
    ) > /etc/motd

RUN echo 'source /etc/bashrc' >> /root/.bashrc
