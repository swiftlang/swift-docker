FROM amazonlinux:2023

RUN yum install shadow-utils -y

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum -y group install "development tools"
RUN yum -y install \
  cmake \
  ninja-build \
  curl-devel \
  gcc-c++ \
  clang \
  git \
  glibc-static \
  libbsd-devel \
  libedit-devel \
  libicu-devel \
  libstdc++-static \
  libuuid-devel \
  libxml2-devel \
  ncurses-devel \
  pkgconfig \
  procps-ng \
  python3 \
  python3-devel \
  python3-distro \
  python3-setuptools \
  rsync \
  sqlite-devel \
  swig \
  tzdata \
  unzip \
  zip \
  lld \
  diffutils


# TODO: Still need to install bits for lldb

USER build-user
WORKDIR /home/build-user
