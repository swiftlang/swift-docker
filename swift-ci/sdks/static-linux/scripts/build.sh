#!/bin/bash
#
# ===----------------------------------------------------------------------===
#
#  Swift Static SDK for Linux: Build Script
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
usage: build.sh --source-dir <path> --products-dir <path>
                [--name <sdk-name>] [--version <version>] [--build-dir <path>]
                [--archs <arch>[,<arch> ...]]

Build the fully statically linked SDK for Linux.

Options:

  --name <sdk-name>     Specify the name of the SDK bundle.
  --version <version>   Specify the version of the Static Linux SDK.
  --source-dir <path>   Specify the path in which the sources can be found.
  --products-dir <path> Specify the path in which the products should be written.
  --build-dir <path>    Specify the path in which intermediates should be stored.
  --archs <arch>[,<arch> ...]
                        Specify the architectures for which we should build
                        the SDK.
                        (Default is ${archs}).
  --build <type>        Specify the CMake build type to use (Release, Debug,
                        RelWithDebInfo).
                        (Default is ${build_type}).
  -j <count>
  --jobs <count>        Specify the number of parallel jobs to run at a time.
                        (Default is ${parallel_jobs}.)
EOF
}

# Declare all the packages we depend on
declare -a packages

function declare_package
{
    local name=$1
    local userVisibleName=$2
    local license=$3
    local url=$4

    local snake=$(echo ${name} | tr '_' '-')

    declare -g ${name}_snake="$snake"
    declare -g ${name}_name="$userVisibleName"
    declare -g ${name}_license="$license"
    declare -g ${name}_url="$url"

    packages+=(${name})
}

declare_package static_linux_sdk \
                "Swift statically linked SDK for Linux" \
                "Apache-2.0" "https://swift.org/install/sdk"
declare_package swift "swift" "Apache-2.0" "https://swift.org"
declare_package musl "musl" "MIT" "https://musl.org"
declare_package musl_fts "musl-fts" "BSD-3-Clause" \
                "https://github.com/void-linux/musl-fts"
declare_package libxml2 "libxml2" "MIT" \
                "https://github.com/GNOME/libxml2"
declare_package curl "curl" "MIT" "https://curl.se"
declare_package boringssl "boringssl" "OpenSSL AND ISC AND MIT" \
                "https://boringssl.googlesource.com/boringssl/"
declare_package zlib "zlib" "Zlib" "https://zlib.net"

# Parse command line arguments
static_linux_sdk_version=0.0.1
sdk_name=
archs=x86_64,aarch64
build_type=RelWithDebInfo
parallel_jobs=$(($(nproc --all) + 2))
source_dir=
build_dir=$(pwd)/build
products_dir=
while [ "$#" -gt 0 ]; do
    case "$1" in
        --source-dir)
            source_dir="$2"; shift ;;
        --build-dir)
            build_dir="$2"; shift ;;
        --products-dir)
            products_dir="$2"; shift ;;
        --name)
            sdk_name="$2"; shift ;;
        --archs)
            archs="$2"; shift ;;
        --version)
            static_linux_sdk_version="$2"; shift ;;
        -j|--jobs)
            parallel_jobs=$2; shift ;;
        *)
            echo "Unknown argument '$1'"; usage; exit 0 ;;
    esac
    shift
done

# Work out the host architecture
case $(arch) in
    arm64|aarch64)
        host_arch=aarch64
        ;;
    amd64|x86_64)
        host_arch=x86_64
        ;;
    *)
        echo "Unknown host architecture $(arch)"
        exit 1
        ;;
esac

# Change the commas for spaces
archs="${archs//,/ }"

if [[ -z "$source_dir" || -z "$products_dir" ]]; then
    usage
    exit 1
fi

if ! swiftc=$(which swiftc); then
    echo "build.sh: Unable to find Swift compiler.  You must have a Swift toolchain installed to build the statically linked SDK."
    exit 1
fi

script_dir=$(dirname -- "${BASH_SOURCE[0]}")
resource_dir="${script_dir}/../resources"

# Find the version numbers of the various dependencies
function describe {
    pushd $1 >/dev/null 2>&1
    git describe --tags
    popd >/dev/null 2>&1
}
function versionFromTag {
    desc=$(describe $1)
    if [[ $desc == v* ]]; then
        echo "${desc#v}"
    else
        echo "${desc}"
    fi
}

