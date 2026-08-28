#!/usr/bin/env bash
# Deploy this repo's packages and dotfiles to a fresh Arch Linux machine.
#
# Usage: ./scripts/bootstrap.sh
#
# Expects a running Arch Linux with network access and a user with sudo
# privileges. Safe to re-run: every step is idempotent.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

say()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }

say "Deploying packages and dotfiles from $REPO_DIR"
sudo -v

# 1. Official packages
say "Installing official packages"
# shellcheck disable=SC2046
sudo pacman -S --needed --noconfirm $(<"$REPO_DIR/pkglist.txt")

# 2. yay (AUR helper)
if ! command -v yay >/dev/null 2>&1; then
    say "Installing yay (AUR helper)"
    sudo pacman -S --needed --noconfirm base-devel
    yay_tmp="$(mktemp -d)"
    trap 'rm -rf "$yay_tmp"' RETURN
    git clone https://aur.archlinux.org/yay-bin.git "$yay_tmp/yay-bin"
    (cd "$yay_tmp/yay-bin" && makepkg -si --noconfirm)
fi

# 3. archlinuxcn repo (patched gtk2, some proprietary packages)
if ! grep -q '^\[archlinuxcn\]' /etc/pacman.conf; then
    say "Enabling the archlinuxcn repository"
    # shellcheck disable=SC2016  # $arch is expanded by pacman, not the shell
    printf '\n[archlinuxcn]\nServer = https://repo.archlinuxcn.org/$arch\n' \
        | sudo tee -a /etc/pacman.conf > /dev/null
    sudo pacman -Sy
    sudo pacman -S --needed --noconfirm archlinuxcn-keyring
fi

say "Installing archlinuxcn packages"
if [ -s "$REPO_DIR/pkglist-cn.txt" ]; then
    # shellcheck disable=SC2046
    sudo pacman -S --needed --noconfirm $(<"$REPO_DIR/pkglist-cn.txt")
fi

# 4. AUR packages
say "Installing AUR packages"
# shellcheck disable=SC2046
yay -S --needed --noconfirm $(<"$REPO_DIR/pkglist-aur.txt")

# 5. Dotfiles
say "Linking dotfiles with stow"
# shellcheck disable=SC2035  # package names come from this fixed directory
(cd user && stow -t "$HOME" -R */)

# Root configs (greetd) — stow target is /, hence sudo
say "Stowing root configs"
# shellcheck disable=SC2035  # package names come from this fixed directory
(cd root && sudo stow -t / -R */)
# The greeter user must traverse $HOME to read the symlinked
# /etc/tuigreet/config.toml.
setfacl -m "u:greeter:--x" "$HOME" 2>/dev/null || true

# 6. Emacs config (lives in its own repo, not stowed)
say "Cloning emacs config"
if [ -e "$HOME/.emacs.d/.git" ]; then
    say "$HOME/.emacs.d already present — leaving it alone"
else
    git clone --recurse-submodules https://github.com/higuoxing/.emacs.d \
        "$HOME/.emacs.d"
fi

# 7. System services (mirrors this laptop's setup)
if [ -d /run/systemd/system ]; then
    say "Enabling system services"
    sudo systemctl enable --now NetworkManager.service bluetooth.service \
         cronie.service docker.service
else
    say "No systemd running (container?) — skipping service setup"
fi

say "Done."
cat <<'NOTES'

Notes for the new machine:
  - Display scale is per-machine; edit
      user/sway/.config/sway/config.d/10-output.conf
    and find the output name with: swaymsg -t get_outputs
    (touchpad settings match any touchpad automatically)
  - If this machine should not run cronie/docker, disable them and drop
    them from pkglist.txt (see scripts/update-pkgs.sh).
  - Log out and back in (or reboot) to start sway.
NOTES
