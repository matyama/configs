.PHONY: \
	config \
	links \
	guake.conf \
	save-guake-conf \
	install-fonts \
	basic-tools \
	net-tools \
	core-utils \
	apt-utils \
	kvm \
	test-kvm \
	k8s \
	test-k8s \
	python3.6 \
	python3.7 \
	pipx \
	python-tools \
	poetry \
	sdk \
	jvm-tools \
	haskell \
	haskell-tools \
	rust \
	rust-tools \
	nodejs \
	ruby \
	docker \
	docker-compose \
	test-docker \
	nvidia-docker \
	binenv \
	zsh \
	zsh-theme \
	snaps \
	chrome \
	gh \
	travis \
	bat \
	aws-vault \
	jetbrains-toolbox \
	keybase \
	zoom \
	set-swappiness \
	crawl \
	games \
	fix-ssh-perms

# Absolute path to the directory containing this Makefile
#  - This path remains the same even when invoked with 'make -f ...'
#  - [source](https://stackoverflow.com/a/23324703)
CFG_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ifndef ZSH
ZSH=~/.oh-my-zsh
endif

ifndef ZSH_CUSTOM
ZSH_CUSTOM=$(ZSH)/custom
endif

ifndef BYOBU_CONFIG_DIR 
BYOBU_CONFIG_DIR=~/.byobu
endif

ifndef SWAPPINESS
SWAPPINESS=10
endif

ifndef SDKMAN_DIR
SDKMAN_DIR=~/.sdkman
endif

ifndef GOPATH
GOPATH=$(HOME)/go
endif

DEBIAN_ISO := debian-10.9.0-amd64-netinst.iso

FONTS_DIR := ~/.local/share/fonts

$(FONTS_DIR):
	mkdir -p $(FONTS_DIR)

$(BYOBU_CONFIG_DIR):
	mkdir -p $(BYOBU_CONFIG_DIR)

$(ZSH_CUSTOM):
	mkdir -p $(ZSH_CUSTOM)

~/.config/nvim/vim-plug:
	mkdir -p ~/.config/nvim/vim-plug

~/.config/nvim/scripts:
	mkdir -p ~/.config/nvim/scripts

~/.config/coc:
	mkdir -p ~/.config/coc

~/.config/pypoetry:
	mkdir -p ~/.config/pypoetry

~/.stack:
	mkdir -p ~/.stack

~/.local/bin:
	mkdir -p ~/.local/bin

~/vm:
	mkdir -p ~/vm

~/vm/$(DEBIAN_ISO): ISO_URL := https://cdimage.debian.org/debian-cd/current/amd64/iso-cd
~/vm/$(DEBIAN_ISO): ~/vm net-tools
	@echo ">>> Downloading Debian Buster net installer for x86_64" 
	@[ -f ~/vm/$(DEBIAN_ISO) ] || wget -O ~/vm/$(DEBIAN_ISO) $(ISO_URL)/$(DEBIAN_ISO)

$(GOPATH):
	mkdir -p ~/go

$(ZSH)/plugins/poetry:
	mkdir -p $(ZSH)/plugins/poetry

INTEL_CPU := $(shell egrep 'model name\s+: Intel' /proc/cpuinfo 2> /dev/null)

ZSH_CMD := $(shell command -v zsh 2> /dev/null)

BINENV_CMD := $(shell command -v binenv 2> /dev/null)

PYTHON36_CMD := $(shell command -v python3.6 2> /dev/null)
PYTHON37_CMD := $(shell command -v python3.7 2> /dev/null)

PIPX_CMD := $(shell command -v pipx 2> /dev/null)

VENV_CMD := $(shell command -v virtualenv 2> /dev/null)
AWSCLI_CMD := $(shell command -v aws 2> /dev/null)
PZ_CMD := $(shell command -v pz 2> /dev/null)
FUCK_CMD := $(shell command -v fuck 2> /dev/null)
PRE_COMMIT_CMD := $(shell command -v pre-commit 2> /dev/null)
BLACK_CMD := $(shell command -v black 2> /dev/null)
KAGGLE_CMD := $(shell command -v kaggle 2> /dev/null)

POETRY_CMD := $(shell command -v poetry 2> /dev/null)

GHCUP_CMD := $(shell command -v ghcup 2> /dev/null)
STACK_CMD := $(shell command -v stack 2> /dev/null)
RUSTC_CMD := $(shell command -v rustc 2> /dev/null)

