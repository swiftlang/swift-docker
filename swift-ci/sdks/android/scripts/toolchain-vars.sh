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

OS=$(echo $HOST_OS | tr -d '.')

case "${BUILD_VERSION}" in
    release)
        # e.g., "swift-6.1-RELEASE"
        SWIFT_TAG=$(curl -fsSL https://www.swift.org/api/v1/install/releases.json | jq -r '.[-1].tag')
        # e.g., "swift-6.1-release"
        SWIFT_BRANCH=$(echo "${SWIFT_TAG}" | tr '[A-Z]' '[a-z]')
        ;;
    devel)
        # e.g., swift-6.2-DEVELOPMENT-SNAPSHOT-2025-05-15-a
        SWIFT_TAG=$(curl -fsSL https://download.swift.org/swift-6.2-branch/$OS/latest-build.yml | grep '^dir: ' | cut -f 2 -d ' ')
        SWIFT_BRANCH="swift-$(echo $SWIFT_TAG | cut -d- -f2)-branch"
        ;;
    trunk)
        # e.g., swift-DEVELOPMENT-SNAPSHOT-2025-05-14-a
        SWIFT_TAG=$(curl -fsSL https://download.swift.org/development/$OS/latest-build.yml | grep '^dir: ' | cut -f 2 -d ' ')
        SWIFT_BRANCH="development"
        ;;
    *)
        echo "$0: invalid BUILD_VERSION=${BUILD_VERSION}"
        exit 1
        ;;
esac

SWIFT_BASE=$SWIFT_TAG-$HOST_OS
export SWIFT_TOOLCHAIN_URL="https://download.swift.org/$SWIFT_BRANCH/$OS/$SWIFT_TAG/$SWIFT_BASE.tar.gz"

