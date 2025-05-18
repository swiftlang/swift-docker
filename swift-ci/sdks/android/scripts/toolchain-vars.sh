#!/bin/bash -e
#
# ===----------------------------------------------------------------------===
#
#  Swift Android SDK: Toolchain source variables
#
# ===----------------------------------------------------------------------===

# This script is meant to be sourced from another script that sets the
# BUILD_VERSION environment variable to one of "release", "devel", or "trunk"
# and will set check the latest builds for each build type in order
# to provide information about the Swift tag name in use and where to
# obtain the latest toolchain for building.

# TODO: we could instead use the latest-build.yml files for this, like:
# https://download.swift.org/swift-6.2-branch/ubuntu2404/latest-build.yml
# https://download.swift.org/development/ubuntu2404/latest-build.yml
# but there doesn't seem to be one for the current release build.

case "${BUILD_VERSION}" in
    release)
        LATEST_TOOLCHAIN_VERSION=$(curl -sL https://github.com/swiftlang/swift/releases | grep -m1 swift-6.1 | cut -d- -f2)
        SWIFT_TAG="swift-${LATEST_TOOLCHAIN_VERSION}-RELEASE"
        SWIFT_BRANCH="swift-$(echo $SWIFT_TAG | cut -d- -f2)-release"
        ;;
    devel)
        LATEST_TOOLCHAIN_VERSION=$(curl -sL https://github.com/swiftlang/swift/tags | grep -m1 swift-6.2-DEV | cut -d- -f8-10)
        SWIFT_TAG="swift-6.2-DEVELOPMENT-SNAPSHOT-${LATEST_TOOLCHAIN_VERSION}-a"
        SWIFT_BRANCH="swift-$(echo $SWIFT_TAG | cut -d- -f2)-branch"
        ;;
    trunk)
        LATEST_TOOLCHAIN_VERSION=$(curl -sL https://github.com/swiftlang/swift/tags | grep -m1 swift-DEV | cut -d- -f7-9)
        SWIFT_TAG="swift-DEVELOPMENT-SNAPSHOT-${LATEST_TOOLCHAIN_VERSION}-a"
        SWIFT_BRANCH="development"
        ;;
    *)
        echo "$0: invalid BUILD_VERSION=${BUILD_VERSION}"
        exit 1
        ;;
esac

SWIFT_BASE=$SWIFT_TAG-$HOST_OS
export SWIFT_TOOLCHAIN_URL="https://download.swift.org/$SWIFT_BRANCH/$(echo $HOST_OS | tr -d '.')/$SWIFT_TAG/$SWIFT_BASE.tar.gz"

