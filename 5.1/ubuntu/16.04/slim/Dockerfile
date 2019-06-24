FROM ubuntu:16.04
LABEL maintainer="Swift Infrastructure <swift-infrastructure@swift.org>"
LABEL Description="Docker Container for the Swift programming language"

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get -q install -y \
    libatomic1 \
    libcurl3 \
    libxml2 \
    tzdata \
    && rm -r /var/lib/apt/lists/*

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little
ARG SWIFT_PLATFORM=ubuntu16.04
ARG SWIFT_BRANCH=swift-5.1-branch
ARG SWIFT_VERSION=swift-5.1-DEVELOPMENT-SNAPSHOT-2019-06-21-a

ENV SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_VERSION=$SWIFT_VERSION

# Download GPG keys, signature and Swift package, then unpack, cleanup and execute permissions for foundation libs
RUN SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz \
    && apt-get update \
    && apt-get install -y curl \
    && curl -fSsL $SWIFT_URL -o swift.tar.gz \
#    && curl -fSsL $SWIFT_URL.sig -o swift.tar.gz.sig \
#    && export GNUPGHOME="$(mktemp -d)" \
#    && set -e; \
#        for key in \
#      # pub   4096R/ED3D1561 2019-03-22 [expires: 2021-03-21]
#      #       Key fingerprint = A62A E125 BBBF BB96 A6E0  42EC 925C C1CC ED3D 1561
#      # uid                  Swift 5.x Release Signing Key <swift-infrastructure@swift.org>
#          A62AE125BBBFBB96A6E042EC925CC1CCED3D1561 \
#        ; do \
#          gpg --quiet --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
#        done \
#    && gpg --batch --verify --quiet swift.tar.gz.sig swift.tar.gz \
    && tar -xzf swift.tar.gz --directory / --strip-components=1 $SWIFT_VERSION-$SWIFT_PLATFORM/usr/lib/swift/linux \
    && apt-get purge -y curl \
    && apt-get -y autoremove \
    && rm -r /var/lib/apt/lists/* \
#    && rm -r "$GNUPGHOME" swift.tar.gz.sig \
    && rm swift.tar.gz \
    && chmod -R o+r /usr/lib/swift
