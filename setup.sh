#!/usr/bin/env bash

# install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# install git
brew install git

# clone dotfiles repo
git clone https://github.com/MattiasGees/dotfiles.git /tmp/dotfiles

# install packages
cd /tmp/dotfiles
brew bundle

# Setup gitconfig
cp /tmp/dotfiles/gitconfig ~/.gitconfig

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cp /tmp/dotfiles/zshrc ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
