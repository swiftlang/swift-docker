FROM swift:5.7-focal

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get -y update && apt-get -y install \
  build-essential       \
  clang                 \
  cmake                 \
  git                   \
  icu-devtools          \
  libcurl4-openssl-dev  \
  libedit-dev           \
  libicu-dev            \
  libncurses5-dev       \
  libpython3-dev        \
  libsqlite3-dev        \
  libxml2-dev           \
  ninja-build           \
  pkg-config            \
  python                \
  python-six            \
  python2-dev           \
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
