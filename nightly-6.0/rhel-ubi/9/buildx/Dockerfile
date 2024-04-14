FROM redhat/ubi9 AS base
LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

RUN yum install -y  \
  git               \
  gcc-c++           \
  libcurl-devel     \
  libedit-devel     \
  libuuid-devel     \
  libxml2-devel     \
  ncurses-devel     \
  python3-devel     \
  rsync             \
  sqlite-devel      \
  unzip             \
  zip

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little

# gpg --keyid-format LONG -k F167DF1ACF9CE069
# pub   rsa4096/F167DF1ACF9CE069 2021-11-08 [SC] [expires: 2025-11-09]
#       E813C892820A6FA13755B268F167DF1ACF9CE069
# uid                 [ unknown] Swift Automatic Signing Key #4 <swift-infrastructure@forums.swift.org>
ARG SWIFT_SIGNING_KEY=E813C892820A6FA13755B268F167DF1ACF9CE069
ARG SWIFT_PLATFORM=ubi
ARG OS_MAJOR_VER=9
ARG SWIFT_WEBROOT=https://download.swift.org/swift-6.0-branch

# This is a small trick to enable if/else for arm64 and amd64.
# Because of https://bugs.swift.org/browse/SR-14872 we need adjust tar options.
FROM base AS base-amd64
ARG OS_ARCH_SUFFIX=

FROM base AS base-arm64
ARG OS_ARCH_SUFFIX=-aarch64

FROM base-$TARGETARCH AS final

ARG OS_VER=$SWIFT_PLATFORM$OS_MAJOR_VER$OS_ARCH_SUFFIX
ARG PLATFORM_WEBROOT="$SWIFT_WEBROOT/$SWIFT_PLATFORM$OS_MAJOR_VER$OS_ARCH_SUFFIX"

RUN echo "${PLATFORM_WEBROOT}/latest-build.yml"

RUN set -e; \
    # - Latest Toolchain info
    export $(curl -s ${PLATFORM_WEBROOT}/latest-build.yml | grep 'download:' | sed 's/:[^:\/\/]/=/g')  \
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
