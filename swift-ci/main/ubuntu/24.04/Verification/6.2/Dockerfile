# This docker image is used to verify the output of the 6.2 bootstrap artifacts by building
# swift on the main branch. They are not bootstrapping a branches source directly
FROM ubuntu:24.04

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y update && apt-get -y install \
  build-essential       \
  cmake                 \
  git                   \
  icu-devtools          \
  libc++-18-dev         \
  libc++abi-18-dev      \
  libcurl4-openssl-dev  \
  libedit-dev           \
  libicu-dev            \
  libncurses5-dev       \
  libpython3-dev        \
  libsqlite3-dev        \
  libxml2-dev           \
  ninja-build           \
  pkg-config            \
  python3-six           \
  python3-pip           \
  python3-pkg-resources \
  python3-psutil        \
  python3-setuptools    \
  rsync                 \
  swig                  \
  systemtap-sdt-dev     \
  tzdata                \
  uuid-dev              \
  zip

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt --break-system-packages

ARG SWIFT_PLATFORM=ubuntu24.04
ARG SWIFT_VERSION=6.2
ARG SWIFT_WEBROOT=https://download.swift.org
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
    SWIFT_BIN_URL="$SWIFT_WEBROOT/tmp-ci-nightly/development/swift-6.2-bootstrap/ubuntu2404$OS_ARCH_SUFFIX/latest.tar.gz" \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -q update && apt-get -q install -y curl && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz \
    && mkdir -p $SWIFT_PREFIX \
    && tar -xzf swift.tar.gz --directory $SWIFT_PREFIX \
    && ls -la $SWIFT_PREFIX/usr/lib/ \
    && chmod -R o+r $SWIFT_PREFIX/usr/lib/swift \
    && rm -rf "$GNUPGHOME" swift.tar.gz \
    && apt-get purge --auto-remove -y curl

ENV PATH="${SWIFT_PREFIX}/usr/bin:${PATH}"

USER build-user

WORKDIR /home/build-user