#!/bin/bash
# ===----------------------------------------------------------------------===
#
#  Swift Android SDK: Fetch Sources
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

# Docker sets TERM to xterm if using a pty; we probably want
# xterm-256color, otherwise we only get eight colors
if [ -t 1 ]; then
    if [[ "$TERM" == "xterm" ]]; then
        export TERM=xterm-256color
    fi
fi

if [[ -n "$TERM" ]]; then
  bold=""
  white=""
  grey=""
  reset=""
else
  bold=$(tput bold)
  white=$(tput setaf 15)
  grey=$(tput setaf 8)
  reset=$(tput sgr0)
fi

function cleanup {
    echo "${reset}"
}
trap cleanup EXIT

function header {
    local text="$1"
    echo ""
    echo "${white}${bold}*** ${text} ***${reset}${grey}"
    echo ""
}

function groupstart {
    local text="$1"
    if [[ ! -z "$CI" ]]; then
        echo "::group::${text}"
    fi
    header $text
}

function groupend {
    if [[ ! -z "$CI" ]]; then
        echo "::endgroup::"
    fi
}

function usage {
    cat <<EOF
usage: fetch-source.sh [--swift-scheme <scheme>|--swift-tag <tag>
                                               |--swift-version <version>]
                       [--boringssl-version <version>]
                       [--clone-with-ssh]
                       [--source-dir <path>]

Fetch all the sources required to build the fully statically linked Linux
SDK for Swift.  Options are:

  --clone-with-ssh    Use git-over-SSH rather than HTTPS where possible.
  --source-dir <path> Specify the path in which the sources should be checked
                      out.  This directory will be created it if does not exist.
  --swift-scheme <scheme>
  --swift-tag <tag>
  --swift-version <version>
                      Select the version of Swift to check out sources for.
                      If <version> starts with "scheme:" or "tag:", it will
                      select a scheme or tag; otherwise it will be treated as
                      a version number.
  --boringssl-version <version>
EOF
}

# Defaults
if [[ -z "${SWIFT_VERSION}" || ($SWIFT_VERSION != scheme:* && $SWIFT_VERSION != tag:*) ]]; then
    SWIFT_VERSION=scheme:release/6.2
fi
if [[ -z "${BORINGSSL_VERSION}" ]]; then
    BORINGSSL_VERSION=fips-20220613
fi

clone_with_ssh=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        --swift-scheme)
            SWIFT_VERSION="scheme:$2"; shift ;;
        --swift-tag)
            SWIFT_VERSION="tag:$2"; shift ;;
        --swift-version)
            SWIFT_VERSION="$2"; shift ;;
        --boringssl-version)
            BORINGSSL_VERSION="$2"; shift ;;
        --clone-with-ssh)
            clone_with_ssh=true ;;
        --source-dir)
            source_dir="$2"; shift ;;
        *)
            usage; exit 0 ;;
    esac
    shift
done

if [[ ! -z "$source_dir" ]]; then
    mkdir -p "$source_dir"
else
    source_dir=.
fi

if [[ "$clone_with_ssh" == "true" ]]; then
    github=git@github.com:
    clone_arg=--clone-with-ssh
else
    github=https://github.com/
    clone_arg=--clone
fi

cd "$source_dir"

# Fetch Swift
mkdir -p swift-project

groupstart "Fetching Swift"
pushd swift-project >/dev/null

[[ -d swift ]] || git clone ${github}swiftlang/swift.git
cd swift

# Get its dependencies
header "Fetching Swift Dependencies"

extra_args="--skip-history --all-repositories"
if [[ $SWIFT_VERSION == scheme:* ]]; then
    utils/update-checkout ${clone_arg} --scheme ${SWIFT_VERSION#scheme:} ${extra_args}
elif [[ $SWIFT_VERSION == tag:* ]]; then
    utils/update-checkout ${clone_arg} --tag ${SWIFT_VERSION#tag:} ${extra_args}
else
    utils/update-checkout ${clone_arg} --tag swift-${SWIFT_VERSION}-RELEASE ${extra_args}
fi

popd >/dev/null
groupend

# Fetch BoringSSL
groupstart "Fetching BoringSSL"
[[ -d boringssl ]] || git clone https://boringssl.googlesource.com/boringssl
pushd boringssl >/dev/null 2>&1
git checkout ${BORINGSSL_VERSION}
popd >/dev/null 2>&1
groupend

groupstart "Patching Sources"
pushd swift-project >/dev/null

# This `git grep` invocation in a trunk test fails in our Docker for some
# reason, so just turn it into a plain `grep` again.
perl -pi -e 's:"git",:#:' swift/test/Misc/verify-swift-feature-testing.test-sh

# Work around swiftlang/swift-driver#1822 for now
perl -pi -g -we "s#(call rm ... \".\{LIBDISPATCH_BUILD_DIR\}\"\n(\s+)fi\n)#\1\2if [[ -d \"\\\${ANDROID_NDK}\" ]]; then call ln -sf \"\\\${SWIFT_BUILD_PATH}/lib/swift\" \"\\\${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib\"; fi#" swift/utils/build-script-impl

# fix optional result value in backtrace() call
perl -pi -e 's;.init\(clamping: addresses.count\)\)\);.init\(clamping: addresses.count\)\) ?? 0\);g' swift-testing/Sources/Testing/SourceAttribution/Backtrace.swift

# disable backtrace() for Android (needs either API33+ or libandroid-execinfo, or to manually add in backtrace backport); will be fixed post 6.2 (in which case only the above patch is needed)
perl -pi -e 's;os\(Android\);os\(AndroidDISABLED\);g' swift-testing/Sources/Testing/SourceAttribution/Backtrace.swift


# Disable posix_spawnattr_* calls for Android API 23
perl -pi -e 's;try _throwIfPosixError\(posix_spawnattr_init;throw NSError\(domain: NSPOSIXErrorDomain, code: .init\(ENOEXEC\), userInfo: [ NSLocalizedFailureReasonErrorKey: "Process unavailable on Android" ]\) //try _throwIfPosixError\(posix_spawnattr_init;g' swift-corelibs-foundation/Sources/Foundation/Process.swift
perl -pi -e 's;try _throwIfPosixError\(posix_spawnattr_setflags;//try _throwIfPosixError\(posix_spawnattr_setflags;g' swift-corelibs-foundation/Sources/Foundation/Process.swift
perl -pi -e 's;posix_spawnattr_destroy;//posix_spawnattr_destroy;g' swift-corelibs-foundation/Sources/Foundation/Process.swift

# Stub out getgrgid_r and getgrnam_r missing from Android API 23
perl -pi -e 's;getgrgid_r|getgrnam_r;{ _, _, _, _, _ in 0 };g' swift-foundation/Sources/FoundationEssentials/Platform.swift

popd >/dev/null 2>&1
groupend

