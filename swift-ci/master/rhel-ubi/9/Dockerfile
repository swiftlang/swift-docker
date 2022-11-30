FROM redhat/ubi9

RUN groupadd -g 42 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum install -y  \
  git               \
  gcc-c++           \
  clang             \
  cmake             \
  make              \
  libcurl-devel     \
  libedit-devel     \
  libuuid-devel     \
  libxml2-devel     \
  ncurses-devel     \
  python3-devel     \
  rsync             \
  sqlite-devel

USER build-user

WORKDIR /home/build-user