GH_CMD := $(shell command -v gh 2> /dev/null)
BAT_CMD := $(shell command -v bat 2> /dev/null)

DOCKER_CMD := $(shell command -v docker 2> /dev/null)
DOCKER_COMPOSE_CMD := $(shell command -v docker-compose 2> /dev/null)

NVIDIA_CTRL := $(shell lspci | grep -i nvidia 2> /dev/null)

CHROME_CMD := $(shell command -v google-chrome 2> /dev/null)
JETBRAINS_TOOLBOX_CMD := $(shell command -v jetbrains-toolbox 2> /dev/null)
KEYBASE_CMD := $(shell command -v keybase 2> /dev/null)

CRAWL_CMD := $(shell command -v crawl 2> /dev/null)

install-fonts: P10K_URL := https://github.com/romkatv/powerlevel10k-media/raw/master
install-fonts: $(FONTS_DIR)
	@echo "Downloading Meslo Nerd Font for Powerlevel10k"
	curl "$(P10K_URL)/MesloLGS%20NF%20{Regular,Bold,Italic,Bold%20Italic}.ttf" \
		-o $(FONTS_DIR)/"MesloLGS NF #1.ttf"
	mv $(FONTS_DIR)/MesloLGS\ NF\ Bold%20Italic.ttf $(FONTS_DIR)/MesloLGS\ NF\ Bold\ Italic.ttf

guake.conf:
	guake --restore-preferences guake.conf

save-guake-conf:
	guake --save-preferences $(CFG_DIR)/guake.conf

links: $(BYOBU_CONFIG_DIR) ~/.config/nvim/vim-plug ~/.config/nvim/scripts ~/.config/coc ~/.config/pypoetry ~/.stack ~/.local/bin $(ZSH_CUSTOM)
	@echo "Linking configuration files:"
	@ln -svft ~ \
		$(CFG_DIR)/.xsession \
		$(CFG_DIR)/.gitconfig \
		$(CFG_DIR)/.pam_environment \
		$(CFG_DIR)/.zsh* \
		$(CFG_DIR)/.p10k.zsh
	@{ \
		for cfg in $$(find $(CFG_DIR)/.byobu $(CFG_DIR)/.config $(CFG_DIR)/.stack $(CFG_DIR)/.oh-my-zsh/custom -type f); do \
			ln -svf $$cfg "$(HOME)$${cfg#$(CFG_DIR)}";\
		done;\
	}
	@ln -svft ~/.local/bin \
		$(CFG_DIR)/.local/bin/increase_swap.sh \
		$(CFG_DIR)/.local/bin/init_ubuntu.sh \
		$(CFG_DIR)/.local/bin/upgrade_kernel.sh
	@[ "$$(grep 'user_readenv=1' /etc/pam.d/login)" ] || \
		echo "Finish pam env setup by manually updating '/etc/pam.d/login' - see https://askubuntu.com/a/636544"
	@echo "Finish Poetry setup by manually configuring auth tokens: https://bit.ly/3fdpMNR"

config: guake.conf links 

net-tools:
	@echo ">>> Installing basic network tools"
	sudo apt install -y curl jq net-tools wget

core-utils:
	@echo ">>> Installing core utilities"
	sudo apt install -y git lsb-core moreutils

apt-utils:
	@echo ">>> Installing utilities that let apt use packages over HTTPS"
	sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# NOTE: python-is-python3 makes python available as python3
python:
	@echo ">>> Installing standard Python libraries"
	sudo apt install -y python3-pip python3-venv python-is-python3

# Installed tools:
#  - fzf: A command-line fuzzy finder (https://github.com/junegunn/fzf)
#  - silversearcher-ag: A code-searching tool (http://geoff.greer.fm/ag/)
#  - libglpk-dev glpk-*: GLPK toolkit (https://www.gnu.org/software/glpk/) 
#  - libecpg-dev: Postgres instegrations
#  - tshark: Terminal version of wireshark
basic-tools: net-tools core-utils apt-utils python
	@echo ">>> Installing basic tools"
	sudo apt install -y \
		htop \
		iotop \
		iftop \
		tshark \
		mc \
		neovim \
		guake \
		tmux \
		byobu \
		tree \
		xclip \
		fzf \
		silversearcher-ag \
		gparted \
		gnome-tweaks \
		blueman \
		mypaint \
		tlp \
		dos2unix \
		direnv \
		graphviz \
		libecpg-dev \
		libglpk-dev \
		glpk-utils \
		glpk-doc

