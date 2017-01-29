FROM ubuntu:16.04
MAINTAINER Haris Amin <aminharis7@gmail.com>

# Install related packages and set LLVM 3.6 as the compiler
RUN apt-get -q update && \
    apt-get -q install -y \
    make \
    libc6-dev \
    clang-3.6 \
    curl \
    libedit-dev \
    python2.7 \
    python2.7-dev \
    libicu-dev \
    rsync \
    libxml2 \
    git \
    libcurl4-openssl-dev \
    && update-alternatives --quiet --install /usr/bin/clang clang /usr/bin/clang-3.6 100 \
    && update-alternatives --quiet --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100 \
    && rm -r /var/lib/apt/lists/*

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little
ENV SWIFT_VERSION=swift-3.1-DEVELOPMENT-SNAPSHOT-2017-01-29-a \
    SWIFT_PLATFORM=ubuntu16.04 \
    PATH=/usr/bin:$PATH

# Download GPG keys, signature and Swift package, then unpack and cleanup
RUN SWIFT_URL=https://ci.swift.org/job/oss-swift-3.1-package-linux-ubuntu-16_04/ws/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz \
    && curl -fSsL $SWIFT_URL -o swift.tar.gz \
    && tar -xzf swift.tar.gz --directory / --strip-components=1 \
    && rm swift.tar.gz

# Print Installed Swift Version
RUN swift --version
CMD echo "Unverified Swift toolchain. Use at your own risk."
