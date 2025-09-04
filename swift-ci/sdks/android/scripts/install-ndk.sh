#!/bin/bash
#
# ===----------------------------------------------------------------------===
#
#  Swift Android SDK: Install NDK
#
#  This source file is part of the Swift.org open source project
#
#  Copyright (c) 2024 Apple Inc. and the Swift project authors
#  Licensed under Apache License v2.0 with Runtime Library Exception
#
#  See https://swift.org/LICENSE.txt for license information
#  See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#
# ===----------------------------------------------------------------------===

set -e

echo "Installing Android NDK"

mkdir -p /usr/local/ndk
pushd /usr/local/ndk >/dev/null

if [[ "${ANDROID_NDK_VERSION}" == "" ]]; then
    echo "$0: Missing ANDROID_NDK_VERSION environment"
    exit 1
fi


NDKFILE=${ANDROID_NDK_VERSION}-linux.zip

NDKURL="https://dl.google.com/android/repository/${NDKFILE}"
echo "Going to fetch ${NDKURL}"

curl -fsSL "${NDKURL}" -o ${NDKFILE}

echo "Extracting NDK"
unzip -q ${NDKFILE}

rm ${NDKFILE}

popd >/dev/null

