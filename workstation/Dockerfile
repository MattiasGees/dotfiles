ARG GOLANG_VERSION=1.11.4

# install kubectl
FROM ubuntu:18.10 as kubectl_builder
RUN apt-get update && apt-get install -y curl ca-certificates
RUN curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod 755 /usr/local/bin/kubectl

# install 1password
FROM ubuntu:18.10 as onepassword_builder
RUN apt-get update && apt-get install -y curl ca-certificates unzip
RUN curl -sS -o 1password.zip https://cache.agilebits.com/dist/1P/op/pkg/v0.5.5/op_linux_amd64_v0.5.5.zip && unzip 1password.zip op -d /usr/bin &&  rm 1password.zip

# install terraform
FROM ubuntu:18.10 as terraform_builder
RUN apt-get update && apt-get install -y wget ca-certificates unzip
RUN wget https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip && unzip terraform_0.11.11_linux_amd64.zip && chmod +x terraform && mv terraform /usr/local/bin && rm terraform_0.11.11_linux_amd64.zip

# base OS
FROM ubuntu:18.10
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -qq -y \
	ansible \
	apache2-utils \
	apt-transport-https \
	build-essential \
	bzr \
	ca-certificates \
	clang \
	cmake \
	curl \
	default-libmysqlclient-dev \
	default-mysql-client \
	direnv \
	dnsutils \
	docker.io \
	fakeroot-ng \
	gdb \
	git \
	git-crypt \
	gnupg \
	gnupg2 \
	htop \
	hugo \
	ipcalc \
	jq \
	less \
	libclang-dev \
	liblzma-dev \
	libpq-dev \
	libprotoc-dev \
	libsqlite3-dev \
	libssl-dev \
	libvirt-clients \
	libvirt-daemon-system \
	lldb \
	locales \
	man \
	mosh \
	mtr-tiny \
	musl-tools \
	ncdu \
	netcat-openbsd \
	openssh-server \
	pkg-config \
	postgresql-contrib \
	protobuf-compiler \
	pwgen \
	python \
	python3 \
	python3-flake8 \
	python3-pip \
	python3-setuptools \
	python3-venv \
	python3-wheel \
	qemu-kvm \
	qrencode \
	quilt \
	ripgrep \
	shellcheck \
	silversearcher-ag \
	socat \
	software-properties-common \
	sqlite3 \
	stow \
	sudo \
	tig \
	tmate \
	tmux \
	tree \
	unzip \
	wget \
	zgen \
	zip \
	zlib1g-dev \
	zsh \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*


RUN mkdir /run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's/#Port 22/Port 3222/' -i /etc/ssh/sshd_config

RUN add-apt-repository ppa:jonathonf/vim -y && apt-get update && apt-get install vim-gtk3 -y

RUN wget https://dl.google.com/go/go1.11.4.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.11.4.linux-amd64.tar.gz && rm go1.11.4.linux-amd64.tar.gz

ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
	locale-gen --purge $LANG && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=$LANG LC_ALL=$LC_ALL LANGUAGE=$LANGUAGE

# gcloud
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
  echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update -y && apt-get install google-cloud-sdk google-cloud-sdk-app-engine-go -y

RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy && chmod +x cloud_sql_proxy && mv cloud_sql_proxy /usr/local/bin

# for correct colours is tmux
ENV TERM screen-256color

# kubectl
COPY --from=kubectl_builder /usr/local/bin/kubectl /usr/local/bin/

# kubectl
COPY --from=onepassword_builder /usr/bin/op /usr/local/bin/

# terraform tools
COPY --from=terraform_builder /usr/local/bin/terraform /usr/local/bin/

# install tools
RUN wget https://github.com/gsamokovarov/jump/releases/download/v0.22.0/jump_0.22.0_amd64.deb && sudo dpkg -i jump_0.22.0_amd64.deb && rm -rf jump_0.22.0_amd64.deb

RUN mkdir ~/.ssh && curl -fsL https://github.com/mattiasgees.keys > ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys

# zsh plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN git clone https://github.com/superbrothers/zsh-kubectl-prompt.git /usr/local/etc/zsh-kubectl-prompt
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/plugins/zsh-autosuggestions

# tmux plugins
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
RUN git clone https://github.com/tmux-plugins/tmux-open.git ~/.tmux/plugins/tmux-open
RUN git clone https://github.com/tmux-plugins/tmux-yank.git ~/.tmux/plugins/tmux-yank
RUN git clone https://github.com/tmux-plugins/tmux-prefix-highlight.git ~/.tmux/plugins/tmux-prefix-highlight

RUN chsh -s /usr/bin/zsh

EXPOSE 3222 60000-60010/udp

WORKDIR /root
COPY entrypoint.sh /bin/entrypoint.sh
CMD ["/bin/entrypoint.sh"]