swift_version=$(describe ${source_dir}/swift-project/swift)
if [[ $swift_version == swift-* ]]; then
    swift_version=${swift_version#swift-}
fi

if [[ -z "$sdk_name" ]]; then
    sdk_name=swift-${swift_version}_static-linux-${static_linux_sdk_version}
fi

musl_version=$(versionFromTag ${source_dir}/musl)

musl_fts_version=$(cat ${resource_dir}/fts/VERSION)

libxml2_version=$(versionFromTag ${source_dir}/libxml2)

curl_desc=$(describe ${source_dir}/curl | tr '_' '.')
curl_version=${curl_desc#curl-}

boringssl_version=$(describe ${source_dir}/boringssl)

zlib_version=$(versionFromTag ${source_dir}/zlib)

function quiet_pushd {
    pushd "$1" >/dev/null 2>&1
}
function quiet_popd {
    popd >/dev/null 2>&1
}

header "Fully statically linked Linux SDK build script"

swift_dir=$(realpath $(dirname "$swiftc")/..)

echo "Swift found at ${swift_dir}"
echo "Building for ${archs}"
echo "Sources are in ${source_dir}"
echo "Build will happen in ${build_dir}"
echo "Products will be placed in ${products_dir}"
echo
echo "Building from:"
echo "  - Swift ${swift_version}"
echo "  - Musl ${musl_version}"
echo "  - Musl FTS ${musl_fts_version}"
echo "  - libxml2 ${libxml2_version}"
echo "  - curl ${curl_version}"
echo "  - BoringSSL ${boringssl_version}"
echo "  - zlib ${zlib_version}"

function run() {
    echo "$@"
    "$@"
}

header "Building CMake from source"

quiet_pushd ${source_dir}/swift-project/cmake
run cmake -G 'Ninja' ./ \
    -B ${build_dir}/cmake/build \
    -DCMAKE_INSTALL_PREFIX=${build_dir}/cmake/install \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_USE_OPENSSL=OFF \
    -DBUILD_CursesDialog=OFF \
    -DBUILD_TESTING=OFF
run ninja -C ${build_dir}/cmake/build
run ninja -C ${build_dir}/cmake/build install
run export PATH="${build_dir}/cmake/install/bin:$PATH"
quiet_popd
run cmake --version

header "Patching Musl"

echo -n "Patching Musl for locale support... "
patch=$(realpath "${resource_dir}/patches/musl.patch")
if git -C ${source_dir}/musl apply --reverse --check "$patch" >/dev/null 2>&1; then
    echo "already patched"
elif git -C ${source_dir}/musl apply "$patch" >/dev/null 2>&1; then
    echo "done"
else
    echo "failed"
    exit 1
fi

# -----------------------------------------------------------------------

header "Building clang for host"

mkdir -p ${build_dir}/host/clang ${build_dir}/clang

run cmake -G Ninja -S ${source_dir}/swift-project/llvm-project/llvm \
    -B ${build_dir}/host/clang \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_PROJECTS="clang" \
    -DLLVM_PARALLEL_LINK_JOBS=1 \
    -DCMAKE_INSTALL_PREFIX=${build_dir}/clang

quiet_pushd ${build_dir}/host/clang
run ninja -j$parallel_jobs
quiet_popd

header "Installing clang for host"

quiet_pushd ${build_dir}/host/clang
run ninja -j$parallel_jobs install
quiet_popd

clang_dir=${build_dir}/clang

header "Clang version"

${clang_dir}/bin/clang --version

# -----------------------------------------------------------------------

for arch in $archs; do

    # Fix architecture names
    alt_arch=$arch
    case $arch in
        amd64) arch=x86_64 ;;
        aarch64|arm64) arch=aarch64; alt_arch=arm64 ;;
    esac

    triple=${arch}-swift-linux-musl

    sdk_root=${build_dir}/sdk_root/${arch}
    mkdir -p "$sdk_root"

    sdk_resource_dir="${sdk_root}/usr/lib/swift/clang"
    mkdir -p "${sdk_resource_dir}/include" \
          "${sdk_resource_dir}/lib/linux" \
          "${sdk_root}/usr/lib/swift_static"
    ln -sf ../swift/clang "${sdk_root}/usr/lib/swift_static/clang"

    clang_resource_dir=$(${clang_dir}/bin/clang -print-resource-dir)
    cp -rT $clang_resource_dir/include $sdk_resource_dir/include

    cc="${clang_dir}/bin/clang -target $triple -resource-dir ${sdk_resource_dir} --sysroot ${sdk_root}"
    cxx="${clang_dir}/bin/clang++ -target $triple -resource-dir ${sdk_resource_dir} --sysroot ${sdk_root} -stdlib=libc++ -unwindlib=libunwind"
    as="$cc"

    # Creating this gets rid of a warning
    cat > $sdk_root/SDKSettings.json <<EOF
{
  "DisplayName": "Swift SDK for Statically Linked Linux ($arch)",
  "Version": "0.0.1",
  "VersionMap": {},
  "CanonicalName": "${arch}-swift-linux-musl"
}
EOF

    # Make some directories
    mkdir -p "$build_dir/$arch/musl" \
          "$build_dir/$arch/runtimes" \
          "$sdk_root/$arch/usr"

    # -----------------------------------------------------------------------

    header "Building Musl for ${arch}"

    quiet_pushd "${build_dir}/$arch/musl"
    if [[ "$BUILD_TYPE" == "Debug" ]]; then
        maybe_debug="--enable-debug"
    fi
    run ${source_dir}/musl/configure \
                  --target=$triple \
                  --prefix=$sdk_root/usr \
                  --disable-shared \
                  --enable-static \
                  --with-unwind-tables=async \
                  $maybe_debug \
                  CC="$cc" CXX="$cxx" AS="$as" AR="ar" RANLIB="ranlib"
    make -j$parallel_jobs
    make -j$parallel_jobs install
    quiet_popd

    # -----------------------------------------------------------------------

    header "Modularizing Musl's headers"

    python3 ${script_dir}/fixtypes.py \
            ${source_dir}/musl/arch/${arch}/bits/alltypes.h.in \
            ${source_dir}/musl/include/alltypes.h.in \
            $sdk_root/usr/include/bits/musldefs.h \
            $sdk_root/usr/include/bits/alltypes.h \
            $sdk_root/usr/include/bits/types

    quiet_pushd $sdk_root/usr/include
    for header in $(find . -name '*.h'); do
        echo "Fixing $header"
        sed -i -E "s:#define[ \t]+__NEED_([_A-Za-z][_A-Za-z0-9]*):#include <bits/types/\1.h>:g;/#include <bits\/alltypes.h>/d" $header
    done
    mkdir -p _modules
    for header in assert complex ctype errno fenv float inttypes iso646 \
                         limits locale math setjmp stdalign stdarg stdatomic \
                         stdbool stddef stdint stdio stdlib string tgmath \
                         uchar wchar wctype; do
        echo "Making _modules/${header}_h.h"
        cat > _modules/${header}_h.h <<EOF
