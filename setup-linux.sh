#!/usr/bin/env bash

sudo dnf install -y dnf-plugins-core

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
sudo sh -c 'cat <<EOF > /etc/yum.repos.d/virtualbox.repo
[virtualbox]
name=Fedora $releasever - $basearch - VirtualBox
baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/$releasever/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://www.virtualbox.org/download/oracle_vbox.asc
EOF'
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

git clone https://github.com/MattiasGees/dotfiles.git /tmp/dotfiles

# install packages
cd /tmp/dotfiles
sudo dnf check-update

sudo dnf install -y htop
sudo dnf install -y zsh
sudo dnf install -y util-linux-user #needed for chsh
sudo dnf install -y code
sudo dnf install -y direnv
sudo dnf install -y golang
sudo dnf install -y kubectl
sudo dnf install -y kubeadm
sudo dnf install -y google-cloud-sdk
sudo dnf install -y terraform
sudo dnf install -y vault
sudo dnf install -y jq
sudo dnf install -y make
sudo dnf install -y fzf
sudo dnf install -y vagrant
sudo dnf install -y VirtualBox-6.1
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo dnf install -y icedtea-web #Needed for access to certain portals
sudo dnf install -y awscli

sudo usermod -aG docker mattias

# Add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Flatpak apps
flatpak install flathub com.spotify.Client
flatpak install flathub us.zoom.Zoom
flatpak install flathub com.obsproject.Studio
flatpak install flathub com.slack.Slack

# HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm plugin install https://github.com/zendesk/helm-secrets

# Kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.9.0/kind-linux-amd64
chmod +x kind
sudo mv kind /usr/local/bin/kind

# Kubectx/Kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
mkdir -p ~/.oh-my-zsh/completions
chmod -R 755 ~/.oh-my-zsh/completions
sudo ln -s /opt/kubectx/completion/kubectx.zsh /usr/share/zsh/site-functions/_kubectx.zsh
sudo ln -s /opt/kubectx/completion/kubens.zsh /usr/share/zsh/site-functions/_kubens.zsh

# Clusterctl
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v0.3.10/clusterctl-linux-amd64 -o clusterctl
chmod +x ./clusterctl
sudo mv ./clusterctl /usr/local/bin/clusterctl

# Sops
curl -L https://github.com/mozilla/sops/releases/download/v3.6.1/sops-3.6.1-1.x86_64.rpm -o sops-3.6.1-1.x86_64.rpm
sudo rpm -ivh sops-3.6.1-1.x86_64.rpm

# 1 Password
curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/v1.7.0/op_linux_amd64_v1.7.0.zip
unzip 1password.zip
sudo mv op /usr/local/bin

# Setup gitconfig
cp /tmp/dotfiles/gitconfig ~/.gitconfig

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cp /tmp/dotfiles/zshrc ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone git@github.com:superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt

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
code --install-extension marcostazi.vs-code-vagrantfile
code --install-extension hashicorp.terraform

# Setup settings of VS Code
cp /tmp/dotfiles/settings.json ~/.config/Code/User/settings.json

# Remove tmp 
rm -rf /tmp/dotfiles
