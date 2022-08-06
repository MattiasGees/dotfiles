#!/usr/bin/env bash

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install git
brew install git

# Intall Yubikey Agent (https://github.com/FiloSottile/yubikey-agent)
brew install yubikey-agent
brew services start yubikey-agent

export SSH_AUTH_SOCK="$(brew --prefix)/var/run/yubikey-agent.sock"

# clone dotfiles repo
git clone https://github.com/MattiasGees/dotfiles.git /tmp/dotfiles

# install packages
cd /tmp/dotfiles
brew bundle

# Setup gitconfig
cp /tmp/dotfiles/gitconfig ~/.gitconfig

# Setup SSH
cp /tmp/dotfiles/sshconfig ~/.ssh/config

# Install Powerline font
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cp /tmp/dotfiles/zshrc ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install code extensions
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension eamodio.gitlens
code --install-extension erd0s.terraform-autocomplete
code --install-extension James-Yu.latex-workshop
code --install-extension lextudio.restructuredtext
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-python.python
code --install-extension redhat.vscode-yaml
code --install-extension searKing.preview-vscode
code --install-extension technosophos.vscode-helm
code --install-extension ms-azuretools.vscode-docker

# Setup settings of VS Code
cp /tmp/dotfiles/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Setup GPG
cp /tmp/dotfiles/gpg.conf ~/.gnupg/gpg.conf
cp /tmp/dotfiles/gpg-agent.conf ~/.gnupg/gpg-agent.conf