#if !__building_module(${header}_h)
#error "Do not include this header directly, include <${header}.h> instead"
#endif
#include <${header}.h>
EOF
    done
    quiet_popd

    # -----------------------------------------------------------------------

    header "Constructing modulemap"

    # Install the modulemap but *not* SwiftMusl.h
    awk '
/^\/\/ START SWIFT ONLY/ { ignore=1 }
/^\/\/ END SWIFT ONLY/ { ignore=0; next }
ignore == 0 { print }
' \
        "${source_dir}/swift-project/swift/stdlib/public/Platform/musl.modulemap" \
        > "$sdk_root/usr/include/module.modulemap"
    echo "OK"

    # -----------------------------------------------------------------------

    header "Setting up for build"

    # Not having these makes CMake compiler identification fail, because
    # it can't compile a C++ program, so make dummy files for now.
    touch ${sdk_root}/usr/lib/libc++.a
    touch ${sdk_root}/usr/lib/libc++abi.a
    touch ${sdk_root}/usr/lib/libunwind.a
    touch ${sdk_resource_dir}/lib/linux/libclang_rt.builtins-${arch}.a
    touch ${sdk_resource_dir}/lib/linux/crtbeginT.o
    touch ${sdk_resource_dir}/lib/linux/crtend.o

    # Install a couple of fake Linux kernel headers; we don't want to
    # use the actual kernel headers because they're GPL'd.
    mkdir -p ${sdk_root}/usr/include
    cp -r ${resource_dir}/linux ${sdk_root}/usr/include

    # Create a CMake toolchain file
    cat > ${build_dir}/${arch}/toolchain.cmake <<EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ${arch})
