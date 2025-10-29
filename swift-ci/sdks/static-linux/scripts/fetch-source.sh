#!/bin/bash
#
# ===----------------------------------------------------------------------===
#
#  Swift Static SDK for Linux: Fetch Sources
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

function usage {
    cat <<EOF
usage: fetch-source.sh [--swift-scheme <scheme>|--swift-tag <tag>
                                               |--swift-version <version>]
                       [--boringssl-version <version>]
                       [--bzip2-version <version>]
                       [--curl-version <version>]
                       [--libarchive-version <version>]
                       [--libxml2-version <version>]
                       [--mimalloc-version <version>]
                       [--musl-version <version>]
                       [--xz-version <version>]
                       [--zlib-version <version>]
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
  --bzip2-version <version>
  --curl-version <version>
  --libarchive-version <version>
  --libxml2-version <version>
  --mimalloc-version <version>
  --musl-version <version>
  --xz-version <version>
  --zlib-version <version>
                      Select the versions of other dependencies.
EOF
}

# Defaults
if [[ -z "${SWIFT_VERSION}" ]]; then
    SWIFT_VERSION=scheme:release/6.0
fi
if [[ -z "${MUSL_VERSION}" ]]; then
    MUSL_VERSION=1.2.5
fi
if [[ -z "${LIBXML2_VERSION}" ]]; then
    LIBXML2_VERSION=2.14.5
fi
if [[ -z "${CURL_VERSION}" ]]; then
    CURL_VERSION=8.15.0
fi
if [[ -z "${BORINGSSL_VERSION}" ]]; then
    BORINGSSL_VERSION=817ab07ebb53da35afea409ab9328f578492832d
fi
if [[ -z "${ZLIB_VERSION}" ]]; then
    ZLIB_VERSION=1.3.1
fi
if [[ -z "${BZIP2_VERSION}" ]]; then
    BZIP2_VERSION=1.0.8
fi
if [[ -z "${LIBARCHIVE_VERSION}" ]]; then
    LIBARCHIVE_VERSION=3.8.1
fi
if [[ -z "${MIMALLOC_VERSION}" ]]; then
    MIMALLOC_VERSION=2.2.4
fi
if [[ -z "${XZ_VERSION}" ]]; then
    XZ_VERSION=5.8.1
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
        --musl-version)
            MUSL_VERSION="$2"; shift ;;
        --libxml2-version)
            LIBXML2_VERSION="$2"; shift ;;
        --curl-version)
            CURL_VERSION="$2"; shift ;;
        --boringssl-version)
            BORINGSSL_VERSION="$2"; shift ;;
        --zlib-version)
            ZLIB_VERSION="$2"; shift ;;
        --bzip2-version)
            BZIP2_VERSION="$2"; shift ;;
        --libarchive-version)
            LIBARCHIVE_VERSION="$2"; shift ;;
        --mimalloc-version)
            MIMALLOC_VERSION="$2"; shift ;;
        --xz-version)
            XZ_VERSION="$2"; shift ;;
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
header "Fetching Swift"

mkdir -p swift-project
pushd swift-project >/dev/null

[[ -d swift ]] || git clone ${github}apple/swift.git
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

# Fetch Musl (can't clone using ssh)
header "Fetching Musl"

[[ -d musl ]] || git clone https://git.musl-libc.org/git/musl
pushd musl >/dev/null 2>&1
git checkout v${MUSL_VERSION}
popd >/dev/null 2>&1

# Fetch libxml2
header "Fetching libxml2"

[[ -d libxml2 ]] || git clone ${github}GNOME/libxml2.git
pushd libxml2 >/dev/null 2>&1
git checkout v${LIBXML2_VERSION}
popd >/dev/null 2>&1

# Fetch curl
header "Fetching curl"

[[ -d curl ]] || git clone ${github}curl/curl.git
pushd curl >/dev/null 2>&1
git checkout curl-$(echo ${CURL_VERSION} | tr '.' '_')
popd >/dev/null 2>&1

# Fetch BoringSSL (also can't clone using ssh)
header "Fetching BoringSSL"

[[ -d boringssl ]] || git clone https://boringssl.googlesource.com/boringssl
pushd boringssl >/dev/null 2>&1
git checkout ${BORINGSSL_VERSION}
popd >/dev/null 2>&1

# Fetch zlib
header "Fetching zlib"

[[ -d zlib ]] || git clone ${github}madler/zlib.git
pushd zlib >/dev/null 2>&1
git checkout v${ZLIB_VERSION}
popd >/dev/null 2>&1

# Fetch bzip2
header "Fetching bzip2"

[[ -d bzip2 ]] | git clone git://sourceware.org/git/bzip2.git
pushd bzip2 >/dev/null 2>&1
git checkout bzip2-${BZIP2_VERSION}
popd >/dev/null 2>&1

# Fetch libarchive
header "Fetching libarchive"

[[ -d libarchive ]] | git clone ${github}libarchive/libarchive.git
pushd libarchive >/dev/null 2>&1
git checkout v${LIBARCHIVE_VERSION}
popd >/dev/null 2>&1

# Fetch mimalloc
header "Fetching mimalloc"

[[ -d mimalloc ]]  | git clone ${github}microsoft/mimalloc.git
pushd mimalloc >/dev/null 2>&1
git checkout v${MIMALLOC_VERSION}
popd

# Fetch xz-utils
header "Fetching xz"

[[ -d xz ]] | git clone ${github}tukaani-project/xz.git
pushd xz >/dev/null 2>&1
git checkout v${XZ_VERSION}
popd
