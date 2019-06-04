#!/bin/bash

set -eu

echo "Authenticating with 1Password"
export OP_SESSION_anneliesmattias=$(op signin https://anneliesmattias.1password.com mattias.gees@gmail.com --output=raw)

echo "Pulling secrets"
# private keys
op get document 'id_workstation' > id_rsa
op get document 'kubeconfig' > kubeconfig
# op get document 'zsh_private' > zsh_private
# op get document 'zsh_history' > zsh_history

mkdir -p ~/.kube

rm -f ~/.ssh/id_rsa
rm -f ~/.kube/config
# rm ~/.zsh_private
# rm ~/.zsh_history

ln -s $(pwd)/id_rsa ~/.ssh/id_rsa
ln -s $(pwd)/kubeconfig ~/.kube/config
chmod 0600 ~/.ssh/id_rsa
# ln -s $(pwd)/zsh_private ~/.zsh_private
# ln -s $(pwd)/zsh_history ~/.zsh_history

echo "Done!"