set(CMAKE_ASM_COMPILER_TARGET ${triple})
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER_TARGET ${triple})
set(CMAKE_Swift_COMPILER_TARGET ${triple})
set(CMAKE_SYSROOT ${sdk_root})

set(CMAKE_CROSSCOMPILING=YES)
set(CMAKE_EXE_LINKER_FLAGS "-unwindlib=libunwind -rtlib=compiler-rt -stdlib=libc++ -fuse-ld=lld -lc++ -lc++abi")

set(CMAKE_C_COMPILER ${clang_dir}/bin/clang -resource-dir ${sdk_resource_dir})
set(CMAKE_CXX_COMPILER ${clang_dir}/bin/clang++ -resource-dir ${sdk_resource_dir} -stdlib=libc++)
set(CMAKE_ASM_COMPILER ${clang_dir}/bin/clang -resource-dir ${sdk_resource_dir})
set(CMAKE_FIND_ROOT_PATH ${sdk_root})
EOF

    # -----------------------------------------------------------------------

    header "Building compiler-rt for ${arch}"

    mkdir -p ${build_dir}/$arch/compiler-rt
    quiet_pushd ${build_dir}/$arch/compiler-rt

    run cmake ${source_dir}/swift-project/llvm-project/compiler-rt \
        -G Ninja \
        -DCMAKE_TOOLCHAIN_FILE=${build_dir}/$arch/toolchain.cmake \
        -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" \
        -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
        -DCOMPILER_RT_BUILD_BUILTINS=ON \
        -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
        -DCOMPILER_RT_BUILD_MEMPROF=OFF \
        -DCOMPILER_RT_BUILD_PROFILE=OFF \
        -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
        -DCOMPILER_RT_BUILD_CTX_PROFILE=OFF \
        -DCOMPILER_RT_BUILD_XRAY=OFF \
        -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON \
        -DCOMPILER_RT_BUILD_ORC=OFF \
        -DCMAKE_INSTALL_PREFIX="${sdk_resource_dir}"

    run ninja -j${parallel_jobs}
    run ninja -j${parallel_jobs} install

    quiet_popd

    # -----------------------------------------------------------------------

    header "Building fts for ${arch}"

    run cmake -G Ninja -S ${resource_dir}/fts -B ${build_dir}/$arch/fts \
          -DCMAKE_TOOLCHAIN_FILE=${build_dir}/$arch/toolchain.cmake \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo \
          -DCMAKE_INSTALL_PREFIX=$sdk_root/usr

    quiet_pushd ${build_dir}/$arch/fts
    run ninja -j$parallel_jobs
    quiet_popd

    header "Installing fts for ${arch}"

    quiet_pushd ${build_dir}/$arch/fts
    run ninja -j$parallel_jobs install
    quiet_popd

    # -----------------------------------------------------------------------

    header "Building runtimes for ${arch}"

    run cmake -G Ninja -S ${source_dir}/swift-project/llvm-project/runtimes \
          -B ${build_dir}/$arch/runtimes \
          -DCMAKE_TOOLCHAIN_FILE=${build_dir}/$arch/toolchain.cmake \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo \
          -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" \
          -DLLVM_PARALLEL_LINK_JOBS=1 \
          -DLIBUNWIND_ENABLE_SHARED=NO \
          -DLIBUNWIND_ENABLE_STATIC=YES \
          -DLIBCXXABI_ENABLE_SHARED=NO \
          -DLIBCXXABI_ENABLE_STATIC=YES \
          -DLIBCXXABI_USE_LLVM_UNWINDER=YES \
          -DLIBCXXABI_USE_COMPILER_RT=YES \
          -DLIBCXX_ENABLE_SHARED=OFF \
          -DLIBCXX_ENABLE_STATIC=ON \
          -DLIBCXX_USE_COMPILER_RT=YES \
          -DLIBCXX_HAS_PTHREAD_API=YES \
          -DLIBCXX_HAS_MUSL_LIBC=YES \
          -DLIBCXX_INCLUDE_BENCHMARKS=NO \
          -DLIBCXX_CXX_ABI=libcxxabi \
          -DCMAKE_INSTALL_PREFIX="$sdk_root/usr"

    quiet_pushd ${build_dir}/$arch/runtimes
    run ninja -j$parallel_jobs
    quiet_popd

    header "Installing runtimes for ${arch}"

    quiet_pushd ${build_dir}/$arch/runtimes
    run ninja -j$parallel_jobs install
    quiet_popd

    ldflags="-fuse-ld=lld -rtlib=compiler-rt -unwindlib=libunwind"
    cxxldflags="-fuse-ld=lld -rtlib=compiler-rt -unwind=libunwind -lc++ -lc++abi"

    # -----------------------------------------------------------------------

    header "Building zlib for $arch"

    mkdir -p $build_dir/$arch/zlib
    quiet_pushd $build_dir/$arch/zlib
    run /bin/env \
          CC="$cc" \
          CXX="$cxx" \
          LDFLAGS="$ldflags" \
          CXXLDFLAGS="$cxxldflags" \
          AS="$as" \
          AR="ar" RANLIB="ranlib" \
          "${source_dir}/zlib/configure" \
          --static \
          --prefix=$sdk_root/usr
    make -j$parallel_jobs
    quiet_popd

    header "Installing zlib for $arch"

    quiet_pushd $build_dir/$arch/zlib
    run make -j$parallel_jobs install
    quiet_popd

    # -----------------------------------------------------------------------

    header "Building libxml2 for $arch"

    run cmake -G Ninja -S ${source_dir}/libxml2 -B ${build_dir}/$arch/libxml2 \
          -DCMAKE_TOOLCHAIN_FILE=${build_dir}/$arch/toolchain.cmake \
          -DCMAKE_EXTRA_LINK_FLAGS="-rtlib=compiler-rt -unwindlib=libunwind -stdlib=libc++ -fuse-ld=lld -lc++ -lc++abi" \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo \
          -DCMAKE_INSTALL_PREFIX=$sdk_root/usr \
          -DBUILD_SHARED_LIBS=NO \
          -DLIBXML2_WITH_PYTHON=NO \
          -DLIBXML2_WITH_ICU=NO \
          -DLIBXML2_WITH_LZMA=NO

    quiet_pushd ${build_dir}/$arch/libxml2
    run ninja -j$parallel_jobs
    quiet_popd

    header "Installing libxml2 for $arch"

    quiet_pushd ${build_dir}/$arch/libxml2
    run ninja -j$parallel_jobs install
    quiet_popd

    # -----------------------------------------------------------------------

    header "Building BoringSSL for $arch"

    run cmake -G Ninja -S ${source_dir}/boringssl -B ${build_dir}/$arch/boringssl \
        -DCMAKE_TOOLCHAIN_FILE=${build_dir}/$arch/toolchain.cmake \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DCMAKE_INSTALL_PREFIX=$sdk_root/usr \
        -DBUILD_SHARED_LIBS=NO

    quiet_pushd ${build_dir}/$arch/boringssl
    run ninja -j$parallel_jobs
    quiet_popd

    header "Installing BoringSSL for $arch"

    quiet_pushd ${build_dir}/$arch/boringssl
    run ninja -j$parallel_jobs install
    quiet_popd

    # -----------------------------------------------------------------------

    header "Building libcurl for $arch"

    run cmake -G Ninja -S ${source_dir}/curl -B ${build_dir}/$arch/curl \
        -DCMAKE_TOOLCHAIN_FILE=${build_dir}/$arch/toolchain.cmake \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DCMAKE_INSTALL_PREFIX=$sdk_root/usr \
        -DBUILD_SHARED_LIBS=NO \
        -DBUILD_STATIC_LIBS=YES \
        -DBUILD_CURL_EXE=NO

    quiet_pushd ${build_dir}/$arch/curl
    ninja -j$parallel_jobs
    quiet_popd

    header "Installing libcurl for $arch"

    quiet_pushd ${build_dir}/$arch/curl
    ninja -j$parallel_jobs install
    quiet_popd

    # -----------------------------------------------------------------------

    ###FIXME: Ideally we'd run the Swift build *once* rather than for each
    ###       architecture, since Swift knows how to build for multiple
    ###       architectures.
    ###
    ###       Unfortunately, it presently builds different architectures
    ###       for the same platform into libraries at the same location,
    ###       which is fine on Darwin because Mach-O supports fat binaries,
    ###       but doesn't work here.
    ###
    ###       If we fix rdar://122472563, this problem will go away, and
    ###       then we can re-work this to run a single Swift build covering
    ###       all desired architectures.

    header "Building Swift for $arch"

    # Construct a .cfg file for Clang; we need this because the Swift build
    # will build a Clang of its own, but that Clang needs to be set up to build
    # for the static SDK (which means we need a .cfg file)
    build_arch=$(uname -m)
    llvm_bin=${build_dir}/swift/Ninja-RelWithDebInfoAssert/llvm-linux-${build_arch}/bin
    swift_bin=${build_dir}/swift/Ninja-RelWithDebInfoAssert/swift-linux-${build_arch}/bin
    mkdir -p $llvm_bin $swift_bin
    cat >> $llvm_bin/${arch}-swift-linux-musl-clang.cfg <<EOF
