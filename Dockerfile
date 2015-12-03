
FROM phusion/baseimage:0.9.17
MAINTAINER Haris Amin <aminharis7@gmail.com>

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && apt-get upgrade -y && apt-get install -y curl wget git make

# Ubuntu Swift Requirements: https://github.com/apple/swift#system-requirements
RUN sudo apt-get install -y git cmake ninja-build clang uuid-dev libicu-dev icu-devtools libbsd-dev libedit-dev libxml2-dev libsqlite3-dev swig libpython-dev libncurses5-dev pkg-config
RUN sudo apt-get install -y clang-3.6
RUN sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100
RUN sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100

# Download Swift Ubuntu 14.04 Snapshot
RUN wget https://swift.org/builds/ubuntu1404/swift-2.2-SNAPSHOT-2015-12-01-b/swift-2.2-SNAPSHOT-2015-12-01-b-ubuntu14.04.tar.gz

RUN tar -xvzf swift-2.2-SNAPSHOT-2015-12-01-b-ubuntu14.04.tar.gz && cd swift-2.2-SNAPSHOT-2015-12-01-b-ubuntu14.04

# Move extracted Swift Snapshot
RUN rsync -a -v --ignore-existing swift-2.2-SNAPSHOT-2015-12-01-b-ubuntu14.04/usr/ /usr

# Clean up
RUN cd / && rm -rf swift-2.2-SNAPSHOT-2015-12-01-b-ubuntu14.04*

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set Swfit Path
ENV PATH /usr/bin:$PATH

# Print Installed Swift Version
RUN swift --version