# FIXME: Use CPU_MODEL instead of plain 'intel' in sed replacement
# Resources:
#  - [Simple tutorial](https://phoenixnap.com/kb/ubuntu-install-kvm)
#  - [Comprehensive guide](https://bit.ly/339BtPT)
# Notes:
#  - [IOMMU GRUB fix](https://serverfault.com/a/633322)
#  - The other WARN should be fine: https://stackoverflow.com/q/65207563
ifdef INTEL_CPU
kvm: CPU_MODEL := intel
else
kvm: CPU_MODEL := amd
endif
kvm: core-utils
	@[ "$$(kvm-ok | grep exists)" ] || (kvm-ok && return 1)
	@echo ">>> Installing KVM virtualization"
	sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
	@echo ">>> Validating virtualization setup"
	@virt-host-validate || echo ">>> Consider fixing problematic entries"
	@{ \
		if [ ! "$$(grep 'iommu=on' /etc/default/grub)" ]; then \
			echo ">>> Adding '$(CPU_MODEL)_iommu=on' to GRUB config";\
			sudo sed -i "s|quiet splash|quiet splash intel_iommu=on|g" /etc/default/grub; \
			sudo update-grub; \
			echo ">>> Reboot for the GRUB changes to take effect!"; \
		fi;\
	}
	@echo ">>> Adding user '$(USER)' to 'libvirt' and 'kvm' groups"
	@echo ">>> Original primary group: $$(id -ng)"
	cat /etc/group | grep libvirt | awk -F':' {'print $$1'} | xargs -n1 sudo adduser $(USER)
	sudo adduser $(USER) kvm
	sudo systemctl enable libvirtd
	@echo ">>> Finish by system reboot for the changes to take effect"

# This test is based on https://bit.ly/339BtPT
# Notes:
#  - Groups will be visibel after login or [newgrp](https://superuser.com/a/345051) hack
#  - Default storage pool will show up AFTER reboot.
test-kvm: ~/vm/$(DEBIAN_ISO)
	@echo ">>> User groups should contain 'kvm' and 'libvirt*'"
	id -nG | egrep -ow 'kvm|libvirt|libvirt-\w+'
	@echo ">>> Verifying installation"
	virsh list --all
	@echo ">>> Showing storage pools"
	virsh pool-list --all
	@echo ">>> Showing default network created and used by KVM"
	ip addr show virbr0
	@echo ">>> Running test instance of virtual Debian Buster"
	virt-install \
		--name debian_buster \
		--virt-type=kvm \
		--ram 8192 \
		--vcpus=4 \
		--hvm \
		--cdrom ~/vm/$(DEBIAN_ISO) \
		--disk path=$(HOME)/vm/debian_buster.img,bus=virtio,size=40 \
		--network network=default,model=virtio \
		--graphics vnc,listen=0.0.0.0 \
		--video=vmvga \
		--noautoconsole
	@echo ">>> Checking that the VM is running"
	@{ \
		VM_STATE=$$(virsh list --all | grep " debian_buster " | awk '{ print $$3}');\
		[ "$$VM_STATE" = "running" ] || (echo ">>> VM is not running" && exit 1);\
	}
	@echo ">>> Destroying the VM"
	virsh destroy debian_buster
	virsh undefine debian_buster
	@echo ">>> Cleaning up the VM storage pool"
	virsh pool-list --details
	virsh pool-autostart vm --disable
	virsh pool-destroy vm
	sudo rm -f ~/vm/debian_buster.img
	virsh pool-undefine vm
	virsh pool-list --details
	@echo ">>> KVM test was successful!"

# Resources:
#  - [Minikube with KVM2 driver](https://bit.ly/3tBWEVI)
#  - [Examples with Virtualbox](https://bit.ly/3vYkEnH)
#  - [GitHub Gist](https://bit.ly/3bex2aW)
#  - [Official docs](https://minikube.sigs.k8s.io/docs/start/)
#  - [Helm docs](https://helm.sh/docs/)
#  - [k8s krew](https://krew.sigs.k8s.io/)
#  - [krew install warning](https://github.com/kubernetes-sigs/krew/issues/576)
k8s: KVM2_DRIVER_URL := https://storage.googleapis.com/minikube/releases/latest
k8s: KVM2_DRIVER := docker-machine-driver-kvm2
k8s: apt-utils binenv kvm
ifndef DOCKER_CMD
	@echo ">>> Docker is not installed"
	exit 1
