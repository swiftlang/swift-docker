#!/bin/bash -e
#
# ===----------------------------------------------------------------------===
#
#  Swift Android SDK: Toolchain source variables
#
# ===----------------------------------------------------------------------===

# This script is meant to be sourced from another script that sets the
# BUILD_SCHEME environment variable to one of "release", "swift-VERSION-branch", or "development"
# and will set check the latest builds for each build type in order
# to provide information about the Swift tag name in use and where to
# obtain the latest toolchain for building.

OS=$(echo $HOST_OS | tr -d '.')

case "${BUILD_SCHEME}" in
    release)
        # e.g., "swift-6.1-RELEASE"
        # there is no latest-build.yml for releases, so we need to get it from the API
        export SWIFT_TAG=$(curl -fsSL https://www.swift.org/api/v1/install/releases.json | jq -r '.[-1].tag')
        # e.g., "swift-6.1-release"
        export SWIFT_BRANCH=$(echo "${SWIFT_TAG}" | tr '[A-Z]' '[a-z]')
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
export SWIFT_TOOLCHAIN_URL="https://download.swift.org/$SWIFT_BRANCH/$OS/$SWIFT_TAG/$SWIFT_BASE.tar.gz"

