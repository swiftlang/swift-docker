FROM ubuntu:resolute

ARG BUILD_USER_ID=998
ARG BUILD_GROUP_ID=998

RUN groupadd -g ${BUILD_GROUP_ID} build-user && \
    useradd -m -r -u ${BUILD_USER_ID} -g build-user build-user

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y update && apt-get -y install \
  binutils-gold         \
  build-essential       \
  clang                 \
  cmake                 \
  curl                  \
  git                   \
  icu-devtools          \
  libc++-20-dev         \
  libc++abi-20-dev      \
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

ARG SCCACHE_VERSION=v0.17.0
RUN set -e; \
    ARCH_NAME="$(dpkg --print-architecture)"; \
    case "$ARCH_NAME" in \
        'amd64') SCCACHE_ARCH='x86_64' ;; \
        'arm64') SCCACHE_ARCH='aarch64' ;; \
        *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-${SCCACHE_ARCH}-unknown-linux-musl.tar.gz" -o sccache.tar.gz \
    && tar -xzf sccache.tar.gz \
    && install -m 755 "sccache-${SCCACHE_VERSION}-${SCCACHE_ARCH}-unknown-linux-musl/sccache" /usr/local/bin/sccache \
    && rm -rf sccache.tar.gz "sccache-${SCCACHE_VERSION}-${SCCACHE_ARCH}-unknown-linux-musl"

USER build-user
WORKDIR /home/build-user
