FROM amazonlinux:2023

RUN yum install shadow-utils -y

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 42 -g build-user build-user

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

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt

USER build-user
WORKDIR /home/build-user