--sysroot ${sdk_root}
-resource-dir ${sdk_resource_dir}
-target ${arch}-swift-linux-musl
-rtlib=compiler-rt
-stdlib=libc++
-fuse-ld=lld
-unwindlib=libunwind
-lc++abi
-static
EOF
    ln -sf ${arch}-swift-linux-musl-clang.cfg \
       $llvm_bin/${arch}-swift-linux-musl-clang++.cfg

    ln -sf $llvm_bin/${arch}-swift-linux-musl-clang.cfg \
       $swift_bin/${arch}-swift-linux-musl-clang.cfg
    ln -sf $llvm_bin/${arch}-swift-linux-musl-clang++.cfg \
       $swift_bin/${arch}-swift-linux-musl-clang++.cfg

    SWIFT_SOURCE_ROOT="${source_dir}/swift-project" \
    SWIFT_BUILD_ROOT="${build_dir}/swift" \
    run ${source_dir}/swift-project/swift/utils/build-script -r \
        --reconfigure \
        --compiler-vendor=apple \
        --bootstrapping hosttools \
        --build-linux-static --install-swift \
        --stdlib-deployment-targets linux-$host_arch,linux-static-$arch \
        --build-stdlib-deployment-targets all \
        --musl-path=${build_dir}/sdk_root \
        --linux-static-arch=$arch \
        --install-destdir=$sdk_root \
        --install-prefix=/usr \
        --swift-install-components="libexec;stdlib;sdk-overlay" \
        --extra-cmake-options="-DSWIFT_SHOULD_BUILD_EMBEDDED_STDLIB=NO -DLLVM_USE_LINKER=lld -DLLVM_NO_DEAD_STRIP=On" \
        $build_script_lto

    # Find some tools
    swiftc=$(find ${build_dir}/swift -name 'swiftc' | grep -v bootstrapping)
    lld=$(find ${build_dir}/swift -name 'ld.lld')

    # Add the Swift compiler to the CMake toolchain file
    cat >> ${build_dir}/$arch/toolchain.cmake <<EOF
