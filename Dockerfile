FROM phusion/baseimage:0.9.17
MAINTAINER Haris Amin <aminharis7@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV SWIFT_VERSION 2.2-SNAPSHOT-2015-12-01-b
ENV SWIFT_PLATFORM ubuntu14.04

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y build-essential wget clang libedit-dev python2.7 python2.7-dev libicu52 rsync && \
    rm -rf /var/lib/apt/lists/*

RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -
RUN gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Download Swift Ubuntu 14.04 Snapshot, signature and verify
RUN wget https://swift.org/builds/ubuntu1404/swift-$SWIFT_VERSION/swift-$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz
RUN wget https://swift.org/builds/ubuntu1404/swift-$SWIFT_VERSION/swift-$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz.sig
RUN gpg --verify swift-$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz.sig

RUN tar -xvzf swift-$SWIFT_VERSION/swift-$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz && cd swift-$SWIFT_VERSION/swift-$SWIFT_VERSION-$SWIFT_PLATFORM

# Move extracted Swift Snapshot
RUN rsync -a -v --ignore-existing swift-$SWIFT_VERSION/swift-$SWIFT_VERSION-$SWIFT_PLATFORM/usr/ /usr

# Clean up
RUN cd / && rm -rf swift-$SWIFT_VERSION/swift-$SWIFT_VERSION-$SWIFT_PLATFORM*

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set Swift Path
ENV PATH /usr/bin:$PATH

# Print Installed Swift Version
RUN swift --version
