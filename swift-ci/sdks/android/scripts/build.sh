#!/bin/bash
# Swift SDK for Android: Build Script
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
usage: build.sh --source-dir <path> --products-dir <path> --ndk-home <path>
                [--name <sdk-name>] [--version <version>] [--build-dir <path>]
                [--archs <arch>[,<arch> ...]]

Build the Swift Android SDK.

Options:

  --name <sdk-name>     Specify the name of the SDK bundle.
  --version <version>   Specify the version of the Android SDK.
  --source-dir <path>   Specify the path in which the sources can be found.
  --ndk-home <path>     Specify the path to the Android NDK
  --host-toolchain <tc> Specify the path to the host Swift toolchain
  --build-compiler <bc> Whether to build and validate the host compiler
  --products-dir <path> Specify the path in which the products should be written.
  --build-dir <path>    Specify the path in which intermediates should be stored.
  --android-api <api>   Specify the Android API level
                        (Default is ${android_api}).
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

declare_package android_sdk \
                "Swift SDK for Android" \
                "Apache-2.0" "https://swift.org/install"
declare_package swift "swift" "Apache-2.0" "https://swift.org"
declare_package libxml2 "libxml2" "MIT" \
                "https://github.com/GNOME/libxml2"
declare_package curl "curl" "MIT" "https://curl.se"
declare_package boringssl "boringssl" "OpenSSL AND ISC AND MIT" \
                "https://boringssl.googlesource.com/boringssl/"

# Parse command line arguments
android_sdk_version=0.1
sdk_name=
archs=aarch64,armv7,x86_64
android_api=28
build_type=Release
parallel_jobs=$(($(nproc --all) + 2))
source_dir=
ndk_home=${ANDROID_NDK}
build_dir=$(pwd)/build
products_dir=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --source-dir)
            source_dir="$2"; shift ;;
        --ndk-home)
            ndk_home="$2"; shift ;;
        --host-toolchain)
            host_toolchain="$2"; shift ;;
        --build-compiler)
            build_compiler="$2"; shift ;;
        --build-dir)
            build_dir="$2"; shift ;;
        --android-api)
            android_api="$2"; shift ;;
        --products-dir)
            products_dir="$2"; shift ;;
        --name)
            sdk_name="$2"; shift ;;
        --archs)
            archs="$2"; shift ;;
        --build)
            build_type="$2"; shift ;;
        --version)
            android_sdk_version="$2"; shift ;;
        -j|--jobs)
            parallel_jobs=$2; shift ;;
        *)
            echo "Unknown argument '$1'"; usage; exit 0 ;;
    esac
    shift
done

# Change the commas for spaces
archs="${archs//,/ }"

if [[ -z "$source_dir" || -z "$products_dir" || -z "$ndk_home" ]]; then
    usage
    exit 1
fi

if ! swiftc=$(which swiftc); then
    echo "build.sh: Unable to find Swift compiler.  You must have a Swift toolchain installed to build the Android SDK."
    exit 1
fi

