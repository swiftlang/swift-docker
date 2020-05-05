FROM ubuntu:19.10

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update

RUN apt -y install      \
  clang                 \
  cmake                 \
  git                   \
  icu-devtools          \
  libcurl4-openssl-dev  \
  libedit-dev           \
  libicu-dev            \
  libncurses5-dev       \
  libpython-dev         \
  libsqlite3-dev        \
  libxml2-dev           \
  ninja-build           \
  pkg-config            \
  python                \
  python-six            \
  rsync                 \
  swig                  \
  systemtap-sdt-dev     \
  tzdata                \
  unzip                 \
  uuid-dev

USER build-user

WORKDIR /home/build-user