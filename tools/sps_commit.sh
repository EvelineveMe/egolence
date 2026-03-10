#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "Usage: sps_commit.sh \"commit message\""
  exit 1
fi

# Detect any change including untracked
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit. Aborting."
  exit 1
fi

MSG="$1"

git add -A

git commit -m "$MSG"

echo "--- RECEIPT ---"
git log -1 --oneline