else
	@echo ">>> Installing kubectl: https://kubernetes.io/docs/tasks/tools/"
	binenv install kubectl
	@echo ">>> Installing minikube: https://minikube.sigs.k8s.io/docs/"
	binenv install minikube
	@echo ">>> Installing krew: https://krew.sigs.k8s.io/"
	binenv install krew
	@echo ">>> Installing kvm2 driver: https://minikube.sigs.k8s.io/docs/drivers/kvm2/"
	curl -L -o "/tmp/$(KVM2_DRIVER)" "$(KVM2_DRIVER_URL)/$(KVM2_DRIVER)" \
		&& sudo install "/tmp/$(KVM2_DRIVER)" /usr/local/bin/
	@echo ">>> Starting minikube"
	minikube start --cpus 2 --memory 2048 --vm-driver kvm2
	minikube status
	@echo ">>> Installing and initializing helm: https://helm.sh/docs/"
	binenv install helm
	@echo ">>> Installing kubectx: https://github.com/ahmetb/kubectx"
	krew install ctx
	@echo ">>> Current k8s context is '$$(kubectl ctx -c)'"
	@echo ">>> Shutting down $$(minikube version --short)"
	minikube stop
	minikube status || true
	@echo ">>> Verified kubectl $$(kubectl version --client --short)"
endif

# FIXME: Cleanup resources if service request fails
# Resources:
#  - [minikube tutorial](https://kubernetes.io/docs/tutorials/hello-minikube/)
#  - [Minikube with KVM2 driver](https://bit.ly/3tBWEVI)
test-k8s: net-tools
	@echo ">>> Testing minikube installation"
	minikube start --cpus 2 --memory 2048 --vm-driver kvm2
	minikube status
	kubectl cluster-info
	kubectl get nodes
	kubectl get pods --all-namespaces
	@echo ">>> Running test application in minikube"
	kubectl create deployment hello-minikube \
		--image=k8s.gcr.io/echoserver:1.10 \
		--port=8080
	kubectl wait deploy/hello-minikube --for condition=available
	@echo ">>> Checking that the VM is running"
	@{ \
		VM_STATE=$$(virsh list --all | grep " minikube " | awk '{ print $$3}');\
		[ "$$VM_STATE" = "running" ] || (echo ">>> VM is not running" && exit 1);\
	}
	kubectl get pods
	@echo ">>> Exposing test service"
	kubectl get services 
	minikube service list
	kubectl expose deployment hello-minikube \
		--type=LoadBalancer \
		--port=8080
	kubectl get services
	minikube service --url hello-minikube
	@echo ">>> Requesting test service"
	curl \
		--connect-timeout 5 \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 40 \
		--retry-connrefused \
		-H "X-mytest: 123" \
		"$$(minikube service hello-minikube --url)/path123"
	@echo ">>> Clearning up test resources"
	kubectl delete service hello-minikube
	kubectl delete deployment hello-minikube
	@echo ">>> Shutting down $$(minikube version --short)"
	minikube stop
	minikube status || true
	@echo ">>> Verified kubectl $$(kubectl version --client --short)"

# TODO: Possibly better option could be https://github.com/pyenv/pyenv
python3.6: python
ifdef PYTHON36_CMD
	@echo ">>> $$(python3.6 --version) already installed"
else
	@echo ">>> Installing Python 3.6"
	sudo add-apt-repository -y ppa:deadsnakes/ppa
	sudo apt update
	sudo apt install -y python3.6-dev python3.6-venv
endif

# TODO: Possibly better option could be https://github.com/pyenv/pyenv
python3.7: python
ifdef PYTHON37_CMD
	@echo ">>> $$(python3.7 --version) already installed"
else
	@echo ">>> Installing Python 3.7"
	sudo add-apt-repository -y ppa:deadsnakes/ppa
	sudo apt update
	sudo apt install -y python3.7-dev python3.7-venv
endif

# https://github.com/devops-works/binenv#linux-bashzsh
binenv: net-tools
ifdef BINENV_CMD
	@echo ">>> binenv already installed to '$(BINENV_HOME)'"
