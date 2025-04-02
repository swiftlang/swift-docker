FROM fedora:39 AS base
LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

RUN yum -y install \
  binutils \
  gcc \
  git \
  unzip \
  libcurl-devel \
  libedit-devel \
  libicu-devel \
  sqlite-devel \
  libuuid-devel \
  libxml2-devel \
  python3-devel \
  libstdc++-devel \
  libstdc++-static


ARG SWIFT_SIGNING_KEY=E813C892820A6FA13755B268F167DF1ACF9CE069
ARG SWIFT_PLATFORM=fedora39
ARG SWIFT_VERSION=6.1
ARG SWIFT_BRANCH=swift-${SWIFT_VERSION}-release
ARG SWIFT_TAG=swift-${SWIFT_VERSION}-RELEASE
ARG SWIFT_WEBROOT=https://download.swift.org/swift-6.1-branch
ARG SWIFT_WEBROOT="$SWIFT_WEBROOT/$SWIFT_PLATFORM"
ARG SWIFT_PREFIX=/opt/swift/${SWIFT_VERSION}

# This is a small trick to enable if/else for arm64 and amd64.
# Because of https://bugs.swift.org/browse/SR-14872 we need adjust tar options.
FROM base AS base-amd64
ARG OS_ARCH_SUFFIX=

FROM base AS base-arm64
ARG OS_ARCH_SUFFIX=-aarch64

FROM base-$TARGETARCH AS final

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_VERSION=$SWIFT_VERSION \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_TAG=$SWIFT_TAG \
    SWIFT_WEBROOT=$SWIFT_WEBROOT \
    SWIFT_PREFIX=$SWIFT_PREFIX

RUN set -e; \
    ARCH_NAME="$(rpm --eval '%{_arch}')"; \
    url=; \
    case "${ARCH_NAME##*-}" in \
        'x86_64') \
            OS_ARCH_SUFFIX=''; \
            ;; \
        'aarch64') \
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
    && curl -fSsL https://swift.org/keys/all-keys.asc | gpg --import -  \
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