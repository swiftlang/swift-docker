#!/bin/bash
#
# ===----------------------------------------------------------------------===
#
#  Swift Android SDK: Install NDK
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