set(CMAKE_Swift_FLAGS "-static-stdlib -use-ld=${lld} -sdk ${sdk_root} -target ${arch}-swift-linux-musl -resource-dir ${sdk_root}/usr/lib/swift_static -Xclang-linker -resource-dir -Xclang-linker ${sdk_resource_dir}")
set(CMAKE_Swift_COMPILER ${swiftc})
EOF

    # Fix-up the static-stdlib-args.lnk (it can't have dispatch in it yet)
    linkfile="${sdk_root}/usr/lib/swift_static/linux-static/static-stdlib-args.lnk"
    mv "$linkfile" "$linkfile.bak"
    grep -v '\(-ldispatch\|-lBlocksRuntime\)' "$linkfile.bak" > "$linkfile"

    # -----------------------------------------------------------------------

    header "Building Dispatch for $arch"

    run cmake -G Ninja -S ${source_dir}/swift-project/swift-corelibs-libdispatch \
          -B ${build_dir}/$arch/dispatch \
          -DCMAKE_TOOLCHAIN_FILE=${build_dir}/$arch/toolchain.cmake \
          -DCMAKE_REQUIRED_DEFINITIONS=-D_GNU_SOURCE \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo \
          -DCMAKE_INSTALL_PREFIX=$sdk_root/usr \
          -DCMAKE_Swift_COMPILER_WORKS=YES \
          -DBUILD_SHARED_LIBS=NO \
          -DENABLE_SWIFT=YES \
          -DSWIFT_SYSTEM_NAME=linux-static

    quiet_pushd ${build_dir}/$arch/dispatch
    run ninja -j$parallel_jobs
    quiet_popd

    # -----------------------------------------------------------------------

    header "Building Foundation for $arch"

    run cmake -G Ninja -S ${source_dir}/swift-project/swift-corelibs-foundation \
          -B ${build_dir}/$arch/foundation \
          -DCMAKE_TOOLCHAIN_FILE=${build_dir}/$arch/toolchain.cmake \
          -DCMAKE_REQUIRED_DEFINITIONS=-D_GNU_SOURCE \
          -DCMAKE_BUILD_TYPE=RelWithDebInfo \
          -DCMAKE_INSTALL_PREFIX=$sdk_root/usr \
          -DCMAKE_INSTALL_LIBDIR=lib/swift_static/linux-static \
          -DBUILD_SHARED_LIBS=NO \
          -DBUILD_FULLY_STATIC=YES \
          -DSWIFT_SYSTEM_NAME=linux-static \
          -DFOUNDATION_PATH_TO_LIBDISPATCH_SOURCE=${source_dir}/swift-project/swift-corelibs-libdispatch \
          -DFOUNDATION_PATH_TO_LIBDISPATCH_BUILD=${build_dir}/$arch/dispatch \
          -D_SwiftFoundation_SourceDIR=${source_dir}/swift-project/swift-foundation \
          -D_SwiftFoundationICU_SourceDIR=${source_dir}/swift-project/swift-foundation-icu \
          -D_SwiftCollections_SourceDIR=${source_dir}/swift-project/swift-collections \
          -DSwiftFoundation_MACRO=/usr/local/swift/lib/swift/host/plugins/libFoundationMacros.so \
          -DCMAKE_Swift_COMPILER_WORKS=YES \
          -Ddispatch_DIR=${build_dir}/$arch/dispatch/cmake/modules

    quiet_pushd ${build_dir}/$arch/foundation
    run ninja -j$parallel_jobs
    quiet_popd

    # -----------------------------------------------------------------------

    # Install Foundation *before* Dispatch because the former doesn't expect
    # to find Dispatch installed :-(

    quiet_pushd ${build_dir}/$arch/foundation
    run ninja -j$parallel_jobs install
    quiet_popd

    # -----------------------------------------------------------------------

    # Install Dispatch *after* building Foundation, because the latter doesn't
    # expect it to be installed when Foundation is building.

    quiet_pushd ${build_dir}/$arch/dispatch
    run ninja -j$parallel_jobs install
    quiet_popd

    # Finally, put the static-stdlib-args.lnk file back
    mv -f "$linkfile.bak" "$linkfile"

    # -----------------------------------------------------------------------

    # HACK: Until swift-collections is fixed to install in the right place,
    # we need to move it from the wrong location to the right location; check
    # for it in the wrong location and move it if we find it.
    static_dir=$sdk_root/usr/lib/swift_static
    if [ -f $static_dir/linux/lib_FoundationCollections.a ]; then
        mv $static_dir/linux/lib_FoundationCollections.a \
           $static_dir/linux-static/lib_FoundationCollections.a
        mv $static_dir/linux/_FoundationCollections.swiftmodule \
           $static_dir/linux-static/_FoundationCollections.swiftmodule
    fi

    # We don't need the Linux libraries here, but turning off the Linux build
    # causes trouble, so we're going to end up building them anyway.
    rm -rf \
       $sdk_root/usr/lib/swift/linux \
       $sdk_root/usr/lib/swift_static/linux