# Find the version numbers of the various dependencies
function describe {
    pushd $1 >/dev/null 2>&1
    # this is needed for docker containers or else we get the error:
    # fatal: detected dubious ownership in repository at '/source/curl'
    if [[ "${SWIFT_BUILD_DOCKER}" == "1" ]]; then
        git config --global --add safe.directory $(pwd)
    fi
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

swift_source_dir=${source_dir}/swift-project

swift_version=$(describe ${swift_source_dir}/swift)
swift_tag_date=$(git -C ${swift_source_dir}/swift log -1 --format=%ct 2>/dev/null)

if [[ $swift_version == swift-* ]]; then
    swift_version=${swift_version#swift-}
fi

if [[ -z "$sdk_name" ]]; then
    sdk_name=swift-${swift_version}-android-${android_sdk_version}
fi

libxml2_version=$(versionFromTag ${swift_source_dir}/libxml2)

curl_desc=$(describe ${swift_source_dir}/curl | tr '_' '.')
curl_version=${curl_desc#curl-}

boringssl_version=$(describe ${source_dir}/boringssl)

function quiet_pushd {
    pushd "$1" >/dev/null 2>&1
}
function quiet_popd {
    popd >/dev/null 2>&1
}

header "Swift Android SDK build script"

swift_dir=$(realpath $(dirname "$swiftc")/..)
HOST=linux-x86_64
# The Linux NDK only supports x86
#HOST=$(uname -s -m | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# in a Docker container, the pre-installed NDK is read-only,
# but the build script needs to write to it to work around
# https://github.com/swiftlang/swift-driver/pull/1822
# so we copy it to a read-write location for the purposes of the build
# this can all be removed once that PR lands
mkdir -p ${build_dir}/ndk/
ndk_home_tmp=${build_dir}/ndk/$(basename $ndk_home)
cp -a $ndk_home $ndk_home_tmp
ndk_home=$ndk_home_tmp

ndk_installation=$ndk_home/toolchains/llvm/prebuilt/$HOST

# ANDROID_NDK env needed by the swift-android.patch for:
# call ln -sf "${SWIFT_BUILD_PATH}/lib/swift" "${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib"
export ANDROID_NDK_HOME=$ndk_home
export ANDROID_NDK=$ndk_home

echo "Swift found at ${swift_dir}"
if [[ ! -z "${host_toolchain}" ]]; then
    echo "Host toolchain found at ${host_toolchain}"
    ${host_toolchain}/bin/swift --version
fi
echo "Android NDK found at ${ndk_home}"
${ndk_installation}/bin/clang --version
echo "Building for ${archs}"
echo "Sources are in ${source_dir}"
echo "Build will happen in ${build_dir}"
echo "Products will be placed in ${products_dir}"
echo
echo "Building from:"
echo "  - Swift ${swift_version}"
echo "  - libxml2 ${libxml2_version}"
echo "  - curl ${curl_version}"
echo "  - BoringSSL ${boringssl_version}"

# make sure the products_dir is writeable
ls -lad $products_dir
touch $products_dir/products_dir_write_test.tmp
rm $products_dir/products_dir_write_test.tmp
#chown -R $(id -u):$(id -g) $products_dir

function run() {
    echo "$@"
    "$@"
}

for arch in $archs; do
    case $arch in
        armv7)
            target_host="arm-linux-androideabi"
            compiler_target_host="armv7a-linux-androideabi$android_api"
            android_abi="armeabi-v7a"
            ;;
        aarch64)
            target_host="aarch64-linux-android"
            compiler_target_host="$target_host$android_api"
            android_abi="arm64-v8a"
            ;;
        x86_64)
            target_host="x86_64-linux-android"
            compiler_target_host="$target_host$android_api"
            android_abi="x86_64"
            ;;
        x86)
            target_host="x86-linux-android"
            compiler_target_host="$target_host$android_api"
            android_abi="x86"
            ;;
        *)
            echo "Unknown architecture '$1'"
            usage
            exit 0
            ;;
    esac

    sdk_root=${build_dir}/sdk_root/${arch}
    mkdir -p "$sdk_root"

    groupstart "Building libxml2 for $arch"
    quiet_pushd ${swift_source_dir}/libxml2
        run cmake \
            -G Ninja \
            -S ${swift_source_dir}/libxml2 \
            -B ${build_dir}/$arch/libxml2 \
            -DANDROID_ABI=$android_abi \
            -DANDROID_PLATFORM=android-$android_api \
            -DCMAKE_TOOLCHAIN_FILE=$ndk_home/build/cmake/android.toolchain.cmake \
            -DCMAKE_BUILD_TYPE=$build_type \
            -DCMAKE_EXTRA_LINK_FLAGS="-rtlib=compiler-rt -unwindlib=libunwind -stdlib=libc++ -fuse-ld=lld -lc++ -lc++abi -Wl,-z,max-page-size=16384" \
            -DCMAKE_BUILD_TYPE=$build_type \
            -DCMAKE_INSTALL_PREFIX=$sdk_root/usr \
            -DLIBXML2_WITH_PYTHON=NO \
            -DLIBXML2_WITH_ICU=NO \
            -DLIBXML2_WITH_ICONV=NO \
            -DLIBXML2_WITH_LZMA=NO \
            -DBUILD_SHARED_LIBS=OFF \
            -DBUILD_STATIC_LIBS=ON

        quiet_pushd ${build_dir}/$arch/libxml2
            run ninja -j$parallel_jobs
        quiet_popd

        header "Installing libxml2 for $arch"
        quiet_pushd ${build_dir}/$arch/libxml2
            run ninja -j$parallel_jobs install
        quiet_popd
    quiet_popd
    groupend

    groupstart "Building boringssl for ${compiler_target_host}"
    quiet_pushd ${source_dir}/boringssl
        run cmake \
            -GNinja \
            -B ${build_dir}/$arch/boringssl \
            -DANDROID_ABI=$android_abi \
            -DANDROID_PLATFORM=android-$android_api \
            -DCMAKE_TOOLCHAIN_FILE=$ndk_home/build/cmake/android.toolchain.cmake \
            -DCMAKE_BUILD_TYPE=$build_type \
            -DCMAKE_INSTALL_PREFIX=$sdk_root/usr \
            -DCMAKE_EXTRA_LINK_FLAGS="-Wl,-z,max-page-size=16384" \
            -DBUILD_SHARED_LIBS=OFF \
            -DBUILD_STATIC_LIBS=ON \
            -DBUILD_TESTING=OFF

        quiet_pushd ${build_dir}/$arch/boringssl
            run ninja -j$parallel_jobs
        quiet_popd

        header "Installing BoringSSL for $arch"
        quiet_pushd ${build_dir}/$arch/boringssl
            run ninja -j$parallel_jobs install
        quiet_popd
    quiet_popd
    groupend

    groupstart "Building libcurl for ${compiler_target_host}"
    quiet_pushd ${swift_source_dir}/curl
        run cmake \
            -G Ninja \
            -S ${swift_source_dir}/curl \
            -B ${build_dir}/$arch/curl \
            -DANDROID_ABI=$android_abi \
            -DANDROID_PLATFORM=android-$android_api \
            -DCMAKE_TOOLCHAIN_FILE=$ndk_home/build/cmake/android.toolchain.cmake \
            -DCMAKE_BUILD_TYPE=$build_type \
            -DCMAKE_INSTALL_PREFIX=$sdk_root/usr \
            -DCMAKE_EXTRA_LINK_FLAGS="-Wl,-z,max-page-size=16384" \
            -DOPENSSL_ROOT_DIR=$sdk_root/usr \
            -DOPENSSL_INCLUDE_DIR=$sdk_root/usr/include \
            -DOPENSSL_SSL_LIBRARY=$sdk_root/usr/lib/libssl.a \
            -DOPENSSL_CRYPTO_LIBRARY=$sdk_root/usr/lib/libcrypto.a \
            -DCURLSSLOPT_NATIVE_CA=ON \
            -DCURL_USE_OPENSSL=ON \
            -DCURL_USE_LIBSSH2=OFF \
            -DCURL_USE_LIBPSL=OFF \
            -DTHREADS_PREFER_PTHREAD_FLAG=OFF \
            -DCMAKE_THREAD_PREFER_PTHREAD=OFF \
            -DCMAKE_THREADS_PREFER_PTHREAD_FLAG=OFF \
            -DCMAKE_HAVE_LIBC_PTHREAD=YES \
            -DBUILD_CURL_EXE=NO \
            -DBUILD_SHARED_LIBS=OFF \
            -DBUILD_STATIC_LIBS=ON \
            -DCURL_BUILD_TESTS=OFF

        quiet_pushd ${build_dir}/$arch/curl
            run ninja -j$parallel_jobs
        quiet_popd

        header "Installing libcurl for $arch"
        quiet_pushd ${build_dir}/$arch/curl
            run ninja -j$parallel_jobs install
        quiet_popd
    quiet_popd
    groupend

    groupstart "Building Android SDK for ${compiler_target_host}"
    quiet_pushd ${swift_source_dir}
        build_type_flag="--debug"
        case $build_type in
            Debug) build_type_flag="--debug" ;;
            Release) build_type_flag="--release" ;;
            RelWithDebInfo) build_type_flag="--release-debuginfo" ;;
        esac

        case $build_compiler in
            1|true|yes|YES)
                build_cmark=""
                local_build=""
                build_llvm="1"
                build_swift_tools="1"
                validation_test="1"
                native_swift_tools_path=""
                native_clang_tools_path=""
                ;;
            *)
                build_cmark="--skip-build-cmark"
                local_build="--skip-local-build"
                build_llvm="0"
                build_swift_tools="0"
                validation_test="0"
                native_swift_tools_path="--native-swift-tools-path=$host_toolchain/bin"
                native_clang_tools_path="--native-clang-tools-path=$host_toolchain/bin"
                ;;
        esac

        # use an out-of-tree build folder
        export SWIFT_BUILD_ROOT=${build_dir}/swift-project

        ./swift/utils/build-script \
            $build_type_flag \
            --reconfigure \
            --no-assertions \
            --validation-test=$validation_test \
            --android \
            --android-ndk=$ndk_home \
            --android-arch=$arch \
            --android-api-level=$android_api \
            --cross-compile-hosts=android-$arch \
            --cross-compile-deps-path=$sdk_root \
            --install-destdir=$sdk_root \
            --build-llvm=$build_llvm \
            --build-swift-tools=$build_swift_tools \
            ${native_swift_tools_path} \
            ${native_clang_tools_path} \
            ${build_cmark} \
            ${local_build} \
            --host-test \
            --skip-test-linux \
            --skip-test-xctest --skip-test-foundation \
            --build-swift-static-stdlib \
            --swift-install-components='compiler;clang-resource-dir-symlink;license;stdlib;sdk-overlay' \
            --install-swift \
            --install-libdispatch \
            --install-foundation \
            --xctest --install-xctest \
            --swift-testing --install-swift-testing \
            --cross-compile-build-swift-tools=0 \
            --llvm-ninja-targets-for-cross-compile-hosts=help \
            --libdispatch-cmake-options=-DCMAKE_SHARED_LINKER_FLAGS= \
            --foundation-cmake-options=-DCMAKE_SHARED_LINKER_FLAGS= \
            --cross-compile-append-host-target-to-destdir=False 
            # --extra-cmake-options='-DCMAKE_EXTRA_LINK_FLAGS="-Wl,-z,max-page-size=16384"'
        # need to remove symlink that gets created in the NDK to the previous arch's build
        # or else we get errors like:
        # error: could not find module '_Builtin_float' for target 'x86_64-unknown-linux-android'; found: aarch64-unknown-linux-android, at: /home/runner/work/_temp/swift-android-sdk/ndk/android-ndk-r27c/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/swift/android/_Builtin_float.swiftmodule
        rm -f $ndk_installation/sysroot/usr/lib/swift
    quiet_popd
    groupend
