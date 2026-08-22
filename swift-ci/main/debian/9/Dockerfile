FROM debian:9

ARG BUILD_USER_ID=998
ARG BUILD_GROUP_ID=998

RUN groupadd -g ${BUILD_GROUP_ID} build-user && \
    useradd -m -r -u ${BUILD_USER_ID} -g build-user build-user

ENV DEBIAN_FRONTEND="noninteractive"

RUN sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list
RUN sed -i s/security.debian.org/archive.debian.org/g /etc/apt/sources.list
RUN sed -i s/stretch-updates/stretch/g /etc/apt/sources.list
RUN apt-get update

RUN apt-get --no-install-recommends -y install \
  build-essential       \
  ca-certificates       \
  clang                 \
  cmake                 \
  curl                  \
  git                   \
  icu-devtools          \
  libcurl4-openssl-dev  \
  libedit-dev           \
  libicu-dev            \
  libncurses5-dev       \
  libsqlite3-dev        \
  libxml2-dev           \
  ninja-build           \
  pkg-config            \
  python                \
  python3-setuptools    \
  python3-dev           \
  python3-pip           \
  python-six            \
  rsync                 \
  swig                  \
  systemtap-sdt-dev     \
  tzdata                \
  unzip                 \
  uuid-dev

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt

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
