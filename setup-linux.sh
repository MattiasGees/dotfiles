#!/usr/bin/env bash

# Import repos
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

git clone https://github.com/MattiasGees/dotfiles.git /tmp/dotfiles

# install packages
cd /tmp/dotfiles
sudo dnf check-update

sudo dnf install -y zsh
sudo dnf install -y code

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
code --install-extension lextudio.restructuredtext
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension ms-python.python
code --install-extension redhat.vscode-yaml
code --install-extension searKing.preview-vscode
code --install-extension technosophos.vscode-helm

# Setup settings of VS Code
cp /tmp/dotfiles/settings.json ~/.config/Code/User/settings.json