done

# Now generate the bundle
groupstart "Bundling SDK"

sdk_base=swift-android
sdk_staging="sdk_staging"

bundle="${sdk_name}.artifactbundle"

rm -rf ${build_dir}/$bundle
mkdir -p ${build_dir}/$bundle
quiet_pushd ${build_dir}/$bundle

# First the info.json, for SwiftPM
cat > info.json <<EOF
{
  "schemaVersion": "1.0",
  "artifacts": {
    "$sdk_name": {
      "variants": [
        {
          "path": "$sdk_base"
        }
      ],
      "version": "${android_sdk_version}",
      "type": "swiftSDK"
    }
  }
}
EOF

mkdir -p $sdk_base
quiet_pushd $sdk_base

cp -a ${build_dir}/sdk_root ${sdk_staging}

swift_res_root="swift-resources"
mkdir -p ${swift_res_root}

cat > $swift_res_root/SDKSettings.json <<EOF
{
  "DisplayName": "Swift Android SDK",
  "Version": "${android_sdk_version}",
  "VersionMap": {},
  "CanonicalName": "linux-android"
}
EOF

# Copy necessary headers and libraries from the toolchain and NDK clang resource directories
mkdir -p $swift_res_root/usr/lib/swift/clang/lib
cp -r $host_toolchain/lib/clang/*/include $swift_res_root/usr/lib/swift/clang

for arch in $archs; do
    quiet_pushd ${sdk_staging}/${arch}/usr
        rm -r bin
        rm -r include/*
        cp -r ${swift_source_dir}/swift/lib/ClangImporter/SwiftBridging/{module.modulemap,swift} include/

        arch_triple="$arch-linux-android"
        if [[ $arch == 'armv7' ]]; then
            arch_triple="arm-linux-androideabi"
        fi

        # need force rm in case linux is not present (when not running tests)
        rm -rf lib/swift{,_static}/{FrameworkABIBaseline,_InternalSwiftScan,_InternalSwiftStaticMirror,clang,embedded,host,linux,migrator}
        rm -rf lib/lib*.so
        mv lib/swift lib/swift-$arch
        ln -s ../swift/clang lib/swift-$arch/clang

        mv lib/swift_static lib/swift_static-$arch
        mv lib/lib*.a lib/swift_static-$arch/android

        ln -sv ../swift/clang lib/swift_static-$arch/clang

        # copy the clang libraries that we need to build for each architecture
        aarch=${arch/armv7/arm}
        mkdir -p lib/swift/clang/lib/linux/${aarch}

        # match clang version 21, 22, etc.
        cp -av ${ndk_installation}/lib/clang/[0-9]*/lib/linux/libclang_rt.builtins-${aarch}-android.a lib/swift/clang/lib/linux/
        cp -av ${ndk_installation}/lib/clang/[0-9]*/lib/linux/${aarch}/libunwind.a lib/swift/clang/lib/linux/${aarch}/
    quiet_popd

    # now sync the massaged sdk_root into the swift_res_root
    rsync -a ${sdk_staging}/${arch}/usr ${swift_res_root}
