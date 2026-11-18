# dotfiles

My shell, terminal and desktop configs (zsh + oh-my-zsh, starship, tmux,
alacritty, i3, Cinnamon), plus scripts to install them on a fresh Ubuntu /
Linux Mint machine.

## Quick start

```sh
git clone --recurse-submodules https://github.com/afonsus1997/dotfiles
cd dotfiles
./install_shell.sh
```

Then log out and back in (or run `exec zsh`).

`install_shell.sh` is safe to re-run: things already installed are skipped and
any config it overwrites is backed up to `~/.dotfiles_backup/<timestamp>/`.

## What's in here

| Path | What it is |
| --- | --- |
| `home/` | Files that get copied into `$HOME` (`.zshrc`, `.tmux.conf`, `.wezterm.lua`, `.config/…`, the `AM` oh-my-zsh theme) |
| `cinnamon/` | Cinnamon settings (`cinnamon.dconf`) and the list of applets/extensions/themes to download (`spices.txt`) |
| `install_shell.sh` | Main installer for the shell/terminal setup (see below) |
| `install_cinnamon.sh` | Restores the Cinnamon desktop setup |
| `install_configs.sh` | Older script: copies **everything** in `home/` into `$HOME` (including i3 configs) and installs oh-my-zsh + starship |
| `install_utilities_ubuntu.sh` | Extra desktop utilities (flameshot, ranger, i3blocks, …) |
| `backup_dotfiles.sh` | Copies `~/.zshrc`, `~/.tmux.conf`, `~/.wezterm.lua` back into the repo |
| `backup_cinnamon.sh` | Exports the current Cinnamon settings into the repo |

## Install scripts

### Shell & terminal — `install_shell.sh`

Installs and configures:

- **Packages (apt):** zsh, git, curl, tmux, xclip, fzf, bat, zsh-syntax-highlighting, zoxide, lsd
- **oh-my-zsh** (unattended), with the `AM` theme from this repo
- **zsh plugins:** zsh-autosuggestions (`~/.oh-my-zsh/custom/plugins/`) and
  zsh-autocomplete (`~/.oh-my-zsh/others/`)
- **`~/.zshrc`** from this repo
- **starship** prompt + `~/.config/starship.toml`
- **tmux** config + TPM and its plugins (prefix is `Ctrl+k`)
- **alacritty** + Hack Nerd Font + alacritty-theme
- Sets zsh as your default shell

Needs `sudo`. It works over SSH on headless machines too; the alacritty/font
steps are harmless there.

### Cinnamon desktop — `install_cinnamon.sh`

Only on a machine running Cinnamon. Installs the icon/cursor themes, downloads
the spices listed in `cinnamon/spices.txt`, copies applet settings and loads
`cinnamon/cinnamon.dconf`. Your current settings are backed up first; to undo:

```sh
dconf load /org/cinnamon/ < ~/.dotfiles_backup/<timestamp>/cinnamon.dconf
```

Restart Cinnamon afterwards (`Ctrl+Alt+Esc`) or log out and back in.

### Extra utilities — `install_utilities_ubuntu.sh`

```sh
bash install_utilities_ubuntu.sh
```

### i3

`install_shell.sh` doesn't touch i3. To install the i3 configs, copy
`home/.config/i3/` into `~/.config/` (or run `install_configs.sh`, which copies
all of `home/`). Also install:

- [i3blocks-mpris](https://github.com/un-def/i3blocks-mpris)
- [i3-workspace-groups](https://github.com/infokiller/i3-workspace-groups)

`i3blocks-contrib` is a git submodule. If you cloned without
`--recurse-submodules`, run `git submodule update --init`.

> **Order matters:** if you use `install_configs.sh`, run it **after**
> `install_shell.sh`, or let it install oh-my-zsh first. Copying `home/` into
> `$HOME` creates a `~/.oh-my-zsh/` folder that holds only the theme, and that
> blocks the oh-my-zsh installer.

## Saving changes back to the repo

```sh
./backup_dotfiles.sh     # zshrc, tmux, wezterm
./backup_cinnamon.sh     # Cinnamon settings + spices list
git add -A && git commit -m "Update configs"
```

## Troubleshooting

**`no such file or directory: ~/.oh-my-zsh/oh-my-zsh.sh`.** `~/.oh-my-zsh`
exists but oh-my-zsh was never installed into it. Re-run `./install_shell.sh`:
it moves the incomplete folder to `~/.dotfiles_backup/` and installs it fresh.

**`.../zsh-autocomplete.plugin.zsh: no such file` or `theme 'AM' not found`.**
The plugins/theme are missing from `~/.oh-my-zsh`. Re-run `./install_shell.sh`.

**`xset: unable to open display ""` over SSH.** This comes from an older
`.zshrc`. The current one only runs `xset` when `$DISPLAY` is set. Re-run
`./install_shell.sh` to pick it up.

**Machine-specific bits in `.zshrc`.** Some aliases and `PATH` entries point
at tools that only exist on my main machine (Vivado, Libero, `/media/Dados/…`,
`athena_login`). They're harmless elsewhere but won't work.