else
	@echo ">>> Downloading and installing binenv"
	wget -q -O /tmp/binenv https://github.com/devops-works/binenv/releases/latest/download/binenv_linux_amd64
	chmod +x /tmp/binenv
	/tmp/binenv update
	/tmp/binenv install binenv
	exec $$SHELL
endif

# See: https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH
zsh: core-utils net-tools
ifdef ZSH_CMD
	@echo ">>> zsh already installed"
else
	@echo ">>> Installing zsh and oh-my-zsh"
	sudo apt install -y zsh
	zsh --version
	sh -c "$$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	sudo chsh -s $$(which zsh)
	@echo ">>> Setting up powerlevel10k theme"
	git clone https://github.com/romkatv/powerlevel10k.git $(ZSH_CUSTOM)/themes/powerlevel10k
	sudo apt install -y fonts-powerline
	@echo ">>> Finish configuration manually by running 'p10k configure'"
endif

# See: https://github.com/romkatv/powerlevel10k
zsh-theme: core-utils
	@echo ">>> Setting up powerlevel10k theme"
	git clone https://github.com/romkatv/powerlevel10k.git $(ZSH_CUSTOM)/themes/powerlevel10k
	sudo apt install -y fonts-powerline
	@echo ">>> Finish configuration manually by running 'p10k configure'"

snaps: $(GOPATH)
	@echo ">>> Installing cmake"
	sudo snap install --classic cmake
	@echo ">>> Installing Go"
	sudo snap install --classic go
	@echo ">>> Installing Slack"
	sudo snap install slack --classic
	@echo ">>> Installing Spotify"
	sudo snap install spotify
	@echo ">>> Installing Skype"
	sudo snap install skype
	@echo ">>> Installing gimp"
	sudo snap install gimp
	@echo ">>> Installing Postman"
	sudo snap install postman
	@echo ">>> Installing DBeaver: https://dbeaver.io/"
	sudo snap install dbeaver-ce
	@echo ">>> Installing Visual Studio Code"
	sudo snap install code --classic
	@echo ">>> Installing googler: https://github.com/jarun/googler"
	sudo snap install googler

pipx: python
ifdef PIPX_CMD
	@echo ">>> pipx $$(pipx --version) already installed"
else
	@echo ">>> Installing pipx"
	python3 -m pip install --user pipx
	python3 -m pipx ensurepath
endif

python-tools: pipx
ifndef VENV_CMD
	@echo ">>> Installing Python virtual environment"
	pipx install virtualenv
endif
	# @echo ">>> Installing Pipenv: https://pipenv.pypa.io/"
	# pipx install pipenv
ifndef AWSCLI_CMD
	@echo ">>> Installing AWS CLI"
	pipx install awscli
endif
ifndef PZ_CMD
	@echo ">>> Installing Pythonize: https://github.com/CZ-NIC/pz"
	pipx install pz
endif
ifndef FUCK_CMD
	@echo ">>> Installing The Fuck shell command corrector: https://github.com/nvbn/thefuck"
	pipx install thefuck
endif
ifndef PRE_COMMIT_CMD
	@echo ">>> Installing pre-commit hooks globally"
	pipx install pre-commit
endif
#ifndef BLACK_CMD
#	@echo ">>> Installing black formatter for Python"
#	pipx install black
#endif
#	@echo ">>> Installing WPS: https://wemake-python-stylegui.de/"
#	pipx install wemake-python-styleguide --include-deps
ifndef KAGGLE_CMD
	@echo ">>> Installing Kaggle API: https://github.com/Kaggle/kaggle-api"
	pipx install kaggle
endif

poetry: python zsh $(ZSH)/plugins/poetry
ifdef POETRY_CMD
	@echo ">>> $$(poetry --version) already installed"
else
	@echo ">>> Installing Poetry: https://python-poetry.org/docs/"
	curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python3
	. $(HOME)/.poetry/env
	poetry self update --preview
	poetry completions zsh > $(ZSH)/plugins/poetry/_poetry
endif

sdk: SHELL := /bin/bash
sdk: net-tools
	@echo ">>> Installing SDKMAN: https://sdkman.io/"
	curl -s https://get.sdkman.io | bash
	source $(SDKMAN_DIR)/bin/sdkman-init.sh