done

rm -r ${swift_res_root}/usr/share/{doc,man}
rm -r ${sdk_staging}

# create an install script to set up the NDK links
#ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
mkdir scripts/

ndk_sysroot="ndk-sysroot"

cat > scripts/setup-android-sdk.sh <<'EOF'
#/bin/bash
# this script will setup the ndk-sysroot with links to the
# local installation indicated by ANDROID_NDK_HOME
set -e
if [ -z "${ANDROID_NDK_HOME}" ]; then
    echo "$(basename $0): error: missing environment variable ANDROID_NDK_HOME"
    exit 1
fi

ndk_prebuilt="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt"
if [ ! -d "${ndk_prebuilt}" ]; then
    echo "$(basename $0): error: ANDROID_NDK_HOME not found: ${ndk_prebuilt}"
    exit 1
fi

#Pkg.Revision = 27.0.12077973
#Pkg.Revision = 28.1.13356709
ndk_version=$(grep '^Pkg.Revision = ' "${ANDROID_NDK_HOME}/source.properties" | cut -f3- -d' ' | cut -f 1 -d '.')
if [[ "${ndk_version}" -lt 27 ]]; then
    echo "$(basename $0): error: minimum NDK version 27 required; found ${ndk_version} in ${ANDROID_NDK_HOME}/source.properties"
    exit 1
