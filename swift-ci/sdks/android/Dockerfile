# ===----------------------------------------------------------------------===
#
#  Swift Android SDK: Docker-based build
#
# ===----------------------------------------------------------------------===

FROM ubuntu:24.04

# Architecture to build on (empty means x86-64)
ARG OS_ARCH_SUFFIX=

# the Swift toolchain URL to download
ARG SWIFT_TOOLCHAIN_URL=

# ............................................................................

# Install development tools
RUN apt-get -q update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q install -y \
    build-essential \
    cmake \
    ninja-build \
    python3 \
    golang \
    git \
    gnupg2 \
    libsqlite3-dev \
    libcurl4-openssl-dev  \
    libedit-dev           \
    libicu-dev            \
    libncurses5-dev       \
    libpython3-dev        \
    libsqlite3-dev        \
    libxml2-dev           \
    rsync \
    uuid-dev \
    uuid-runtime \
    tzdata \
    curl \
    unzip \
    && rm -rf /var/lib/apt-lists/*

# Install Swift
ARG SWIFT_SIGNING_KEY=E813C892820A6FA13755B268F167DF1ACF9CE069
ARG SWIFT_PLATFORM=ubuntu
ARG OS_MAJOR_VER=24
ARG OS_MINOR_VER=04

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    OS_MAJOR_VER=$OS_MAJOR_VER \
    OS_MINOR_VER=$OS_MINOR_VER \
    OS_VER=$SWIFT_PLATFORM$OS_MAJOR_VER.$OS_MINOR_VER

COPY scripts/install-swift.sh /scripts/install-swift.sh
RUN chmod ugo+x /scripts/install-swift.sh
RUN /scripts/install-swift.sh /usr/local/swift
ENV PATH="/usr/local/swift/bin:${PATH}"

ARG ANDROID_NDK_VERSION=

ENV ANDROID_NDK_VERSION=$ANDROID_NDK_VERSION

COPY scripts/install-ndk.sh /scripts/install-ndk.sh
RUN chmod ugo+x /scripts/install-ndk.sh
RUN /scripts/install-ndk.sh
ENV ANDROID_NDK_HOME="/usr/local/ndk/${ANDROID_NDK_VERSION}"

ENV SWIFT_VERSION=$SWIFT_VERSION \
    LIBXML2_VERSION=$LIBXML2_VERSION \
    CURL_VERSION=$CURL_VERSION \
    BORINGSSL_VERSION=$BORINGSSL_VERSION \
    ICU_VERSION=$ICU_VERSION \
    ZLIB_VERSION=$ZLIB_VERSION

ENV SWIFT_BUILD_DOCKER="1"

COPY scripts /scripts
RUN chmod ugo+x /scripts/*

# Create a user
RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

USER build-user

WORKDIR /home/build-user
