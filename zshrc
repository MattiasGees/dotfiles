# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

DEFAULT_USER="mattias"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  helm
  aws
  docker
  encode64
  tmux
  zsh-autosuggestions
  #zsh-kubectl-prompt
  colored-man-pages
  gpg-agent
  golang
  kubectl
  gcloud
  extract
  terraform
  vagrant
  vault
  web-search
)

source $ZSH/oh-my-zsh.sh
source /opt/homebrew/etc/zsh-kubectl-prompt/kubectl.zsh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

export PATH="/usr/local/go/bin:$PATH"

export GOPATH=$(go env GOPATH)
export PATH=$PATH:$(go env GOPATH)/bin
export GPG_TTY=$(tty)

alias git-sync="git checkout master && git fetch upstream && git rebase upstream/master && git push origin master"
alias git-clean="git branch --merged | egrep -v \"(^\*|master|dev)\" | xargs git branch -d && git remote prune origin && git remote prune upstream"
alias gcloud-personal="gcloud config set core/account mattias.gees@gmail.com"
alias gcloud-work="gcloud config set core/account mattias.gees@jetstack.io"
alias gcurl='curl -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json"'

autoload -U colors; colors
RPROMPT='%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}'

# Enable direnv
eval "$(direnv hook zsh)"

function ephemeralContainer() {
    pod_name="$1"
    container_name="$2"
    namespace="${3:-default}"
    image="${4:-alpine:latest}"
    if [[ -z "${pod_name}" || -z "${container_name}" ]]; then
        echo "requires pod name as first argument and container name as second argument"
        return 1
    fi
    pod_json="$(kubectl -n "${namespace}" get pod "${pod_name}" -o json)"
    if [[ -z "${pod_json}" ]]; then
        echo "invalid pod"
        return 2
    fi
    volume_mounts="$(jq --arg CONTAINERNAME "${container_name}" '.spec.containers[] | select(.name==$CONTAINERNAME) | .volumeMounts | map(select(.subPath==null))' <<<"${pod_json}")"
    env_variables="$(jq --arg CONTAINERNAME "${container_name}" '.spec.containers[] | select(.name==$CONTAINERNAME) | .env' <<<"${pod_json}")"
    env_froms="$(jq --arg CONTAINERNAME "${container_name}" '.spec.containers[] | select(.name==$CONTAINERNAME) | .envFrom' <<<"${pod_json}")"
    exec 3< <(
        kubectl proxy --port=0 &
        echo $!
    )
    port_number=''
    kubectl_pid=''
    while [[ "${port_number}" == '' || "${kubectl_pid}" == '' ]]; do
        read -r -u 3 line
        if [[ "${kubectl_pid}" == '' && "${line}" =~ ^[0-9]+$ ]]; then
            kubectl_pid="${line}"
            continue
        elif [[ "${port_number}" == '' && "${line}" =~ :[0-9]+$ ]]; then
            port_number="$(grep -oE '[0-9]+$' <<<"${line}")"
            continue
        fi
    done

    ephemeral_container_name="debugger-${RANDOM}"
    patch_api_body="$(jq -r tostring <<EOF
  {
    "spec":
    {
        "ephemeralContainers":
        [
            {
                "name": "${ephemeral_container_name}",
                "command": ["sh"],
                "image": "${image}",
                "targetContainerName": "${container_name}",
                "stdin": true,
                "tty": true,
                "volumeMounts": ${volume_mounts},
                "envFrom": ${env_froms},
                "env": ${env_variables}
            }
        ]
    }
}
EOF
)"
    echo "Patching with the following:"
    echo "${patch_api_body}"
    curl "http://localhost:${port_number}/api/v1/namespaces/${namespace}/pods/${pod_name}/ephemeralcontainers" -X PATCH -H 'Content-Type: application/strategic-merge-patch+json' --data-binary "${patch_api_body}"
    kill "${kubectl_pid}"

    try=1
    while [[ "$(kubectl -n "${namespace}" get pod "${pod_name}" -o jsonpath='{.status.ephemeralContainerStatuses}' | jq --arg EPHEMERALCONTAINERNAME "${ephemeral_container_name}" -r 'map(select(.name==$EPHEMERALCONTAINERNAME))[0].state | has("running")')" != 'true' ]]; do
        echo 'Ephemeral container still not running...'
        sleep 1
        ((try++))
        if [[ ${try} -gt 30 ]]; then
            echo 'Waiting for ephemeral container to be running timed out.'
            return 3
        fi
    done

    kubectl -n "${namespace}" attach "${pod_name}" -c "${ephemeral_container_name}" -it
}