fi

cd $(dirname $(dirname $(realpath -- "${BASH_SOURCE[0]}")))
swift_resources=swift-resources
ndk_sysroot=ndk-sysroot

if [[ -d "${ndk_sysroot}" ]]; then
    # clear out any previous NDK setup
    rm -rf ${ndk_sysroot}
    ndk_re="re-"
fi

# link vs. copy the NDK files
SWIFT_ANDROID_NDK_LINK=${SWIFT_ANDROID_NDK_LINK:-1}
if [[ "${SWIFT_ANDROID_NDK_LINK}" == 1 ]]; then
    ndk_action="${ndk_re}linked"
    mkdir -p ${ndk_sysroot}/usr/lib
    ln -s ${ndk_prebuilt}/*/sysroot/usr/include ${ndk_sysroot}/usr/include
    for triplePath in ${ndk_prebuilt}/*/sysroot/usr/lib/*; do
        triple=$(basename ${triplePath})
        ln -s ${triplePath} ${ndk_sysroot}/usr/lib/${triple}
    done
else
    ndk_action="${ndk_re}copied"
    cp -a ${ndk_prebuilt}/*/sysroot ${ndk_sysroot}
fi

# copy each architecture's swiftrt.o into the sysroot,
# working around https://github.com/swiftlang/swift/pull/79621
for folder in swift swift_static; do
    for swiftrt in ${swift_resources}/usr/lib/${folder}-*/android/*/swiftrt.o; do
        arch=$(basename $(dirname ${swiftrt}))
        mkdir -p ${ndk_sysroot}/usr/lib/${folder}/android/${arch}
        if [[ "${SWIFT_ANDROID_NDK_LINK}" == 1 ]]; then
            ln -s ../../../../../../${swiftrt} ${ndk_sysroot}/usr/lib/${folder}/android/${arch}/
        else
            cp -a ${swiftrt} ${ndk_sysroot}/usr/lib/${folder}/android/${arch}/
        fi
    done
done

echo "$(basename $0): success: ndk-sysroot ${ndk_action} to Android NDK at ${ndk_prebuilt}"
EOF

chmod +x scripts/setup-android-sdk.sh

cat > swift-sdk.json <<EOF
{
  "schemaVersion": "4.0",
  "targetTriples": {
EOF

first=true
# create targets for the supported API and higher,
# as well as a blank API, which will be the NDK default
# FIXME: building against blank API doesn't work: ld.lld: error: cannot open crtbegin_dynamic.o: No such file or directory
#for api in "" $(eval echo "{$android_api..36}"); do
for api in $(eval echo "{$android_api..36}"); do
    for arch in $archs; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            cat >> swift-sdk.json <<EOF
    },
EOF
        fi

        SWIFT_RES_DIR="swift-${arch}"
        SWIFT_STATIC_RES_DIR="swift_static-${arch}"

        cat >> swift-sdk.json <<EOF
    "${arch}-unknown-linux-android${api}": {
      "sdkRootPath": "${ndk_sysroot}",
      "swiftResourcesPath": "${swift_res_root}/usr/lib/${SWIFT_RES_DIR}",
      "swiftStaticResourcesPath": "${swift_res_root}/usr/lib/${SWIFT_STATIC_RES_DIR}",
      "toolsetPaths": [ "swift-toolset.json" ]
EOF
      #"librarySearchPaths": [ "${swift_res_root}/usr/lib/swift-x86_64/android/x86_64" ],
      #"includeSearchPaths": [ "${ndk_sysroot}/usr/include" ],
    done
done

cat >> swift-sdk.json <<EOF
    }
  }
}
EOF

cat > swift-toolset.json <<EOF
{
  "cCompiler": { "extraCLIOptions": ["-fPIC"] },
  "swiftCompiler": { "extraCLIOptions": ["-Xclang-linker", "-fuse-ld=lld"] },
  "linker": { "extraCLIOptions": ["-z", "max-page-size=16384"] },
  "schemaVersion": "1.0"
}
EOF

quiet_popd

header "Outputting compressed bundle"

quiet_pushd "${build_dir}"
    mkdir -p "${products_dir}"
    # set the timestamps of every file in the artifact to the tag date for the swift repo for build reproducibility
    touch_date=$(date -d "@$swift_tag_date" "+%Y%m%d%H%M.%S")
    find "${bundle}" -exec touch -t "$touch_date" {} +

    bundle_archive="${products_dir}/${bundle}.tar.gz"
    tar czf "${bundle_archive}" "${bundle}"
    shasum -a 256 "${bundle_archive}"
quiet_popd

groupend
