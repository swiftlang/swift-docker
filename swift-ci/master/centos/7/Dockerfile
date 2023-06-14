FROM centos:7

RUN yum install shadow-utils.x86_64 -y

RUN groupadd -g 1000 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum install -y epel-release centos-release-scl

RUN yum install --enablerepo=centosplus  -y \
    autoconf            \
    cmake               \
    devtoolset-8        \
    glibc-static        \
    libatomic           \
    libcurl-devel       \
    libedit-devel       \
    libstdc++-static    \
    libtool             \
    libuuid-devel       \
    libxml2-devel       \
    llvm-toolset-7.0    \
    make                \
    ncurses-devel       \
    ninja-build         \
    openssl-devel       \
    pexpect             \
    python-devel        \
    python3-devel       \
    python-pygments     \
    python-six          \
    python36-pexpect    \
    python36-six        \
    PyYAML              \
    rsync               \
    sclo-git25-git      \
    sqlite-devel        \
    swig3               \
    which               \
    unzip               \
    zip                 \
    zlib-devel

RUN echo -e ". /opt/rh/sclo-git25/enable\n. /opt/rh/llvm-toolset-7.0/enable\n. /opt/rh/devtoolset-8/enable\n" >> /home/build-user/.bashrc

RUN echo /opt/rh/llvm-toolset-7.0/root/usr/lib64/ > /etc/ld.so.conf.d/llvm-toolset.conf
RUN ldconfig

RUN sed -i -e 's/\*__block/\*__libc_block/g' /usr/include/unistd.h

ARG SWIFT_SIGNING_KEY=A62AE125BBBFBB96A6E042EC925CC1CCED3D1561
ARG SWIFT_PLATFORM=centos7
ARG SWIFT_BRANCH=swift-5.8.1-release
ARG SWIFT_VERSION=swift-5.8.1-RELEASE
ARG SWIFT_WEBROOT=https://download.swift.org

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_VERSION=$SWIFT_VERSION \
    SWIFT_WEBROOT=$SWIFT_WEBROOT

RUN set -e; \
    SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)" \
    && SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz" \
    && SWIFT_SIG_URL="$SWIFT_BIN_URL.sig" \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz "$SWIFT_SIG_URL" -o swift.tar.gz.sig \
    && gpg --batch --quiet --keyserver keyserver.ubuntu.com --recv-keys "$SWIFT_SIGNING_KEY" \
    && gpg --batch --verify swift.tar.gz.sig swift.tar.gz \
    && mkdir -p /opt/swift \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && tar -xzf swift.tar.gz --directory /opt/swift/ --strip-components=1 \
    && chmod -R o+r /opt/swift/usr/lib/swift \
    && ln -s /opt/swift/usr/lib/swift /usr/lib/swift \
    && rm -rf "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz

ENV PATH="${PATH}:/opt/swift/usr/bin"

RUN swift --version

USER build-user

WORKDIR /home/build-user

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
