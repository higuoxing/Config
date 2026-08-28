# Laptop

my own dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/)

Each directory under `user/` is a stow package that expands into `$HOME`:

| Package | Expands to |
| --- | --- |
| sway | `~/.config/sway` |
| waybar | `~/.config/waybar` |
| anyrun | `~/.config/anyrun` |
| tmux | `~/.tmux.conf` |
| npm | `~/.npmrc` |
| postgresql | `~/.psqlrc` |

The `root/greetd` package expands into `/` instead and is stowed as root;
it carries `/etc/greetd/config.toml` and `/etc/tuigreet/config.toml`.

## Usage

Install stow: `pacman -S stow`

1. Clone:

   ```
   git clone <url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Stow a single package:

   ```
   stow -d user -t ~ sway
   ```

   or all of them at once:

   ```
   stow -d user -t ~ */
   ```

   `-d user` points stow at the package directory, and `-t ~` sets
   the target. The explicit target is required unless the repo is cloned
   directly into `$HOME`: stow's default target is the parent directory
   of the repo, which links dotfiles into the wrong place anywhere else
   (e.g. a repo at `~/x/gh/Laptop`).

   - `stow -n -d user -t ~ sway` — dry run, show what would be linked
   - `stow -R -d user -t ~ sway` — restow after pulling updates
   - `stow -D -d user -t ~ sway` — remove a package's links
   - `stow --adopt -d user -t ~ sway` — replace existing real files in `$HOME` by moving them into the repo and linking; review with `git diff` afterwards
   - `sudo stow -d root -t / greetd` — root configs (greetd), stowed as root

## Deploying to a new laptop

On a fresh Arch Linux install, clone the repo and run:

   ```
   git clone <url> ~/x/gh/Laptop
   ~/x/gh/Laptop/scripts/bootstrap.sh
   ```

The script installs every package listed in `pkglist.txt` (official repos),
`pkglist-cn.txt` (archlinuxcn — the repo is enabled automatically), and
`pkglist-aur.txt` (AUR, via yay), stows all dotfiles (including the
greetd root configs), clones the emacs config from its own repo
(`github.com/higuoxing/.emacs.d`), and enables the system services this
laptop runs (NetworkManager, bluetooth, cronie, docker).

This pairs well with [archinstall](https://archinstall.readthedocs.io/):
pick the `minimal` profile (skip the desktop profiles — packages and
configs come from this repo), enter `git` at the "Additional packages"
prompt, then clone and run `scripts/bootstrap.sh` after the first boot.

After intentionally installing or removing packages on any machine, refresh
the lists and commit them:

   ```
   scripts/update-pkgs.sh
   ```
