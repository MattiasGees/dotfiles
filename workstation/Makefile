GITCOMMIT := $(shell git rev-parse --short=7 HEAD 2>/dev/null)
NAME=dev

all: build

build:
	docker build -t mattiasgees/${NAME}:${GITCOMMIT} .

push:
	@echo "==> Publishing mattiasgees/${NAME}:$(GITCOMMIT)"
	@docker tag mattiasgees/${NAME}:$(GITCOMMIT) mattiasgees/${NAME}:latest
	@docker push mattiasgees/${NAME}:$(GITCOMMIT)
	@docker push mattiasgees/${NAME}:latest
	@echo "==> Your image is now available at mattiasgees/${NAME}:$(GITCOMMIT)"

run: kill
	docker run -it -h dev -d --net=host --rm -v /var/run/docker.sock:/var/run/docker.sock -v /home/mattiasgees/code:/home/mattiasgees/code -v /home/mattiasgees/.ssh:/home/mattiasgees/.ssh -v /home/mattiasgees/.zsh_private:/home/mattiasgees/.zsh_private -v /home/mattiasgees/.zsh_history:/home/mattiasgees/.zsh_history --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --privileged --name dev mattiasgees:dev 

ssh:
	mosh --no-init --ssh="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -p 3222" mattiasgees@localhost -- tmux new-session -AD -s main

kill:
	docker kill dev | true
