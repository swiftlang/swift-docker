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
  glibc-static \
  python3 \
  python3-pip \
  python3-devel \
  python3-distro \
  python3-psutil \
  python3-setuptools \
  rsync \
  sqlite-devel \
  swig \
  tzdata \
  unzip \
  zip \
  lld \
  diffutils \
  wget \
  which

# Bug: https://github.com/amazonlinux/amazon-linux-2023/issues/243
RUN yum -y swap gnupg2-minimal gnupg2-full

ARG SWIFT_PLATFORM=amazonlinux2023
ARG SWIFT_VERSION=6.3.1
ARG SWIFT_BRANCH=swift-${SWIFT_VERSION}-release
ARG SWIFT_TAG=swift-${SWIFT_VERSION}-RELEASE
ARG SWIFT_WEBROOT=https://download.swift.org
ARG SWIFT_PREFIX=/opt/swift/${SWIFT_VERSION}

ENV SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_VERSION=$SWIFT_VERSION \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_TAG=$SWIFT_TAG \
    SWIFT_WEBROOT=$SWIFT_WEBROOT \
    SWIFT_PREFIX=$SWIFT_PREFIX

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt

RUN set -e; \
    ARCH_NAME="$(rpm --eval '%{_arch}')"; \
    case "${ARCH_NAME##*-}" in \
        'x86_64') \
            OS_ARCH_SUFFIX=''; \
            ;; \
        'aarch64') \
            OS_ARCH_SUFFIX='-aarch64'; \
            ;; \
        *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac; \
    SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)$OS_ARCH_SUFFIX" \
    && SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_TAG/$SWIFT_TAG-$SWIFT_PLATFORM$OS_ARCH_SUFFIX.tar.gz" \
    && SWIFT_SIG_URL="$SWIFT_BIN_URL.sig" \
    && echo $SWIFT_BIN_URL \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz "$SWIFT_SIG_URL" -o swift.tar.gz.sig \
    && curl -fSsL --compressed https://swift.org/keys/all-keys.asc | gpg --batch --no-tty --import - \
    && gpg --batch --verify swift.tar.gz.sig swift.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && mkdir -p $SWIFT_PREFIX \
    && tar -xzf swift.tar.gz --directory $SWIFT_PREFIX --strip-components=1 \
    && chmod -R o+r $SWIFT_PREFIX/usr/lib/swift \
    && rm -rf "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz

ENV PATH="${SWIFT_PREFIX}/usr/bin:${PATH}"

RUN echo PATH="${SWIFT_PREFIX}/usr/bin:${PATH}" >> /etc/profile

USER build-user

WORKDIR /home/build-user