jvm-tools: SHELL := /bin/bash
jvm-tools: $(SDKMAN_DIR)/bin/sdkman-init.sh
	@{ \
		set -e;\
		export SDKMAN_DIR=$$HOME/.sdkman;\
		source $$SDKMAN_DIR/bin/sdkman-init.sh;\
		echo ">>> Installing Java";\
		sdk install java;\
		sdk install java 8.0.292-zulu;\
		echo ">>> Installing Maven";\
		sdk install maven;\
		echo ">>> Installing Gradle";\
		sdk install gradle;\
		echo ">>> Installing Kotlin";\
		sdk install kotlin;\
		echo ">>> Installing kscript";\
		sdk install kscript;\
		echo ">>> Installing sbt";\
		sdk install sbt;\
		echo ">>> Installing Scala";\
		sdk install scala;\
		echo ">>> Installing Spark";\
		sdk install spark;\
		echo ">>> Installing VisualVM";\
		sdk install visualvm;\
	}

# Haskell toolchain and project builder
#  - [ghcup](https://www.haskell.org/ghcup/)
#  - [stack](https://docs.haskellstack.org/en/stable/README/)
# Additional notes:
#  - ghcup also installs the Haskell Language Server
#  - ghcup-zsh instegration is already present in .zshrc
haskell: net-tools
ifndef GHCUP_CMD
	@echo ">>> Installing Haskell toolchain installer"
	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
endif
ifndef STACK_CMD
	@echo ">>> Installing Haskell Stack"
	curl -sSL https://get.haskellstack.org/ | sh
endif

# Installed tools:
#  - brittany: Haskell source code formatter
#  - data-tree-print: Installed as a brittany dependency
haskell-tools: haskell
	@echo ">>> Installing brittany: https://github.com/lspitzner/brittany/"
	stack install data-tree-print brittany

rust: net-tools
ifndef RUSTC_CMD
	@echo ">>> Installing Rust toolchain"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	. $(HOME)/.cargo/env
	@echo ">>> Installing Rust nightly toolchain"
	rustup install nightly
endif
	rustup show

# Installed tools:
#  - click: Command Line Interactive Controller for Kubernetes
#  - exa: A modern replacement for 'ls' (https://github.com/ogham/exa)
#  - fd: A simple, fast and user-friendly alternative to 'find'
#    (https://github.com/sharkdp/fd)
#  - proximity-search: Simple command-line utility for sorting inputs by
#    proximity to a path argument (https://github.com/jonhoo/proximity-sort)
#  - ripgrep: Recursively searches directories for a regex pattern
#    (https://github.com/BurntSushi/ripgrep)
rust-tools: rust
	@echo ">>> Installing cargo-readme"
	cargo install cargo-readme
	@echo ">>> Installing exa: https://the.exa.website/"
	cargo install exa
	@echo ">>> Installing fd: https://github.com/sharkdp/fd"
	cargo install fd-find
	@echo ">>> Installing proximity-search: https://github.com/jonhoo/proximity-sort"
	cargo install proximity-sort
	@echo ">>> Installing click: https://github.com/databricks/click"
	cargo install click
	@echo ">>> Installing ripgrep: https://github.com/BurntSushi/ripgrep"
	cargo install ripgrep

nodejs: net-tools
	@echo ">>> Installing nodejs (LTS)"
	sudo curl -sL install-node.now.sh/lts | sudo bash -s -- -y

ruby:
	@echo ">>> Installing Ruby"
	sudo snap install --classic ruby 

# Installtion resources:
#  - [Official documentation](https://docs.docker.com/engine/install/ubuntu/)
#  - [Official post-instegration](https://docs.docker.com/engine/install/linux-postinstall/)
docker: DOCKER_URL := https://download.docker.com/linux/ubuntu
docker: DOCKER_GPG := /usr/share/keyrings/docker-archive-keyring.gpg
docker: core-utils apt-utils
	@echo ">>> Installing Docker: https://docs.docker.com/engine/install/ubuntu/"
	@echo ">>> Downloading GPG key as '$(DOCKER_GPG)' and configuring apt sources"
	curl -fsSL $(DOCKER_URL)/gpg | gpg --dearmor | sudo tee $(DOCKER_GPG) > /dev/null
	echo "deb [arch=amd64 signed-by=$(DOCKER_GPG)] $(DOCKER_URL) $$(lsb_release -cs) stable" \
		| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	@echo ">>> Setting up 'docker' user group with current user '$(USER)'"
	sudo groupadd -f docker
	sudo gpasswd -a $(USER) docker
	sudo usermod -aG docker $(USER)
	@echo ">>> Configuring Docker to start on boot"
	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
	@echo ">>> Finishing Docker installation"
	sudo service docker restart
	newgrp docker

