FROM redhat/ubi8

ARG BUILD_USER_ID=42
ARG BUILD_GROUP_ID=42

RUN groupadd -g ${BUILD_GROUP_ID} build-user && \
    useradd -m -r -u ${BUILD_USER_ID} -g build-user build-user

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
  python3-pip       \
  rsync             \
  sqlite-devel      \
  unzip             \
  zip

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt

USER build-user

WORKDIR /home/build-user
