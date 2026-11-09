#!/usr/bin/env bash
# Restores the Cinnamon setup saved by backup_cinnamon.sh:
#   - installs the cursor/icon themes the settings use
#   - downloads the applets, extensions and themes listed in cinnamon/spices.txt
#   - copies applet/extension settings and loads cinnamon/cinnamon.dconf
# The current dconf settings are backed up first, so this can be undone with:
#   dconf load /org/cinnamon/ < ~/.dotfiles_backup/<timestamp>/cinnamon.dconf
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPICES_URL="https://cinnamon-spices.linuxmint.com/files"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

info() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!] %s\033[0m\n' "$*"; }

command -v cinnamon >/dev/null || { echo "Cinnamon isn't installed; aborting."; exit 1; }

############# PACKAGES #############
info "Installing packages (apt)"
sudo apt update
# yaru-theme-icon: icon theme; mint-cursor-themes: Bibata cursors.
# rofi: used by the custom keybindings.
sudo apt install -y curl unzip dconf-cli yaru-theme-icon rofi
sudo apt install -y mint-cursor-themes 2>/dev/null \
  || warn "mint-cursor-themes not available (not Linux Mint?); cursor theme won't be found"

############# SPICES #############
# Spices are zips with the uuid as top-level folder.
install_spice() {
  local type="$1" uuid="$2" dest tmp
  case "$type" in
    themes) dest="$HOME/.themes" ;;
    *)      dest="$HOME/.local/share/cinnamon/$type" ;;
  esac
  if [ -d "$dest/$uuid" ]; then
    echo "$type/$uuid already installed"
    return
  fi
  mkdir -p "$dest"
  tmp="$(mktemp -d)"
  if curl -fsSL -o "$tmp/spice.zip" "$SPICES_URL/$type/$uuid.zip"; then
    unzip -q "$tmp/spice.zip" -d "$dest"
    echo "Installed $type/$uuid"
  else
    warn "Could not download $type/$uuid"
  fi
  rm -rf "$tmp"
}

info "Installing applets, extensions and themes"
while read -r type uuid; do
  case "$type" in ''|\#*) continue ;; esac
  install_spice "$type" "$uuid"
done < "$DOTFILES/cinnamon/spices.txt"

############# SETTINGS #############
info "Copying applet/extension settings"
SPICES_CFG="$HOME/.config/cinnamon/spices"
if [ -d "$SPICES_CFG" ]; then
  mkdir -p "$BACKUP_DIR"
  cp -a "$SPICES_CFG" "$BACKUP_DIR/spices"
  warn "Backed up $SPICES_CFG -> $BACKUP_DIR/spices"
fi
mkdir -p "$SPICES_CFG"
cp -r "$DOTFILES/home/.config/cinnamon/spices/." "$SPICES_CFG/"

mkdir -p "$HOME/.icons/default"
cp "$DOTFILES/home/.icons/default/index.theme" "$HOME/.icons/default/"

info "Loading Cinnamon settings (dconf)"
mkdir -p "$BACKUP_DIR"
dconf dump /org/cinnamon/ > "$BACKUP_DIR/cinnamon.dconf"
warn "Backed up current settings -> $BACKUP_DIR/cinnamon.dconf"
dconf load /org/cinnamon/ < "$DOTFILES/cinnamon/cinnamon.dconf"

info "Done! Restart Cinnamon (Ctrl+Alt+Esc) or log out and back in to apply everything."
