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
| pulseaudio-ctl | `~/.config/pulseaudio-ctl` |

## Usage

Install stow: `pacman -S stow`

1. Clone with submodules:

   ```
   git clone --recurse-submodules <url> ~/dotfiles
   cd ~/dotfiles
   ```

2. Stow a single package:

   ```
   stow sway
   ```

   or all of them at once:

   ```
   stow */
   ```

   - `stow -n sway` — dry run, show what would be linked
   - `stow -R sway` — restow after pulling updates
   - `stow -D sway` — remove a package's links
   - `stow --adopt sway` — replace existing real files in `$HOME` by moving them into the repo and linking; review with `git diff` afterwards
