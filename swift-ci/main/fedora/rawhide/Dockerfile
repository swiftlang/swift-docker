FROM fedora:rawhide

RUN groupadd -g 42 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN dnf -y update && dnf install -y \
    clang                       \
    cmake                       \
    git                         \
    libblocksruntime-static     \
    libbsd-devel                \
    libcurl-devel               \
    libedit-devel               \
    libicu-devel                \
    libsqlite3x-devel           \
    libuuid-devel               \
    libxml2-devel               \
    make                        \
    ninja-build                 \
    python-unversioned-command  \
    python27                    \
    python3                     \
    python3-pip                 \
    python3-devel               \
    python3-distro              \
    python3-six                 \
    rsync                       \
    swig 

COPY swift-ci/dependencies/requirements.txt /dependencies/
RUN pip3 install -r /dependencies/requirements.txt

USER build-user

WORKDIR /home/build-user

