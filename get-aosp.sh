#!/bin/bash

SYNC_JOBS=4

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            echo "Usage:"
            echo "    $0 [-h|--help] [-u|--git-user <GIT_USERNAME>] [-e|--git-email <GIT_EMAIL>] [-j|--sync-jobs <SYNC_JOBS>]"
            echo
            echo "    -h|--help                         Prints this help"
            echo "    -u|--git-user <GIT_USERNAME>      Sets the global Git username"
            echo "    -e|--git-email <GIT_EMAIL>        Sets the global Git email"
            echo "    -j|--sync-jobs <SYNC_JOBS>        Simultaneous syncing jobs (repo)"
            echo "                                      Default is 4 (four)"
            echo
            exit 0
            ;;
        -u|--git-user)
            GIT_USERNAME="$2"
            echo "Setting Git user.name as $GIT_USERNAME"
            git config --global user.name "$GIT_USERNAME"
            shift # Consume param
            shift # Consume value
            ;;
        -e|--git-email)
            GIT_EMAIL="$2"
            echo "Setting Git user.email as $GIT_EMAIL"
            git config --global user.email "$GIT_EMAIL"
            shift # Consume param
            shift # Consume value
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

# Check if git user.name is set globally
GIT_USERNAME=$(git config --global user.name)
if [ -z "$GIT_USERNAME" ]; then
    echo "Git user.name is not set."
    read -p "Please enter your Git username (ENTER to abort): " GIT_USERNAME

    if [ -n "$GIT_USERNAME" ]; then
        git config --global user.name "$GIT_USERNAME"
    else
        echo "No username entered. Abort." && exit 1
    fi
fi

# The same for git user.email
GIT_EMAIL=$(git config --global user.email)
if [ -z "$GIT_EMAIL" ]; then
    echo "Git user.email is not set."
    read -p "Please enter your Git email (ENTER to abort): " GIT_EMAIL

    if [ -n "$GIT_EMAIL" ]; then
        git config --global user.email "$GIT_EMAIL"
    else
        echo "No email entered. Abort." && exit 1
    fi
fi

# Pre-accept repy diff coloring
git config --global color.ui true

echo "Initializing AOSP repo's latest release" 
repo init --partial-clone -b android-latest-release -u https://android.googlesource.com/platform/manifest --depth=1 || exit 2

echo "Acquiring AOSP"
repo sync -c -j${SYNC_JOBS} --no-manifest-update --fail-fast || exit 3
