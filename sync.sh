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
