#!/bin/bash

set -e

if [ ! -d ~/code/dotfiles ]; then
  echo "Cloning dotfiles"
  # the reason we dont't copy the files individually is, to easily push changes
  # if needed
  cd ~/code
  git clone --recursive https://github.com/mattiasgees/dotfiles.git
fi

cd ~/code/dotfiles 
git remote set-url origin git@github.com:mattiasgees/dotfiles.git

rm ~/.zshrc
ln -s $(pwd)/zshrc ~/.zshrc
ln -s $(pwd)/gitconfig ~/.gitconfig
ln -s $(pwd)/sshconfig_linux ~/.ssh/config
ln -s ~/code ~/go/src

/usr/sbin/sshd -D
