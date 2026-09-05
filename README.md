# Laptop

my own dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/)

Each directory under `user/` is a stow package that expands into `$HOME`:

| Package | Expands to |
| --- | --- |
| sway | `~/.config/sway` |
| waybar | `~/.config/waybar` |
| anyrun | `~/.config/anyrun` |
| chrome | `~/.local/share/applications/google-chrome.desktop` (launches with `--ozone-platform=wayland`) |
| fcitx5 | `~/.config/fcitx5/config` and `conf/waylandim.conf` |
| tmux | `~/.tmux.conf` |
| npm | `~/.npmrc` |
| postgresql | `~/.psqlrc` |

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
