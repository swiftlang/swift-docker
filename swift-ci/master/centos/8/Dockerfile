FROM centos:centos8

RUN groupadd -g 42 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

RUN yum -y update

RUN yum install --enablerepo=PowerTools -y \
    autoconf              \
    clang                 \
    cmake                 \
    git                   \
    libbsd-devel          \
    libcurl-devel         \
    libedit-devel         \
    libicu-devel          \
    libtool               \
    libuuid-devel         \
    libxml2-devel         \
    make                  \
    ncurses-devel         \
    ninja-build           \
    pcre-devel            \
    python2               \
    python2-devel         \
    python2-six           \
    python3               \
    python3-six           \
    python3-pexpect       \
    platform-python-devel \
    rpm-build.x86_64      \
    sqlite-devel          \
    swig                  \
    rsync                 \
    tar                   \
    which

RUN ln -s /usr/bin/python2 /usr/bin/python

RUN mkdir -p /home/build-user/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

RUN echo '%_topdir %(echo $HOME)/rpmbuild' > /home/build-user/.rpmmacros

USER build-user

WORKDIR /home/build-user
