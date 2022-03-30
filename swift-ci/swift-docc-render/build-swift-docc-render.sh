#!/bin/bash
#
# This source file is part of the Swift.org open source project
#
# Copyright (c) 2021 Apple Inc. and the Swift project authors
# Licensed under Apache License v2.0 with Runtime Library Exception
#
# See https://swift.org/LICENSE.txt for license information
# See https://swift.org/CONTRIBUTORS.txt for Swift project authors


set -e

function usage() {
  echo "$0 --output-path <output_path> [OPTIONS]"
  echo ""
  echo "<output_path> - Path to the directory where the built Swift-DocC-Render will be copied"
  echo ""
  echo "OPTIONS"
  echo ""
  echo "-h --help"
  echo "Show help information."
  echo ""
  echo "-b --branch"
  echo "The branch of Swift-DocC-Render to build."
  echo ""
}

OUTPUT_PATH=
BRANCH=main

while [ $# -ne 0 ]; do
  case "$1" in
  -o|--output-path)
    shift
    OUTPUT_PATH="$1"
  ;;
  -b|--branch)
    shift
    BRANCH="$1"
  ;;
  -h|--help)
    usage
    exit 0
  ;;
  *)
    echo "Unrecognised argument \"$1\""
    echo ""
    usage
    exit 1
  ;;
  esac
shift
done

if [ -z "${OUTPUT_PATH}" ]; then
echo "Output path cannot be empty. See $0 --help"
exit 1
fi

function filepath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

DIRECTORY_ROOT="$(dirname $(filepath $0))"
DOCKERFILE_PATH="$DIRECTORY_ROOT"/Dockerfile

docker build -t swift-docc-render:latest \
  --no-cache \
  --build-arg SWIFT_DOCC_RENDER_BRANCH="$BRANCH" \
  --build-arg http_proxy="$http_proxy" \
  --build-arg https_proxy="$https_proxy" \
  --build-arg no_proxy="$no_proxy" \
  -f "$DOCKERFILE_PATH" \
  "$DIRECTORY_ROOT" 

CONTAINER_ID=$(docker create swift-docc-render:latest)

docker cp -a $CONTAINER_ID:/home/build-user/swift-docc-render/dist/. "$OUTPUT_PATH"
 
docker rm $CONTAINER_ID
