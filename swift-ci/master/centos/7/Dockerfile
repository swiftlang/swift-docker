FROM swift:5.7-centos7

RUN yum install shadow-utils.x86_64 -y

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
    llvm-toolset-7.0    \
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
    unzip               \
    zip                 \
    zlib-devel

RUN echo -e ". /opt/rh/sclo-git25/enable\n. /opt/rh/llvm-toolset-7.0/enable\n. /opt/rh/devtoolset-8/enable\n" >> /home/build-user/.bashrc

RUN echo /opt/rh/llvm-toolset-7.0/root/usr/lib64/ > /etc/ld.so.conf.d/llvm-toolset.conf
RUN ldconfig

RUN sed -i -e 's/\*__block/\*__libc_block/g' /usr/include/unistd.h

USER build-user

WORKDIR /home/build-user

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
