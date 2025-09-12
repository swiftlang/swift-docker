# Dockerfile-based build for Swift Android SDK

This is a Dockerfile-based build set-up for the Swift Android SDK.

The top-level `./build-docker` script will create a
Docker container and install a host toolchain and the
Android NDK, and then invoke `scripts/fetch-source.sh` which will
fetch tagged sources for libxml2, curl, boringssl, and swift.

It can be run with:

```
$ ./build-docker <version> <workdir>
```

for example:

```
$ ./build-docker tag:swift-6.2-RELEASE /tmp/android-sdk
```

This will create an Ubuntu 24.04 container with the necessary dependencies
to build the Android SDK, including a Swift host toolchain and the
Android NDK that will be used for cross-compilation.

The `version` argument can be a branch scheme, like "scheme:release/6.2", or a
tag, like "tag:swift-6.2-DEVELOPMENT-SNAPSHOT-2025-09-04-a".

> [!WARNING]
> The workdir argument must not be located in a git repository (e.g., it cannot be the
> current directory)

## Running

The top-level `./build-docker` script installs a host toolchain and the
Android NDK, and then invokes `scripts/fetch-source.sh` which will
fetch tagged sources for libxml2, curl, boringssl, and swift.

It then applies some perl substitutions and invokes `scripts/build.sh`,
which will build the sources for each of the specified
architectures and then combines the SDKs into a single
artifactbundle with targetTriples for each of the supported
architectures (`aarch64`, `x86_64`, `aarmv7`)
and Android API levels (28-35).

## Specifying Architectures

By default, all the supported Android architectures
will be built, but this can be reduced in order to speed
up the build. This can be useful, e.g., as part of a CI that
validates a pull request, as building a single architecture
takes around 30 minutes on a standard ubuntu-24.04 GitHub runner,
whereas building for all the architectures takes over an hour.

To build an artifactbundle for just the `x86_64` architecture, run:

```
TARGET_ARCHS=x86_64 ./build-docker scheme:main /tmp/android-sdk
```

## Building the Swift compiler from source and running the validation suite

All tags that are specified will download the official release or snapshot
toolchain and build only the bundle by default, while building from a branch
scheme always builds the full Swift compiler from the latest commit in that
branch. If you want to build the Swift compiler from source for a tag also and
run the compiler validation suite, specify the `BUILD_COMPILER` variable:

```
BUILD_COMPILER=yes ./build-docker tag:swift-DEVELOPMENT-SNAPSHOT-2025-09-04-a /tmp/android-sdk
```

## Building locally

Instead of building within a Docker container, the script can also
perform the build locally on an Ubuntu 24.04 machine with all the
build prerequisites already installed. This will generate
the same artifacts in approximately half the time, and
may be suitable to an already containerized envrionment (such as
a GitHub runner). A local build can be run with the
`build-local` script, such as:

```
./build-local scheme:release/6.2 /tmp/android-sdk
```
