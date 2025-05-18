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
$ ./build-docker release /tmp/android-sdk
```

This will create an Ubuntu 24.04 container with the necessary dependencies
to build the Android SDK, including a Swift host toolchain and the
Android NDK that will be used for cross-compilation.

The `version` argument can be one of the following values:

| version | Swift version |
| --- | --- |
| `release` | swift-6.1-RELEASE |
| `devel` | swift-6.2-DEVELOPMENT-SNAPSHOT-yyyy-mm-dd |
| `trunk` | swift-DEVELOPMENT-SNAPSHOT-yyyy-mm-dd |

## Running

The top-level `./build-docker` script installs a host toolchain and the
Android NDK, and then invokes `scripts/fetch-source.sh` which will
fetch tagged sources for libxml2, curl, boringssl, and swift.

It then applies some patches and invokes `scripts/build.sh`,
which will build the sources for each of the specified
architectures. Finally, it combines the NDK and the newly built
SDKs into a single artifactbundle.  

## Specifying Architectures

By default all the supported Android architectures
(`aarch64`, `x86_64`, `aarmv7`)
will be built, but this can be reduced in order to speed
up the build. This can be useful, e.g., as part of a CI that
validates a pull request, as building a single architecture
takes around 30 minutes on a standard ubuntu-24.04 GitHub runner,
whereas building for all the architectures takes over an hour.

To build an artifactbundle for just the `x86_64` architecture, run:

```
TARGET_ARCHS=aarch64 ./build-docker release /tmp/android-sdk
```

## Installing and validating the SDK

The `.github/workflows/pull_request.yml` workflow
will create and upload an installable SDK named something like:
`swift-6.1-RELEASE_android-0.1.artifactbundle.tar.gz`

The workflow will also install the SDK locally and use
[swift-android-action](https://github.com/marketplace/actions/swift-android-action)
to build and test various Swift packages in an Android emulator using the
freshly-created SDK bundle.
