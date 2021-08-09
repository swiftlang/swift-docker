#!/bin/bash
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2021 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
# See https://swift.org/CONTRIBUTORS.txt for Swift project authors

# This script is used to install Node.js in the Docker containers used 
# to build & qualify Swift toolchains on Linux.
#
# Node is specifically required to build swift-docc-render, the template used by swift-docc to
# render documentation archives.

set -e

NODE_VERSION='v14.17.4'

ARCH=`uname -m`
if [ ${ARCH} == 'x86_64' ]; then
  NODE_DISTRO='linux-x64'
elif [ ${ARCH} == 'aarch64' ]; then
  NODE_DISTRO='linux-arm64'
else
  echo >&2 "Unsupported CPU architecture. Unable to install required Node dependency."
  exit 1
fi

NODE_FILENAME=node-$NODE_VERSION-$NODE_DISTRO
NODE_COMPRESSED_FILENAME=$NODE_FILENAME.tar.gz
NODE_URL=https://nodejs.org/dist/$NODE_VERSION/$NODE_COMPRESSED_FILENAME

NODE_SHASUM_FILENAME=SHASUMS256.txt
NODE_SHASUM_URL=https://nodejs.org/dist/$NODE_VERSION/$NODE_SHASUM_FILENAME

if [ -x "$(command -v curl)" ]; then
  curl -o $NODE_COMPRESSED_FILENAME $NODE_URL
  curl -o $NODE_SHASUM_FILENAME $NODE_SHASUM_URL
elif [ -x "$(command -v python)" ]; then
  python -c "from urllib import urlretrieve; urlretrieve('$NODE_URL', '$NODE_COMPRESSED_FILENAME')"
  python -c "from urllib import urlretrieve; urlretrieve('$NODE_SHASUM_URL', '$NODE_SHASUM_FILENAME')"
else
  echo >&2 "No download command found; install curl or python."
  exit 1
fi

if [ -x "$(command -v shasum)" ]; then
  SHA_CMD="shasum"
elif [ -x "$(command -v sha256sum)" ]; then
  SHA_CMD="sha256sum"
else
  echo >&2 "No sha command found; install shasum or sha256sum."
  exit 1
fi

if grep $NODE_COMPRESSED_FILENAME $NODE_SHASUM_FILENAME | $SHA_CMD -c -; then
  echo "Node.js binary verified successfully."
else
  echo >&2 "Node.js binary could not be verified."
  exit 1
fi

mkdir -p /usr/local/lib/nodejs
tar -xf $NODE_COMPRESSED_FILENAME -C /usr/local/lib/nodejs
mv /usr/local/lib/nodejs/$NODE_FILENAME /usr/local/lib/nodejs/node
