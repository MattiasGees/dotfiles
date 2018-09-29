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

# Install code extensions
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension eamodio.gitlens
code --install-extension erd0s.terraform-autocomplete
code --install-extension James-Yu.latex-workshop
code --install-extension jpogran.puppet-vscode
code --install-extension lextudio.restructuredtext
code --install-extension mauve.terraform
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-python.python
code --install-extension ms-vscode.Go
code --install-extension PeterJausovec.vscode-docker
code --install-extension redhat.vscode-yaml
code --install-extension searKing.preview-vscode
code --install-extension technosophos.vscode-helm

# Setup settings of VS Code
cp /tmp/dotfiles/settings.json ~/Library/Application\ Support/Code/User/settings.json
