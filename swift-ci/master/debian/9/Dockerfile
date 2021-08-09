FROM debian:9

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 998 -g build-user build-user

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update

RUN apt-get --no-install-recommends -y install \
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
  pkg-config            \
  python                \
  python-six            \
  rsync                 \
  swig                  \
  systemtap-sdt-dev     \
  tzdata                \
  unzip                 \
  ca-certificates	\
  uuid-dev

# Install the current version of Node.js that swift-docc-render depends on:
COPY install_node.sh /
RUN /install_node.sh
RUN echo "export PATH=$PATH:/usr/local/lib/nodejs/node/bin" >> /home/build-user/.bashrc

USER build-user

WORKDIR /home/build-user