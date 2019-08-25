FROM ubuntu:16.04
LABEL maintainer="Swift Infrastructure <swift-infrastructure@swift.org>"
LABEL Description="Docker Container for the Swift programming language"

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && apt-get -q update && \
    apt-get -q install -y \
    libatomic1 \
    libcurl3 \
    libxml2 \
    tzdata \
    curl \
    && rm -r /var/lib/apt/lists/*

# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little

# pub   rsa4096 2017-11-07 [SC] [expires: 2019-11-07]
#       8513 444E 2DA3 6B7C 1659  AF4D 7638 F1FB 2B2B 08C4
# uid           [ unknown] Swift Automatic Signing Key #2 <swift-infrastructure@swift.org>
ARG SWIFT_SIGNING_KEY=8513444E2DA36B7C1659AF4D7638F1FB2B2B08C4
ARG SWIFT_PLATFORM=ubuntu16.04
ARG SWIFT_BRANCH=swift-5.1-branch
ARG SWIFT_VERSION=swift-5.1-DEVELOPMENT-SNAPSHOT-2019-08-24-a
ARG SWIFT_WEBROOT=https://swift.org/builds/

ENV SWIFT_SIGNING_KEY=$SWIFT_SIGNING_KEY \
    SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_VERSION=$SWIFT_VERSION \
    SWIFT_WEBROOT=$SWIFT_WEBROOT

RUN set -e; \
    SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)/" \
    && SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz" \
    && SWIFT_SIG_URL="$SWIFT_BIN_URL.sig" \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz "$SWIFT_SIG_URL" -o swift.tar.gz.sig \
    && gpg --batch --quiet --keyserver ha.pool.sks-keyservers.net --recv-keys "$SWIFT_SIGNING_KEY" \
    && gpg --batch --verify swift.tar.gz.sig swift.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && tar -xzf swift.tar.gz --directory / --strip-components=1 \
    && chmod -R o+r /usr/lib/swift \
    && rm -rf "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz \
    && apt-get purge --auto-remove -y curl