done

# Now generate the bundle
header "Bundling SDK"

spdx_uuid=$(uuidgen)
spdx_doc_uuid=$(uuidgen)
spdx_timestamp=$(date -Iseconds)

sdk_name=swift-${swift_version}_static-linux-${static_linux_sdk_version}
bundle="${sdk_name}.artifactbundle"

rm -rf "${build_dir}/$bundle"
mkdir -p "${build_dir}/$bundle/$sdk_name/swift-linux-musl"

quiet_pushd ${build_dir}/$bundle

# First the info.json, for SwiftPM
cat > info.json <<EOF
{
  "schemaVersion": "1.0",
  "artifacts": {
    "$sdk_name": {
      "variants": [
        {
          "path": "$sdk_name/swift-linux-musl"
        }
      ],
      "version": "0.0.1",
      "type": "swiftSDK"
    }
  }
}
EOF

# Now generate SPDX data
cat > sbom.spdx.json <<EOF
{
  "SPDXID": "SPDXRef-DOCUMENT",
  "name": "SBOM-SPDX-${spdx_uuid}",
  "spdxVersion": "SPDX-2.3",
  "creationInfo": {
    "created": "${spdx_timestamp}",
    "creators": [
      "Organization: Apple, Inc."
    ]
  },
  "dataLicense": "Apache-2.0",
  "documentNamespace": "urn:uuid:${spdx_doc_uuid}",
  "documentDescribes": [
    "SPDXRef-Package-static-linux-sdk"
  ],
  "packages": [
EOF

first=true
for package in ${packages[@]}; do
    if [[ "$first" == "true" ]]; then
        first=false
    else
        cat >> sbom.spdx.json <<EOF
    },
EOF
    fi

    snake=${package}_snake; snake=${!snake}
    version=${package}_version; version=${!version}
    name=${package}_name; name=${!name}
    license=${package}_license; license=${!license}
    url=${package}_url; url=${!url}

    cat >> sbom.spdx.json <<EOF
    {
      "SPDXID": "SPDXRef-Package-${snake}",
      "name": "${name}",
      "versionInfo": "${version}",
      "filesAnalyzed": false,
      "licenseDeclared": "${license}",
      "licenseConcluded": "${license}",
      "downloadLocation": "${url}",
      "copyrightText": "NOASSERTION",
      "checksums": []
EOF
done

cat >> sbom.spdx.json <<EOF
    }
  ],
  "relationships": [
EOF

first=true
for package in ${packages[@]}; do
    if [[ "$package" == "static_linux_sdk" ]]; then
        continue
    fi

    if [[ "$first" == "true" ]]; then
        first=false
    else
        cat >> sbom.spdx.json <<EOF
    },
