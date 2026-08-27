#!/usr/bin/env bash
# Deploy this repo's packages and dotfiles to a fresh Arch Linux machine.
#
# Usage: ./bootstrap.sh
#
# Expects a running Arch Linux with network access and a user with sudo
# privileges. Safe to re-run: every step is idempotent.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

say "Deploying packages and dotfiles from $REPO_DIR"
sudo -v

# 1. Official packages
say "Installing official packages"
sudo pacman -S --needed --noconfirm - < "$REPO_DIR/pkglist.txt"

# 2. AUR packages (via yay)
if ! command -v yay >/dev/null 2>&1; then
    say "Installing yay (AUR helper)"
    sudo pacman -S --needed --noconfirm base-devel
    yay_tmp="$(mktemp -d)"
    trap 'rm -rf "$yay_tmp"' RETURN
    git clone https://aur.archlinux.org/yay-bin.git "$yay_tmp/yay-bin"
    (cd "$yay_tmp/yay-bin" && makepkg -si --noconfirm)
fi

say "Installing AUR packages"
# Some entries come from the archlinuxcn repo; enable it in pacman.conf
# (https://www.archlinuxcn.org) if yay cannot find them.
yay -S --needed --noconfirm - < "$REPO_DIR/pkglist-aur.txt"

# 3. Dotfiles
say "Linking dotfiles with stow"
git submodule update --init
stow -t "$HOME" -R */

# 4. System services (mirrors this laptop's setup)
say "Enabling system services"
sudo systemctl enable --now NetworkManager.service bluetooth.service \
     cronie.service docker.service

say "Done."
cat <<'NOTES'

Notes for the new machine:
  - Hardware-specific sway settings live in sway/.config/sway/config:
      output eDP-1 scale 1.5        -> find yours: swaymsg -t get_outputs
      input "1739:52619:..."        -> find yours: swaymsg -t get_inputs
  - If this machine should not run cronie/docker, disable them and drop
    them from pkglist.txt (see scripts/update-pkgs.sh).
  - Log out and back in (or reboot) to start sway.
NOTES
