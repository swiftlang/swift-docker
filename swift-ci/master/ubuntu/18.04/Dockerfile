FROM ubuntu:18.04

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt -y update && apt -y install \
  build-essential       \
  autoconf              \
  curl                  \
  clang                 \
  cmake                 \
  git                   \
  icu-devtools          \
  libblocksruntime-dev  \
  libbsd-dev            \
  libcurl4-openssl-dev  \
  libedit-dev           \
  libicu-dev            \
  libkqueue-dev         \
  libncurses5-dev       \
  libpython-dev         \
  libpython3-dev        \
  libsqlite3-dev        \
  libtool               \
  libxml2-dev           \
  llvm                  \
  ninja-build           \
  pkg-config            \
  python                \
  python-six            \
  python3-six           \
  python3-distutils     \
  rsync                 \
  swig                  \
  systemtap-sdt-dev     \
  tzdata                \
  unzip                 \
  uuid-dev

USER build-user

WORKDIR /home/build-user
