#!/bin/bash -e
#
# ===----------------------------------------------------------------------===
#
#  Swift Android SDK: Toolchain source variables
#
#  This source file is part of the Swift.org open source project
#
#  Copyright (c) 2025 Apple Inc. and the Swift project authors
#  Licensed under Apache License v2.0 with Runtime Library Exception
#
#  See https://swift.org/LICENSE.txt for license information
#  See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
#
# ===----------------------------------------------------------------------===

# This script is meant to be sourced from another script that sets the
# SWIFT_VERSION environment variable to one of "scheme:release/6.2" or
# "tag:swift-6.2-RELEASE" and will get the latest builds for each build
# type.

OS=$(echo $HOST_OS | tr -d '.')
# e.g., "swift-6.1-RELEASE"
# there is no latest-build.yml for releases, so we need to get it from the API
RELEASE_TAG=$(curl -fsSL https://www.swift.org/api/v1/install/releases.json | jq -r '.[-1].tag')
# e.g., "swift-6.1-release"
RELEASE_BRANCH=$(echo "${RELEASE_TAG}" | tr '[A-Z]' '[a-z]')

if [[ $SWIFT_VERSION == tag:* ]]; then
    SWIFT_TAG=${SWIFT_VERSION#tag:}
    case "${SWIFT_TAG}" in
        swift-*-RELEASE)
            SWIFT_BRANCH=$(echo "${SWIFT_TAG}" | tr '[A-Z]' '[a-z]')
            ;;
        swift-6.*-DEVELOPMENT-SNAPSHOT-*)
            # e.g., swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-15-a
            SWIFT_BRANCH=${SWIFT_TAG//DEVEL*/branch}
            ;;
        swift-DEVELOPMENT-SNAPSHOT-*)
            # e.g., swift-DEVELOPMENT-SNAPSHOT-2025-05-14-a
            SWIFT_BRANCH=development
            ;;
    *)
        echo "$0: invalid tag=${SWIFT_TAG}"
        exit 1
        ;;
    esac
elif [[ $SWIFT_VERSION == scheme:* ]]; then
    echo "Building $SWIFT_VERSION with prebuilt Swift $RELEASE_TAG compiler"
    BUILD_COMPILER=yes
    echo "Branch scheme builds always build the Swift compiler from source and take much longer."
else
    echo "Invalid Swift version=${SWIFT_VERSION}"
    exit 1
fi

SWIFT_BASE=$SWIFT_TAG-$HOST_OS

case $(arch) in
    arm64|aarch64)
        export OS_ARCH_SUFFIX=-aarch64
        ;;
    amd64|x86_64)
        export OS_ARCH_SUFFIX=
        ;;
    *)
        echo "Unknown architecture $(arch)"
        exit 1
        ;;
esac


case $BUILD_COMPILER in
    1|true|yes|YES)
        export SWIFT_TOOLCHAIN_URL="https://download.swift.org/$RELEASE_BRANCH/$OS$OS_ARCH_SUFFIX/$RELEASE_TAG/$RELEASE_TAG-$HOST_OS$OS_ARCH_SUFFIX.tar.gz"
        ;;
    *)
        export SWIFT_TOOLCHAIN_URL="https://download.swift.org/$SWIFT_BRANCH/$OS$OS_ARCH_SUFFIX/$SWIFT_TAG/$SWIFT_BASE$OS_ARCH_SUFFIX.tar.gz"
        ;;
esac
