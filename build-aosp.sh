#!/bin/bash

SYNC_JOBS=4

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Usage:"
            echo "    $0 [-h|--help] [-j|--sync-jobs <SYNC_JOBS>]"
            echo
            echo "    -h|--help                         Prints this help"
            echo "    -j|--sync-jobs <SYNC_JOBS>        Simultaneous syncing jobs (repo)"
            echo "                                      Default is 4 (four)"
            echo
            exit 0
            ;;
        -j|--sync-jobs)
            SYNC_JOBS="$2"
            echo "Repo sync jobs set to $SYNC_JOBS"
            shift # Consume param
            shift # Consume value
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 99
            ;;
    esac
done

if [[ -z "$__BUILD_SETUP__" ]]; then
    echo "Setting up the build environment"
    source build/envsetup.sh || exit 1

    echo "$ lunch aosp_cf_x86_64_only_phone-aosp_current-userdebug"
    lunch aosp_cf_x86_64_only_phone-aosp_current-userdebug || exit 2

    export __BUILD_SETUP__=1
fi

# Function to be executed as the "finally" block
cleanup_function() {
    echo "Restauring unprivileged user namespaces"
    echo sysctl -w kernel.apparmor_restrict_unprivileged_unconfined=1
    sysctl -w kernel.apparmor_restrict_unprivileged_unconfined=1
    echo sysctl -w kernel.apparmor_restrict_unprivileged_userns=1
    sysctl -w kernel.apparmor_restrict_unprivileged_userns=1
}

# Register the cleanup_function to be executed when the script exits
# regardless of whether it exits normally or due to an error.
trap cleanup_function EXIT

echo "Disabling unprivileged user namespaces during build (it happens on host!)"
echo sysctl -w kernel.apparmor_restrict_unprivileged_unconfined=0
sysctl -w kernel.apparmor_restrict_unprivileged_unconfined=0 || exit 3
echo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
sysctl -w kernel.apparmor_restrict_unprivileged_userns=0 || exit 3

echo "Building AOSP"
echo "$ m -j$SYNC_JOBS"
m -j${SYNC_JOBS} || exit 4
