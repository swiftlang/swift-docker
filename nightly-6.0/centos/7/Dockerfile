FROM centos:7
LABEL maintainer="Swift Infrastructure <swift-infrastructure@forums.swift.org>"
LABEL description="Docker Container for the Swift programming language"

# CentOS 7 ships with git 1.x which is too old for the toolchain usage, using RH software collections to install git 2.x
RUN yum install -y centos-release-scl-rh

RUN yum install shadow-utils.x86_64 -y \
  binutils \
  gcc \
  rh-git227-git \
  glibc-static \
  libbsd-devel \
  libcurl-devel \
  libedit \
  libedit-devel \
  libicu-devel \
  libstdc++-static \
  libxml2-devel \
  pkg-config \
  python2 \
  python3 \
  sqlite \
  unzip \
  zip \
  zlib-devel

# Enable git 2.x from RH software collections for both login and non-login shells
RUN ln -s /opt/rh/rh-git227/enable /etc/profile.d/git.sh
ENV ENV=/etc/profile.d/git.sh
ENV BASH_ENV=$ENV

RUN sed -i -e 's/\*__block/\*__libc_block/g' /usr/include/unistd.h

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little

# gpg --keyid-format LONG -k F167DF1ACF9CE069
# pub   rsa4096/F167DF1ACF9CE069 2021-11-08 [SC] [expires: 2025-11-09]
#       E813C892820A6FA13755B268F167DF1ACF9CE069
# uid                 [ unknown] Swift Automatic Signing Key #4 <swift-infrastructure@forums.swift.org>
ARG SWIFT_SIGNING_KEY=E813C892820A6FA13755B268F167DF1ACF9CE069
ARG SWIFT_PLATFORM=centos
ARG OS_MAJOR_VER=7
ARG SWIFT_WEBROOT=https://download.swift.org/swift-6.0-branch

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    OS_MAJOR_VER=$OS_MAJOR_VER \
    OS_VER=$SWIFT_PLATFORM$OS_MAJOR_VER \
    SWIFT_WEBROOT="$SWIFT_WEBROOT/$SWIFT_PLATFORM$OS_MAJOR_VER"

RUN echo "${SWIFT_WEBROOT}/latest-build.yml"

RUN set -e; \
    # - Latest Toolchain info
    export $(curl -s ${SWIFT_WEBROOT}/latest-build.yml | grep 'download:' | sed 's/:[^:\/\/]/=/g')  \
    && export $(curl -s ${SWIFT_WEBROOT}/latest-build.yml | grep 'download_signature:' | sed 's/:[^:\/\/]/=/g')  \
    && export DOWNLOAD_DIR=$(echo $download | sed "s/-${OS_VER}.tar.gz//g") \
    && echo $DOWNLOAD_DIR > .swift_tag \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fL ${SWIFT_WEBROOT}/${DOWNLOAD_DIR}/${download} -o latest_toolchain.tar.gz \
    ${SWIFT_WEBROOT}/${DOWNLOAD_DIR}/${download_signature} -o latest_toolchain.tar.gz.sig \
    && curl -fL https://swift.org/keys/all-keys.asc | gpg --import -  \
    && gpg --batch --verify latest_toolchain.tar.gz.sig latest_toolchain.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && tar -xzf latest_toolchain.tar.gz --directory / --strip-components=1 \
    && chmod -R o+r /usr/lib/swift \
    && rm -rf "$GNUPGHOME" latest_toolchain.tar.gz.sig latest_toolchain.tar.gz

# The devtoolset-8 that the Swift runtime is built against uses new
# functionality in the backdeploy `libstdc++_noshared.a` in devtoolset-a.
# A linkerscript in the devtoolset ensures that it is picked up appropriately.
# When dynamically linking the runtime, this static archive is merged into the
# shared object. When static linking, the compat library needs to be available
# to be merged into the final shared object/executable.
#
# Symlink it from the devtoolset into the static swift resource directory
RUN yum install -y centos-release-scl
RUN yum install -y devtoolset-8
RUN ln -s /opt/rh/devtoolset-8/root/usr/lib/gcc/x86_64-redhat-linux/8/libstdc++_nonshared.a /usr/lib/swift_static/linux && \
    ln -s /opt/rh/devtoolset-8/root/usr/lib/gcc/x86_64-redhat-linux/8/libstdc++.so /usr/lib/swift_static/linux

# Print Installed Swift Version
RUN swift --version

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' \
    >> /etc/bashrc; \
    echo -e " ################################################################\n" \
    "#\t\t\t\t\t\t\t\t#\n" \
    "# Swift Nightly Docker Image\t\t\t\t\t#\n" \
    "# Tag: $(cat .swift_tag)\t\t\t#\n" \
    "#\t\t\t\t\t\t\t\t#\n"  \
    "################################################################\n" > /etc/motd
