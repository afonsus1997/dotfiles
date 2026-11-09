#!/usr/bin/env bash
# Exports the current Cinnamon settings into this repo (run before committing).
#   cinnamon/cinnamon.dconf         - dconf dump of /org/cinnamon/
#   cinnamon/spices.txt             - installed applets/extensions + active themes
#   home/.config/cinnamon/spices/   - per-applet/extension settings (JSON)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$DOTFILES/cinnamon"
mkdir -p "$OUT"

# Drop the auto-detected night-light location; it's machine/location specific.
dconf dump /org/cinnamon/ | grep -v '^night-light-last-coordinates=' > "$OUT/cinnamon.dconf"
echo "Wrote cinnamon/cinnamon.dconf"

# Spices are downloaded at install time, so only record their names.
{
  echo "# <type> <uuid>, downloaded from cinnamon-spices.linuxmint.com by install_cinnamon.sh"
  for type in applets desklets extensions; do
    dir="$HOME/.local/share/cinnamon/$type"
    [ -d "$dir" ] || continue
    for d in "$dir"/*/; do [ -d "$d" ] && echo "$type $(basename "$d")"; done
  done
  # Only the themes currently in use, not everything in ~/.themes
  for t in "$(gsettings get org.cinnamon.theme name | tr -d "'")" \
           "$(gsettings get org.cinnamon.desktop.interface gtk-theme | tr -d "'")"; do
    [ -d "$HOME/.themes/$t" ] && echo "themes $t"
  done | sort -u
} > "$OUT/spices.txt"
echo "Wrote cinnamon/spices.txt"

# Applet/extension settings, skipping empty folders.
SPICES_CFG="$DOTFILES/home/.config/cinnamon/spices"
rm -rf "$SPICES_CFG"
mkdir -p "$SPICES_CFG"
(cd "$HOME/.config/cinnamon/spices" && find . -name '*.json' -exec cp --parents {} "$SPICES_CFG/" \;)
echo "Wrote home/.config/cinnamon/spices/"

# Default cursor theme for X apps
if [ -f "$HOME/.icons/default/index.theme" ]; then
  mkdir -p "$DOTFILES/home/.icons/default"
  cp "$HOME/.icons/default/index.theme" "$DOTFILES/home/.icons/default/"
fi