# NOTE: This target installs docker-compose using pipx for easier version handling.
docker-compose:
ifdef DOCKER_COMPOSE_CMD
	@echo ">>> Already installed $$(docker-compose --version)"
else
	@echo ">>> Installing docker-compose: https://docs.docker.com/compose/install/"
	pipx install docker-compose
endif

test-docker:
ifndef DOCKER_CMD
	$(error docker command not found)
else
	@echo ">>> Testing $$(docker --version)"
	docker run --rm hello-world:latest
	docker rmi -f hello-world:latest
endif

# Installation resources:
#  - [Official documentation](https://bit.ly/3tcye5b)
#  - [Package info](https://bit.ly/3nISlqx)
#  - [k8s](https://bit.ly/3ta2ttu) and the [plugin](https://github.com/NVIDIA/k8s-device-plugin)
# TL;DR
#  - k8s depends on a runtime => install nvidia-docker2 and use --runtime=nvidia (--gpus might work)
#  - otherwise install just nvidia-container-toolkit and use --gpus
nvidia-docker: NVIDIA_DOCKER_PKG := nvidia-docker2
nvidia-docker: NVIDIA_DOCKER_URL := https://nvidia.github.io/nvidia-docker
nvidia-docker: NVIDIA_DOCKER_GPG := /usr/share/keyrings/nvidia-docker-archive-keyring.gpg
nvidia-docker: DOCKERD_CFG := /etc/docker/daemon.json
nvidia-docker: core-utils net-tools
ifdef NVIDIA_CTRL
	@echo ">>> Installing NVIDIA Docker"
	@echo ">>> Downloading GPG key as '$(NVIDIA_DOCKER_GPG)' and configuring apt sources"
	curl -fsSL "$(NVIDIA_DOCKER_URL)/gpgkey" | gpg --dearmor | sudo tee $(NVIDIA_DOCKER_GPG) > /dev/null
	@{ \
		DISTRIBUTION=$$(lsb_release -sir | tr -d '\n' | tr '[:upper:]' '[:lower:]');\
		curl -sL "$(NVIDIA_DOCKER_URL)/$$DISTRIBUTION/nvidia-docker.list" \
			| sed "s|deb|deb [signed-by=$(NVIDIA_DOCKER_GPG)]|g" \
			| sudo tee /etc/apt/sources.list.d/nvidia-docker.list > /dev/null;\
	}
	sudo apt update
	sudo apt install -y $(NVIDIA_DOCKER_PKG)
	sudo jq --arg r nvidia '{"default-runtime": $$r} + .' $(DOCKERD_CFG) | sudo sponge $(DOCKERD_CFG)
	sudo systemctl restart docker
	@echo ">>> Testing NVIDIA Docker installation"
	docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
else
	$(error >>> No NVIDIA GPU available)
endif

chrome: CHROME_PKG := google-chrome-stable_current_amd64.deb
chrome: net-tools
ifdef CHROME_CMD
	@echo ">>> Google Chrome already installed"
else
	@echo ">>> Downloading and installing Google Chrome"
	wget -O /tmp/$(CHROME_PKG) https://dl.google.com/linux/direct/$(CHROME_PKG)
	sudo apt install -y /tmp/$(CHROME_PKG)
endif

# https://github.com/cli/cli
gh: zsh
ifdef GH_CMD
	@echo ">>> gh already installed"
else
	@echo ">>> Installing Github CLI"
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
	sudo apt-add-repository https://cli.github.com/packages
	sudo apt update
	sudo apt install -y gh
	@echo ">>> Adding ZSH autocompletion for Github CLI"
	gh completion -s zsh | sudo tee /usr/local/share/zsh/site-functions/_gh > /dev/null
endif

travis: ruby
	@echo ">>> Installing Travis CLI: https://github.com/travis-ci/travis.rb"
	gem install travis --no-document --user-install

