#!/usr/bin/env bash

# Import repos
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo sh -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'

git clone https://github.com/MattiasGees/dotfiles.git /tmp/dotfiles

# install packages
cd /tmp/dotfiles
sudo dnf check-update

sudo dnf install -y zsh
sudo dnf install -y util-linux-user #needed for chsh
sudo dnf install -y code
sudo dnf install -y direnv
sudo dnf install -y golang
sudo dnf install -y kubectl

# Setup gitconfig
cp /tmp/dotfiles/gitconfig ~/.gitconfig

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cp /tmp/dotfiles/zshrc ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone git@github.com:superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt
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
cp /tmp/dotfiles/settings.json ~/.config/Code/User/settings.json

# Remove tmp 
rm -rf /tmp/dotfiles
