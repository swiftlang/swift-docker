FROM debian:10

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update

RUN apt-get --no-install-recommends install -y     \
  build-essential       \
  clang                 \
  cmake                 \
  git                   \
  icu-devtools          \
  libcurl4-openssl-dev  \
  libedit-dev           \
  libicu-dev            \
  libncurses5-dev       \
  libsqlite3-dev        \
  libxml2-dev           \
  ninja-build           \
  python                \
  python-dev            \
  python-six            \
  pkg-config            \
  rsync                 \
  swig                  \
  systemtap-sdt-dev     \
  tzdata                \
  unzip                 \
  vim                   \
  uuid-dev

USER build-user

WORKDIR /home/build-user