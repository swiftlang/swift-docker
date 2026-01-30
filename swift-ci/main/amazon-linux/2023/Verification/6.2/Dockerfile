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
  python-pip \
  rsync \
  sqlite-devel \
  swig \
  tzdata \
  unzip \
  zip \
  lld \
  diffutils

RUN mkdir -p /usr/local/lib/python3.7/site-packages/

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt
RUN pip3 install six

ARG SWIFT_PLATFORM=amazon-linux2023
ARG SWIFT_VERSION=6.2
ARG SWIFT_WEBROOT=https://download.swift.org
ARG SWIFT_PREFIX=/opt/swift/${SWIFT_VERSION}

ENV SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_VERSION=$SWIFT_VERSION \
    SWIFT_WEBROOT=$SWIFT_WEBROOT \
    SWIFT_PREFIX=$SWIFT_PREFIX

RUN set -e; \
    ARCH_NAME="$(rpm --eval '%{_arch}')"; \
    url=; \
    case "${ARCH_NAME##*-}" in \
        'x86_64') \
            OS_ARCH_SUFFIX=''; \
            ;; \
        'aarch64') \
            OS_ARCH_SUFFIX='-aarch64'; \
            ;; \
        *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac; \
    SWIFT_BIN_URL="$SWIFT_WEBROOT/tmp-ci-nightly/development/swift-6.2-bootstrap/amazonlinux2023$OS_ARCH_SUFFIX/latest.tar.gz" \
    && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz \
    && mkdir -p $SWIFT_PREFIX \
    && tar -xzf swift.tar.gz --directory $SWIFT_PREFIX \
    && ls -la $SWIFT_PREFIX/usr/lib/ \
    && chmod -R o+r $SWIFT_PREFIX/usr/lib/swift \
    && rm -rf "$GNUPGHOME" swift.tar.gz

ENV PATH="${SWIFT_PREFIX}/usr/bin:${PATH}"

USER build-user
WORKDIR /home/build-user