EOF
    fi

    snake=${package}_snake; snake=${!snake}

    cat >> sbom.spdx.json <<EOF
    {
      "spdxElementId": "SPDXRef-Package-static-linux-sdk",
      "relationshipType": "GENERATED_FROM",
      "relatedSpdxElement": "SPDXRef-Package-${snake}"
EOF
done

cat >> sbom.spdx.json <<EOF
    }
  ]
}
EOF

cd "$sdk_name/swift-linux-musl"

cat > swift-sdk.json <<EOF
{
  "schemaVersion": "4.0",
  "targetTriples": {
EOF

first=true
for arch in $archs; do
    if [[ "$first" == "true" ]]; then
        first=false
    else
        cat >> swift-sdk.json <<EOF
    },
EOF
    fi
    cat >> swift-sdk.json <<EOF
    "${arch}-swift-linux-musl": {
      "toolsetPaths": [
        "toolset.json"
      ],
      "sdkRootPath": "musl-${musl_version}.sdk/${arch}",
      "swiftResourcesPath": "musl-${musl_version}.sdk/${arch}/usr/lib/swift_static",
      "swiftStaticResourcesPath": "musl-${musl_version}.sdk/${arch}/usr/lib/swift_static"
EOF
done

cat >> swift-sdk.json <<EOF
    }
  }
}
EOF

mkdir "musl-${musl_version}.sdk"
quiet_pushd "musl-${musl_version}.sdk"
cp -R ${build_dir}/sdk_root/* .
quiet_popd

mkdir -p swift.xctoolchain/usr/bin

cat > toolset.json <<EOF
{
  "rootPath": "swift.xctoolchain/usr/bin",
  "swiftCompiler" : {
    "extraCLIOptions" : [
      "-static-executable",
      "-static-stdlib"
    ]
  },
  "schemaVersion": "1.0"
}
EOF

quiet_popd

header "Outputting compressed bundle"

quiet_pushd "${build_dir}"
mkdir -p "${products_dir}"
tar cvzf "${products_dir}/${bundle}.tar.gz" "${bundle}"
quiet_popd
