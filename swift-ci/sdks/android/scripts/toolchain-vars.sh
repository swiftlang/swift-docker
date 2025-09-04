#!/bin/bash -e
#
# ===----------------------------------------------------------------------===
#
#  Swift Android SDK: Toolchain source variables
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

# This script is meant to be sourced from another script that sets the
# BUILD_SCHEME environment variable to one of "release", "swift-VERSION-branch", or "development"
# and will set check the latest builds for each build type in order
# to provide information about the Swift tag name in use and where to
# obtain the latest toolchain for building.

OS=$(echo $HOST_OS | tr -d '.')
# e.g., "swift-6.1-RELEASE"
# there is no latest-build.yml for releases, so we need to get it from the API
RELEASE_TAG=$(curl -fsSL https://www.swift.org/api/v1/install/releases.json | jq -r '.[-1].tag')
# e.g., "swift-6.1-release"
RELEASE_BRANCH=$(echo "${RELEASE_TAG}" | tr '[A-Z]' '[a-z]')

case "${BUILD_SCHEME}" in
    release)
        export SWIFT_TAG=$RELEASE_TAG
        export SWIFT_BRANCH=$RELEASE_BRANCH
        ;;
    development|swift-*-branch)
        # e.g., swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-15-a
        # e.g., swift-DEVELOPMENT-SNAPSHOT-2025-05-14-a
        export SWIFT_TAG=$(curl -fsSL https://download.swift.org/$BUILD_SCHEME/$OS/latest-build.yml | grep '^dir: ' | cut -f 2 -d ' ')
        export SWIFT_BRANCH=$BUILD_SCHEME
        ;;
    *)
        echo "$0: invalid BUILD_SCHEME=${BUILD_SCHEME}"
        exit 1
        ;;
esac

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
