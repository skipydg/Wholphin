#!/bin/bash
# sync.sh — Pull latest Wholphin updates and rebase DV changes on top
set -e

# Add upstream remote if it doesn't exist
if ! git remote | grep -q upstream; then
  echo "Adding upstream remote..."
  git remote add upstream https://github.com/damontecres/wholphin.git
fi

echo "Fetching latest from upstream Wholphin..."
git fetch upstream

echo "Updating main to match upstream..."
git checkout main
git merge --ff-only upstream/main

echo "Rebasing DV compat changes on top..."
git checkout dv-compat
git rebase main

echo "Pushing to GitHub..."
git push origin main
git push --force-with-lease origin dv-compat

echo "Done! Your DV changes are now on top of the latest Wholphin."

# Fetch MPV native libs from the latest upstream release if missing
ARM64="app/src/main/jniLibs/arm64-v8a/libmpv.so"
if [ ! -f "$ARM64" ]; then
  echo ""
  echo "MPV native libs not found. Fetching from latest upstream release..."
  LATEST_TAG=$(gh release view --repo damontecres/Wholphin --json tagName -q '.tagName')
  echo "Upstream release: $LATEST_TAG"

  mkdir -p /tmp/wholphin-native-libs

  echo "Downloading arm64-v8a APK..."
  curl -L -o /tmp/wholphin-native-libs/arm64.apk \
    "https://github.com/damontecres/Wholphin/releases/download/${LATEST_TAG}/Wholphin-arm64-v8a.apk"
  mkdir -p app/src/main/jniLibs/arm64-v8a
  unzip -o /tmp/wholphin-native-libs/arm64.apk "lib/arm64-v8a/*.so" -d /tmp/wholphin-native-libs/arm64
  cp /tmp/wholphin-native-libs/arm64/lib/arm64-v8a/*.so app/src/main/jniLibs/arm64-v8a/

  echo "Downloading armeabi-v7a APK..."
  curl -L -o /tmp/wholphin-native-libs/v7a.apk \
    "https://github.com/damontecres/Wholphin/releases/download/${LATEST_TAG}/Wholphin-armeabi-v7a.apk"
  mkdir -p app/src/main/jniLibs/armeabi-v7a
  unzip -o /tmp/wholphin-native-libs/v7a.apk "lib/armeabi-v7a/*.so" -d /tmp/wholphin-native-libs/v7a
  cp /tmp/wholphin-native-libs/v7a/lib/armeabi-v7a/*.so app/src/main/jniLibs/armeabi-v7a/

  rm -rf /tmp/wholphin-native-libs
  echo "MPV native libs installed."
else
  echo "MPV native libs already present, skipping download."
fi
