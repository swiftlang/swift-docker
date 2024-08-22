FROM fedora:31

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
    python3-devel               \
    python3-distro              \
    python3-six                 \
    rsync                       \
    swig 

USER build-user

WORKDIR /home/build-user

