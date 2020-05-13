FROM centos:7

RUN groupadd -g 42 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum install -y epel-release centos-release-scl

RUN yum install --enablerepo=centosplus  -y \
	autoconf          \
	cmake3            \
	devtoolset-8      \
	gettext           \
	gnutls-devel      \
	krb5-devel        \
	libatomic         \
	libedit-devel     \
	libidn2-devel     \
	libmetalink-devel \
	libnghttp2-devel  \
	libssh2-devel     \
	libstdc++-devel   \
	libtool           \
	libuuid-devel     \
	libxml2-devel     \
	llvm-toolset-7    \
	make              \
	ncurses-devel     \
	ninja-build       \
	openldap-devel    \
	openssl-devel     \
	pexpect           \
	python-devel      \
	python-pygments   \
	python36-pexpect  \
	PyYAML            \
	rpm-build.x86_64  \
	rsync             \
	sclo-git25-git    \
	sqlite-devel      \
	swig3             \
	which             \
	zlib-devel

RUN ln -sf /usr/bin/ninja-build /usr/bin/ninja && ln -sf /usr/bin/cmake3 /usr/bin/cmake

RUN mkdir -p /home/build-user/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

RUN echo '%_topdir %(echo $HOME)/rpmbuild' > /home/build-user/.rpmmacros

RUN echo -e ". /opt/rh/sclo-git25/enable\n. /opt/rh/llvm-toolset-7/enable\n. /opt/rh/devtoolset-8/enable\n" >> /home/build-user/.bashrc

USER build-user

WORKDIR /home/build-user
