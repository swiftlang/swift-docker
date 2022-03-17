FROM oraclelinux:8

RUN groupadd -g 42 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum install -y oracle-epel-release-el8

RUN yum install --enablerepo=ol8_codeready_builder -y \
    autoconf              \
    clang-12.0.1          \
    cmake                 \
    diffutils             \
    git                   \
    glibc-static          \
    libbsd-devel          \
    libcurl-devel         \
    libedit-devel         \
    libicu-devel          \
    libstdc++-static      \
    libtool               \
    libuuid-devel         \
    libxml2-devel         \
    make                  \
    ncurses-devel         \
    ninja-build           \
    pcre-devel            \
    procps-ng             \
    python2               \
    python2-devel         \
    python2-six           \
    python3               \
    python3-six           \
    python3-pexpect       \
    platform-python-devel \
    sqlite-devel          \
    swig                  \
    rsync                 \
    tar                   \
    which

RUN ln -s /usr/bin/python2 /usr/bin/python

USER build-user

WORKDIR /home/build-user