# TODO: Install via binenv when it's available as a dependency
aws-vault: AWS_VAULT_BIN := /usr/local/bin/aws-vault
aws-vault: AWS_VAULT_URL := https://github.com/99designs/aws-vault/releases
aws-vault: net-tools
	@echo ">>> Installing latest aws-vault: $(AWS_VAULT_URL)"
	@{ \
		TAG=$$(curl -sL -H "Accept: application/json" "$(AWS_VAULT_URL)/latest" | jq -r '.tag_name');\
		echo ">>> Downloading aws-vault $$TAG binary as '$(AWS_VAULT_BIN)'";\
		sudo curl -Lo $(AWS_VAULT_BIN) "$(AWS_VAULT_URL)/download/$$TAG/aws-vault-linux-amd64";\
	}
	sudo chmod 755 $(AWS_VAULT_BIN)

bat: ~/.local/bin
ifdef BAT_CMD
	@echo ">>> $$(bat --version) already installed"
else
	@echo ">>> Installing bat: https://github.com/sharkdp/bat"
	sudo apt install -y bat
	ln -s /usr/bin/batcat ~/.local/bin/bat
	@echo ">>> Installed $$(bat --version)"
endif

set-swappiness:
ifeq ($(shell grep "vm.swappiness" /etc/sysctl.conf),)
	@echo ">>> Setting swappiness to $(SWAPPINESS)"
	@echo "# Decrease swap usage to a more reasonable level\nvm.swappiness=$(SWAPPINESS)" | sudo tee -a /etc/sysctl.conf > /dev/null
else
	@echo ">>> Manually change value of 'vm.swappiness' in '/etc/sysctl.conf'"
endif

# Resources:
#  - [Automating setup](https://bit.ly/2SMFmsj)
jetbrains-toolbox: TOOLBOX_URL := "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"
jetbrains-toolbox: TOOLBOX_DIR := $(shell mktemp -d)
jetbrains-toolbox: net-tools
ifdef JETBRAINS_TOOLBOX_CMD
	@echo ">>> JetBrains Toolbox already installed"
else
	@echo ">>> Downloading and unpacking $(TOOLBOX_URL)"
	curl -sL $(TOOLBOX_URL) | tar -xvzf - --strip-components=1 -C $(TOOLBOX_DIR)
	@echo ">>> Installing JetBrains Toolbox"
	$(TOOLBOX_DIR)/jetbrains-toolbox
endif
	rm -rf $(TOOLBOX_DIR)

keybase: KEYBASE_URI := https://prerelease.keybase.io/keybase_amd64.deb
keybase: KEYBASE_PKG := $(shell mktemp)
keybase: net-tools
ifdef KEYBASE_CMD
	@echo ">>> $$(keybase --version) already installed"
else
	@echo ">>> Installing Keybase: https://keybase.io/docs/the_app/install_linux"
	curl -o $(KEYBASE_PKG) --remote-name $(KEYBASE_URI)
	sudo dpkg -i $(KEYBASE_PKG) || true
	sudo apt install -y -f
	@echo ">>> Complete by running command 'run_keybase'"
endif
	rm -f $(KEYBASE_PKG)

zoom:
	@echo ">>> Installing zoom client"
	sudo snap install zoom-client

games: crawl

crawl: net-tools
ifdef CRAWL_CMD
	@echo ">>> $$(crawl --version | head -n1) already installed"
else
	@echo ">>> Installing Dungeon Crawl Stone Soup: https://crawl.develz.org/"
	echo 'deb https://crawl.develz.org/debian crawl 0.23' | sudo tee -a /etc/apt/sources.list
	wget https://crawl.develz.org/debian/pubkey -O - | sudo apt-key add -
	sudo apt update
	sudo apt install -y crawl crawl-tiles
endif

fix-ssh-perms: SSH_DIR := $(HOME)/.ssh
fix-ssh-perms:
	@echo ">>> Setting appropriate file permissions for files in '$(SSH_DIR)'"
	chmod 700 $(SSH_DIR)
	chmod 644 "$(SSH_DIR)/authorized_keys"
	chmod 644 "$(SSH_DIR)/*.pub"
	chmod 600 "$(SSH_DIR)/id_rsa*"
	chmod 600 "$(SSH_DIR)/config"
	chmod 600 "$(SSH_DIR)/known_hosts*"
	chmod 400 "$(SSH_DIR)/*.pem"

