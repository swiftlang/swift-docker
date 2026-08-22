FROM fedora:40

ARG BUILD_USER_ID=998
ARG BUILD_GROUP_ID=998

RUN groupadd -g ${BUILD_GROUP_ID} build-user && \
    useradd -m -r -u ${BUILD_USER_ID} -g build-user build-user

RUN yum install -y    \
  curl                \
  libcurl-devel       \
  libedit-devel       \
  libicu-devel        \
  sqlite-devel        \
  libuuid-devel       \
  libxml2-devel       \
  python3             \
  python3-pip         \
  python3-devel       \
  python3-distro      \
  python3-setuptools  \
  python3-six         \
  rsync               \
  swig                \
  clang               \
  perl-podlators      \
  which               \
  git                 \
  cmake               \
  zip                 \
  unzip               \
  diffutils

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
