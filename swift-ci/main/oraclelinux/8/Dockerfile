FROM oraclelinux:8

ARG BUILD_USER_ID=42
ARG BUILD_GROUP_ID=42

RUN groupadd -g ${BUILD_GROUP_ID} build-user && \
    useradd -m -r -u ${BUILD_USER_ID} -g build-user build-user

RUN yum install -y oracle-epel-release-el8

RUN yum install --enablerepo=ol8_codeready_builder -y \
    autoconf              \
    clang-12.0.1          \
    cmake                 \
    curl                  \
    diffutils             \
    git                   \
    glibc-static          \
    libbsd-devel          \
    libcurl-devel         \
    libedit-devel         \
    libicu-devel          \
    libstdc++-static      \
    libtool               \
    libuuid-devel         \
    libxml2-devel         \
    make                  \
    ncurses-devel         \
    ninja-build           \
    pcre-devel            \
    procps-ng             \
    python2               \
    python2-devel         \
    python2-six           \
    python3               \
    python3-six           \
    python3-pexpect       \
    platform-python-devel \
    sqlite-devel          \
    swig                  \
    rsync                 \
    tar                   \
    unzip                 \
    which                 \
    zip

RUN ln -s /usr/bin/python2 /usr/bin/python

ARG SCCACHE_VERSION=v0.17.0
RUN set -e; \
    ARCH_NAME="$(rpm --eval '%{_arch}')" \
    && curl -fsSL "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-${ARCH_NAME}-unknown-linux-musl.tar.gz" -o sccache.tar.gz \
    && tar -xzf sccache.tar.gz \
    && install -m 755 "sccache-${SCCACHE_VERSION}-${ARCH_NAME}-unknown-linux-musl/sccache" /usr/local/bin/sccache \
    && rm -rf sccache.tar.gz "sccache-${SCCACHE_VERSION}-${ARCH_NAME}-unknown-linux-musl"

USER build-user

WORKDIR /home/build-user
