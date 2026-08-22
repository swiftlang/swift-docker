FROM amazonlinux:2023

RUN yum install shadow-utils -y

ARG BUILD_USER_ID=42
ARG BUILD_GROUP_ID=998

RUN groupadd -g ${BUILD_GROUP_ID} build-user && \
    useradd -m -r -u ${BUILD_USER_ID} -g build-user build-user

RUN yum -y group install "development tools"
RUN yum -y install \
  ninja-build \
  curl-devel \
  gcc-c++ \
  clang \
  git \
  libbsd-devel \
  libedit-devel \
  libicu-devel \
  libuuid-devel \
  libxml2-devel \
  ncurses-devel \
  pkgconfig \
  procps-ng \
  python3 \
  python3-devel \
  python3-distro \
  python3-setuptools \
  python3-pip \
  rsync \
  sqlite-devel \
  swig \
  tzdata \
  unzip \
  zip \
  lld \
  diffutils \
  which

RUN curl -fsSL "https://github.com/Kitware/CMake/releases/download/v4.0.2/cmake-4.0.2-linux-`uname -m`.tar.gz" \
  | tar --strip-components=1 -xz -C /usr/local

ARG SCCACHE_VERSION=v0.17.0
RUN set -e; \
    SCCACHE_ARCH="$(uname -m)" \
    && curl -fsSL "https://github.com/mozilla/sccache/releases/download/${SCCACHE_VERSION}/sccache-${SCCACHE_VERSION}-${SCCACHE_ARCH}-unknown-linux-musl.tar.gz" -o sccache.tar.gz \
    && tar -xzf sccache.tar.gz \
    && install -m 755 "sccache-${SCCACHE_VERSION}-${SCCACHE_ARCH}-unknown-linux-musl/sccache" /usr/local/bin/sccache \
    && rm -rf sccache.tar.gz "sccache-${SCCACHE_VERSION}-${SCCACHE_ARCH}-unknown-linux-musl"

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt

USER build-user
WORKDIR /home/build-user
