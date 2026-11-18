#! /bin/bash

HOMEDIR=~/

# Install oh-my-zsh BEFORE copying home/, which contains .oh-my-zsh/themes and
# would otherwise create ~/.oh-my-zsh and make the installer refuse to run.
if [ ! -f ~/.oh-my-zsh/oh-my-zsh.sh ]; then
  [ -d ~/.oh-my-zsh ] && mv ~/.oh-my-zsh ~/.oh-my-zsh.incomplete.$(date +%s)
  echo "Installing oh my zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

#make and copy .config
#mkdir -p $HOMEDIR/.config
cp -r home/. $HOMEDIR

echo ""
echo "Don't forget to install i3blocks mpris"
echo "https://github.com/un-def/i3blocks-mpris"
echo ""
echo "Don't forget to install i3 workspace groups"
echo "https://github.com/infokiller/i3-workspace-groups"

############# INSTALL ZSH #############

#install oh my zsh
echo ""
echo "Installing zsh"
#install oh my zsh
# (oh my zsh is installed at the top of this script)
#cp home/.zshrc $HOMEDIR
#mkdir -p $HOMEDIR/.oh-my-zsh/themes
#cp -r home/.oh-my-zsh/themes $HOMEDIR/.oh-my-zsh/

#install starship
curl -sS https://starship.rs/install.sh | sh
#starship config already copied

mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat