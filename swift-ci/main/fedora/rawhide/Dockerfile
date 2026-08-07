FROM fedora:rawhide

ARG BUILD_USER_ID=42
ARG BUILD_GROUP_ID=42

RUN groupadd -g ${BUILD_GROUP_ID} build-user && \
    useradd -m -r -u ${BUILD_USER_ID} -g build-user build-user

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

