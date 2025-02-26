FROM redhat/ubi8

RUN groupadd -g 42 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum install -y  \
  git               \
  gcc-c++           \
  clang             \
  cmake             \
  glibc-static      \
  make              \
  libcurl-devel     \
  libedit-devel     \
  libuuid-devel     \
  libstdc++-devel   \
  libstdc++-static  \
  libxml2-devel     \
  ncurses-devel     \
  python3-devel     \
  python3-pip       \
  rsync             \
  sqlite-devel      \
  unzip             \
  zip

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt

USER build-user

WORKDIR /home/build-user
