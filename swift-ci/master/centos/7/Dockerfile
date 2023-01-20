FROM swift:centos7

RUN groupadd -g 1000 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum install -y epel-release centos-release-scl

RUN yum install --enablerepo=centosplus  -y \
    autoconf            \
    cmake               \
    devtoolset-8        \
    glibc-static        \
    libatomic           \
    libcurl-devel       \
    libedit-devel       \
    libstdc++-static    \
    libtool             \
    libuuid-devel       \
    libxml2-devel       \
    make                \
    ncurses-devel       \
    ninja-build         \
    openssl-devel       \
    pexpect             \
    python-devel        \
    python3-devel       \
    python-pygments     \
    python-six          \
    python36-pexpect    \
    python36-six        \
    PyYAML              \
    rsync               \
    sclo-git25-git      \
    sqlite-devel        \
    swig3               \
    which               \
    zlib-devel

RUN echo -e ". /opt/rh/sclo-git25/enable\n. /opt/rh/devtoolset-8/enable\n" >> /home/build-user/.bashrc

# Workarounds
RUN \
    sed -i -e 's/\*__block/\*__libc_block/g' /usr/include/unistd.h && \
    ln -s /opt/rh/devtoolset-8/root/usr/lib/gcc/x86_64-redhat-linux/8 /usr/lib/gcc/x86_64-redhat-linux/8 && \
    ln -s /opt/rh/devtoolset-8/root/usr/include/c++/8 /usr/include/c++/8

USER build-user

WORKDIR /home/build-user

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
