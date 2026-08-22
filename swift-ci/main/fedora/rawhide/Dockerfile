FROM fedora:rawhide

RUN groupadd -g 42 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN dnf -y update && dnf install -y \
    clang                       \
    cmake                       \
    curl                        \
    git                         \
    libblocksruntime-static     \
    libbsd-devel                \
    libcurl-devel               \
    libedit-devel               \
    libicu-devel                \
    libsqlite3x-devel           \
    libuuid-devel               \
    libxml2-devel               \
    make                        \
    ninja-build                 \
    python-unversioned-command  \
    python3                     \
    python3-pip                 \
    python3-devel               \
    python3-distro              \
    python3-six                 \
    rsync                       \
    swig

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt

ARG SCCACHE_VERSION=v0.17.0
RUN set -e; \
    ARCH_NAME="$(rpm --eval '%{_arch}')" \
    && curl -fsSL "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-${ARCH_NAME}-unknown-linux-musl.tar.gz" -o sccache.tar.gz \
    && tar -xzf sccache.tar.gz \
    && install -m 755 "sccache-${SCCACHE_VERSION}-${ARCH_NAME}-unknown-linux-musl/sccache" /usr/local/bin/sccache \
    && rm -rf sccache.tar.gz "sccache-${SCCACHE_VERSION}-${ARCH_NAME}-unknown-linux-musl"

USER build-user

WORKDIR /home/build-user

