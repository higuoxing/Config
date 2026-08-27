#!/usr/bin/env bash
# Regenerate the package lists from this machine's explicitly installed
# packages, split by source:
#   pkglist.txt     - official repositories (core/extra)
#   pkglist-cn.txt  - the archlinuxcn repository
#   pkglist-aur.txt - AUR and other foreign packages
# Run after intentionally installing or removing packages, review the
# diff, and commit.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

explicit="$(pacman -Qqen | sort)"
foreign="$(pacman -Qqem | sort)"

if pacman -Slq archlinuxcn >/dev/null 2>&1; then
    cn="$(pacman -Slq archlinuxcn | sort)"
else
    cn=""
fi

comm -23 <(echo "$explicit") <(echo "$cn") > "$REPO_DIR/pkglist.txt"
comm -12 <(echo "$explicit") <(echo "$cn") > "$REPO_DIR/pkglist-cn.txt"
echo "$foreign" > "$REPO_DIR/pkglist-aur.txt"

echo "Wrote pkglist.txt     ($(wc -l < "$REPO_DIR/pkglist.txt") official packages)"
echo "Wrote pkglist-cn.txt  ($(wc -l < "$REPO_DIR/pkglist-cn.txt") archlinuxcn packages)"
echo "Wrote pkglist-aur.txt ($(wc -l < "$REPO_DIR/pkglist-aur.txt") AUR/foreign packages)"
