#! /bin/bash

HOMEDIR=~/

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
echo "Installing oh my zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#cp home/.zshrc $HOMEDIR
#mkdir -p $HOMEDIR/.oh-my-zsh/themes
#cp -r home/.oh-my-zsh/themes $HOMEDIR/.oh-my-zsh/

#install starship
curl -sS https://starship.rs/install.sh | sh
#starship config already copied

mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat