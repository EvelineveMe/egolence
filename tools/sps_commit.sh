#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "Usage: sps_commit.sh \"commit message\""
  exit 1
fi

if git diff --quiet && git diff --cached --quiet; then
  echo "No changes to commit. Aborting."
  exit 1
fi

MSG="$1"

git add -A
git commit -m "$MSG"

echo "--- RECEIPT ---"
git log -1 --oneline
