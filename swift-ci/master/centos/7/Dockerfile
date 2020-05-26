FROM centos:7

RUN groupadd -g 42 build-user && \
    useradd -m -r -u 42 -g build-user build-user

RUN yum install -y epel-release centos-release-scl

RUN yum install --enablerepo=centosplus  -y \
	autoconf          \
	cmake3            \
	devtoolset-8      \
	gettext           \
	libatomic         \
	libcurl-devel     \
	libedit-devel     \
	libstdc++-devel   \
	libtool           \
	libuuid-devel     \
	libxml2-devel     \
	llvm-toolset-7    \
	make              \
	ncurses-devel     \
	ninja-build       \
	pexpect           \
	python-devel      \
	python-pygments   \
	python36-pexpect  \
	PyYAML            \
	rsync             \
	sclo-git25-git    \
	sqlite-devel      \
	swig3             \
	which             \
	zlib-devel

RUN ln -sf /usr/bin/ninja-build /usr/bin/ninja && \
  ln -sf /usr/bin/cmake3 /usr/bin/cmake && \
  ln -sf /usr/lib64/libstdc++.so.6.0.?? /usr/lib64/libstdc++.so && \
  ln -sf /usr/lib64/libatomic.so.1.?.? /usr/lib64/libatomic.so && \
  echo "/* GNU ld script" > /usr/lib64/libgcc_s.so && \
  echo "Use the shared library, but some functions are only in" >> /usr/lib64/libgcc_s.so && \
  echo "the static library.  */" >> /usr/lib64/libgcc_s.so && \
  echo "GROUP ( libgcc_s.so.1 -lgcc )" >> /usr/lib64/libgcc_s.so && \
  sed -i -e 's/\*__block/\*__libc_block/g' /usr/include/unistd.h && \
  echo -e ". /opt/rh/sclo-git25/enable\n. /opt/rh/llvm-toolset-7/enable\n. /opt/rh/devtoolset-8/enable\n" >> /home/build-user/.bashrc && \
  chown -R build-user:build-user /home/build-user

USER build-user

WORKDIR /home/build-user
