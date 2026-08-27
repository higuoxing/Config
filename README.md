# Laptop

my own dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/)

Each directory is a stow package that expands into `$HOME`:

| Package | Expands to |
| --- | --- |
| sway | `~/.config/sway` |
| waybar | `~/.config/waybar` |
| anyrun | `~/.config/anyrun` |
| emacs | `~/.emacs.d` (submodule) |
| tmux | `~/.tmux.conf` |
| npm | `~/.npmrc` |
| postgresql | `~/.psqlrc` |

## Usage

Install stow: `pacman -S stow`

1. Clone with submodules:

   ```
   git clone --recurse-submodules <url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Stow a single package:

   ```
   stow -t ~ sway
   ```

   or all of them at once:

   ```
   stow -t ~ */
   ```

   The `-t ~` target is required unless the repo is cloned directly into
   `$HOME`: stow's default target is the parent directory of the repo,
   which links dotfiles into the wrong place anywhere else (e.g. a repo
   at `~/x/gh/Laptop`).

   - `stow -n -t ~ sway` — dry run, show what would be linked
   - `stow -R -t ~ sway` — restow after pulling updates
   - `stow -D -t ~ sway` — remove a package's links
   - `stow --adopt -t ~ sway` — replace existing real files in `$HOME` by moving them into the repo and linking; review with `git diff` afterwards

## Deploying to a new laptop

On a fresh Arch Linux install, clone the repo and run:

   ```
   git clone --recurse-submodules <url> ~/x/gh/Laptop
   ~/x/gh/Laptop/bootstrap.sh
   ```

The script installs every package listed in `pkglist.txt` (official repos)
and `pkglist-aur.txt` (AUR, via yay), stows all dotfiles, and enables the
system services this laptop runs (NetworkManager, bluetooth, cronie,
docker).

After intentionally installing or removing packages on any machine, refresh
the lists and commit them:

   ```
   scripts/update-pkgs.sh
   ```
