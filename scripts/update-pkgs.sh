#!/usr/bin/env bash
# Regenerate the package lists from this machine's explicitly installed
# packages. Run after intentionally installing or removing packages,
# review the diff, and commit.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pacman -Qqen > "$REPO_DIR/pkglist.txt"
pacman -Qqem > "$REPO_DIR/pkglist-aur.txt"

echo "Wrote pkglist.txt      ($(wc -l < "$REPO_DIR/pkglist.txt") official packages)"
echo "Wrote pkglist-aur.txt  ($(wc -l < "$REPO_DIR/pkglist-aur.txt") AUR/foreign packages)"
