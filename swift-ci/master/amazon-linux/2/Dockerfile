FROM swift:5.7-amazonlinux2

RUN yum install shadow-utils -y

RUN groupadd -g 998 build-user && \
    useradd -m -r -u 42 -g build-user build-user

# The build needs a package from the EPEL repo so that needs to be enabled.
# https://www.tecmint.com/install-epel-repository-on-centos/
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

# Update and install needed build packages
RUN yum -y group install "development tools"
RUN yum -y install \
  clang            \
  cmake            \
  curl-devel       \
  gcc-c++          \
  git              \
  glibc-static     \
  libbsd-devel     \
  libedit-devel    \
  libicu-devel     \
  libuuid-devel    \
  libxml2-devel    \
  ncurses-devel    \
  pexpect          \
  pkgconfig        \
  procps-ng        \
  python           \
  python-devel     \
  python-pkgconfig \
  python-six       \
  python3-devel    \
  python3-psutil   \
  rsync            \
  sqlite-devel     \
  swig             \
  tzdata           \
  uuid-devel       \
  wget             \
  which

RUN mkdir -p /usr/local/lib/python3.7/site-packages/

RUN easy_install-3.7 six

USER build-user

WORKDIR /home/build-user
