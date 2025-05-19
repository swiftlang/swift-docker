#!/bin/bash
# Swift Android SDK: Patch Sources
set -e

source_dir=$1
if [[ ! -d "${source_dir}" ]]; then
    echo "$0: source_dir ${source_dir} does not exist"
    exit 1
fi

patches_dir="${source_dir}/swift-android-patches"
if [[ ! -d "${patches_dir}" ]]; then
    echo "$0: patches_dir ${patches_dir} does not exist"
    exit 1
fi

cd ${source_dir}/swift-project
swift_android_patch="${patches_dir}/swift-android.patch"

# patch the patch, which seems to only be needed for an API less than 28
# https://github.com/finagolfin/swift-android-sdk/blob/main/swift-android.patch#L110
perl -pi -e 's/#if os\(Windows\)/#if os\(Android\)/g' $swift_android_patch

# remove the need to link in android-execinfo
perl -pi -e 's;dispatch android-execinfo;dispatch;g' $swift_android_patch

# debug symbolic link setup
perl -pi -e 's;call ln -sf;call ln -svf;g' $swift_android_patch
perl -pi -e 's%linux-x86_64/sysroot/usr/lib"%linux-x86_64/sysroot/usr/lib"; echo "VALIDATING SYMBOLIC LINK"; ls -la "\${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib"; ls -la "\${ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/swift"; %g' $swift_android_patch

case "${BUILD_SCHEME}" in
    release)
        testing_patch="${patches_dir}/swift-android-testing-release.patch"
        ;;
    swift-*-branch)
        testing_patch="${patches_dir}/swift-android-testing-except-release.patch"
        ;;
    development)
        testing_patch="${patches_dir}/swift-android-testing-except-release.patch"
        dispatch_patch="${patches_dir}/swift-android-trunk-libdispatch.patch"
        ;;
    *)
        echo "$0: invalid BUILD_SCHEME=${BUILD_SCHEME}"
        exit 1
        ;;
esac

for patch in "$swift_android_patch" "$testing_patch" "$dispatch_patch"; do
    if [[ "${patch}" == "" ]]; then
        continue
    fi

    echo "applying patch $patch in $PWD…"
    # first check to make sure the patches can apply and fail if not
    git apply -v --check -C1 "$patch"
    git apply --no-index -v -C1 "$patch"

    #if git apply -C1 --reverse --check "$patch" >/dev/null 2>&1 ; then
    #    echo "already patched"
    #elif git apply -C1 "$patch" ; then
    #    echo "done"
    #else
    #    echo "failed to apply patch $patch in $PWD"
    #    exit 1
    #fi
done

perl -pi -e 's%String\(cString: getpass%\"fake\" //%' swiftpm/Sources/PackageRegistryCommand/PackageRegistryCommand+Auth.swift
# disable backtrace() for Android (needs either API33+ or libandroid-execinfo, or to manually add in backtrace backport)
perl -pi -e 's;os\(Android\);os\(AndroidDISABLED\);g' swift-testing/Sources/Testing/SourceAttribution/Backtrace.swift

# need to un-apply libandroid-spawn since we don't need it for API28+
perl -pi -e 's;MATCHES "Android";MATCHES "AndroidDISABLED";g' llbuild/lib/llvm/Support/CMakeLists.txt
perl -pi -e 's; STREQUAL Android\); STREQUAL AndroidDISABLED\);g' swift-corelibs-foundation/Sources/Foundation/CMakeLists.txt

# validate the patches
ls -la swift/utils/build-script-impl
grep 'VALIDATING SYMBOLIC LINK' swift/utils/build-script-impl

