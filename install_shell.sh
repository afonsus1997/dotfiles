#!/usr/bin/env bash
# Installs zsh + oh-my-zsh (with the AM theme and plugins), starship, and tmux
# (with TPM and its plugins), then copies the configs from this repo into $HOME.
# Safe to re-run: existing installs are skipped, existing configs are backed up.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$DOTFILES/home"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM_DIR="$ZSH_DIR/custom"

info() { printf '\n\033[1;32m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!] %s\033[0m\n' "$*"; }

# Back up an existing file before overwriting it, then copy the repo version.
install_file() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && ! cmp -s "$src" "$dest"; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$dest" "$BACKUP_DIR/"
    warn "Backed up $dest -> $BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "Installed $dest"
}

# Clone a git repo if it isn't there yet, otherwise pull it.
clone_or_update() {
  local url="$1" dest="$2"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only --quiet || warn "Could not update $dest"
  else
    git clone --depth=1 "$url" "$dest"
  fi
}

############# PACKAGES #############
info "Installing packages (apt)"
sudo apt update
sudo apt install -y zsh git curl tmux xclip fzf bat zsh-syntax-highlighting

# zoxide and lsd are only in apt on newer Ubuntu releases; fall back otherwise.
if ! command -v zoxide >/dev/null; then
  sudo apt install -y zoxide 2>/dev/null \
    || curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi
if ! command -v lsd >/dev/null; then
  sudo apt install -y lsd 2>/dev/null || sudo snap install lsd
fi

# Ubuntu ships bat as "batcat"
mkdir -p "$HOME/.local/bin"
if command -v batcat >/dev/null && [ ! -e "$HOME/.local/bin/bat" ]; then
  ln -s "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

############# OH MY ZSH #############
info "Installing oh-my-zsh"
if [ -d "$ZSH_DIR" ]; then
  echo "oh-my-zsh already installed, skipping"
else
  # Unattended: don't switch shell, don't launch zsh, don't touch .zshrc.
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

info "Installing zsh extensions"
clone_or_update https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
# .zshrc sources zsh-autocomplete from ~/.oh-my-zsh/others/
mkdir -p "$ZSH_DIR/others"
clone_or_update https://github.com/marlonrichert/zsh-autocomplete \
  "$ZSH_DIR/others/zsh-autocomplete"

info "Copying custom theme"
install_file "$SRC/.oh-my-zsh/themes/AM.zsh-theme" "$ZSH_DIR/themes/AM.zsh-theme"

info "Copying .zshrc"
install_file "$SRC/.zshrc" "$HOME/.zshrc"
# The repo's .zshrc hardcodes /home/amrm; point it at this machine's $HOME.
if [ "$HOME" != "/home/amrm" ]; then
  sed -i "s|/home/amrm|$HOME|g" "$HOME/.zshrc"
  echo "Rewrote /home/amrm -> $HOME in ~/.zshrc"
fi

############# STARSHIP #############
info "Installing starship"
if command -v starship >/dev/null; then
  echo "starship already installed ($(starship --version | head -1))"
else
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
install_file "$SRC/.config/starship.toml" "$HOME/.config/starship.toml"

############# TMUX #############
info "Setting up tmux"
install_file "$SRC/.tmux.conf" "$HOME/.tmux.conf"
clone_or_update https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
info "Installing tmux plugins"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" || warn "TPM install failed; press prefix (Ctrl+k) + I inside tmux"

############# DEFAULT SHELL #############
ZSH_BIN="$(command -v zsh)"
if [ "${SHELL:-}" != "$ZSH_BIN" ]; then
  info "Setting zsh as default shell"
  chsh -s "$ZSH_BIN" || warn "chsh failed; run: chsh -s $ZSH_BIN"
fi

info "Done! Log out and back in (or run 'exec zsh') to start using it."
[ -d "$BACKUP_DIR" ] && echo "Previous configs were backed up to $BACKUP_DIR"
exit 0
