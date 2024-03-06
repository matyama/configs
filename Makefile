# Absolute path to the directory containing this Makefile
#  - This path remains the same even when invoked with 'make -f ...'
#  - [source](https://stackoverflow.com/a/23324703)
CFG_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Make sure XDG is set: https://wiki.archlinux.org/title/XDG_Base_Directory
XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_BIN_HOME ?= $(HOME)/.local/bin
XDG_DATA_HOME ?= $(HOME)/.local/share
XDG_STATE_HOME ?= $(HOME)/.local/state

GIT_TEMPLATE_DIR ?= $(XDG_DATA_HOME)/git-core/templates

ZDOTDIR ?= $(XDG_CONFIG_HOME)/zsh
ZSH ?= $(XDG_DATA_HOME)/oh-my-zsh
ZSH_CUSTOM ?= $(ZSH)/custom

FZF_BASE ?= $(XDG_DATA_HOME)/fzf

BASE16_FZF_HOME ?= $(XDG_CONFIG_HOME)/base16-fzf
# TODO: currently tinted-theming hardcodes `$HOME/.config`, use 
# `XDG_CONFIG_HOME` once supported
BASE16_SHELL_PATH ?= $(HOME)/.config/base16-shell

ALACRITTY_CONFIG_DIR ?= $(XDG_CONFIG_HOME)/alacritty
BAT_CONFIG_DIR ?= $(XDG_CONFIG_HOME)/bat
BYOBU_CONFIG_DIR ?= $(XDG_CONFIG_HOME)/byobu
FD_CONFIG_HOME ?= $(XDG_CONFIG_HOME)/fd
RIPGREP_CONFIG_HOME ?= $(XDG_CONFIG_HOME)/rg

CARGO_HOME ?= $(XDG_DATA_HOME)/cargo

ifndef CARGO_TARGET_DIR
CARGO_TARGET_DIR=$(XDG_CACHE_HOME)/cargo-target
CARGO_RELEASE_DIR=$(CARGO_TARGET_DIR)/release
CARGO_ARTIFACTS_DIR=$(CARGO_RELEASE_DIR)/artifacts
endif

GEM_HOME ?= $(XDG_CONFIG_HOME)/gem
GEM_SPEC_CACHE ?= $(XDG_CACHE_HOME)/gem

TRAVIS_CONFIG_PATH ?= $(XDG_CONFIG_HOME)/travis

GHCUP_USE_XDG_DIRS ?= 1
STACK_ROOT ?= $(XDG_DATA_HOME)/stack

SDKMAN_DIR ?= $(XDG_DATA_HOME)/sdkman
ZSH_SDKMAN_DIR ?= $(XDG_DATA_HOME)/zsh-sdkman

GOPATH ?= $(XDG_DATA_HOME)/go

MINIKUBE_HOME ?= $(XDG_DATA_HOME)/minikube
KREW_ROOT ?= $(XDG_DATA_HOME)/krew

DIST_ARCH := $(shell dpkg --print-architecture)

# Aliases to make tools respect XDG specification
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
WGET := wget --hsts-file=$(XDG_CACHE_HOME)/wget-hsts

DEBIAN_ISO := debian-11.3.0-$(DIST_ARCH)-netinst.iso

APT_KEYRINGS := /etc/apt/keyrings
FONTS_DIR := $(XDG_DATA_HOME)/fonts
KEYRINGS_DIR := /usr/share/keyrings
MAN1_DIR := /usr/local/share/man/man1
PIXMAPS_DIR := /usr/share/pixmaps
ZSH_COMPLETIONS := $(ZSH)/completions

# Ensure necessary paths exist
$(FONTS_DIR) \
	$(ALACRITTY_CONFIG_DIR) \
	$(BAT_CONFIG_DIR)/themes \
	$(BYOBU_CONFIG_DIR) \
	$(CARGO_HOME) \
	$(CARGO_ARTIFACTS_DIR) \
	$(FD_CONFIG_HOME) \
	$(GOPATH) \
	$(RIPGREP_CONFIG_HOME) \
	$(STACK_ROOT) \
	$(ZDOTDIR) \
	$(ZSH_COMPLETIONS) \
	$(ZSH_CUSTOM) \
	$(ZSH_CUSTOM)/plugins/base16-shell \
	$(ZSH_CUSTOM)/plugins/forgit \
	$(ZSH_CUSTOM)/plugins/poetry \
	$(XDG_BIN_HOME) \
	$(XDG_CACHE_HOME)/vm \
	$(XDG_CACHE_HOME)/zsh \
	$(XDG_CONFIG_HOME)/coc \
	$(XDG_CONFIG_HOME)/direnv \
	$(XDG_CONFIG_HOME)/git \
	$(XDG_CONFIG_HOME)/maven \
	$(XDG_CONFIG_HOME)/npm \
	$(XDG_CONFIG_HOME)/nvidia-settings \
	$(XDG_CONFIG_HOME)/nvim/lua \
	$(XDG_CONFIG_HOME)/nvim/scripts \
	$(XDG_CONFIG_HOME)/nvim/vim-plug \
	$(XDG_CONFIG_HOME)/pypoetry \
	$(XDG_CONFIG_HOME)/python \
	$(XDG_DATA_HOME)/npm \
	$(XDG_STATE_HOME)/nvim/spell:
	mkdir -p $@

$(APT_KEYRINGS) $(KEYRINGS_DIR) $(MAN1_DIR) $(PIXMAPS_DIR):
	sudo mkdir -p $@

$(XDG_CACHE_HOME)/vm/$(DEBIAN_ISO): ISO_URL := https://cdimage.debian.org/debian-cd/current/$(DIST_ARCH)/iso-cd
$(XDG_CACHE_HOME)/vm/$(DEBIAN_ISO): $(XDG_CACHE_HOME)/vm net-tools
	@echo ">>> Downloading Debian Buster net installer for x86_64" 
	@[ -f $@ ] || $(WGET) -O $@ $(ISO_URL)/$(DEBIAN_ISO)

DOCKER_CMD := $(shell command -v docker 2> /dev/null)

INTEL_CPU := $(shell egrep 'model name\s+: Intel' /proc/cpuinfo 2> /dev/null)

NVIDIA_CTRL := $(shell lspci | grep -i nvidia 2> /dev/null)

.PHONY: install-fonts
install-fonts: P10K_URL := https://github.com/romkatv/powerlevel10k-media/raw/master
install-fonts: $(FONTS_DIR)
	@echo ">>> Downloading Meslo Nerd Font for Powerlevel10k"
	curl "$(P10K_URL)/MesloLGS%20NF%20{Regular,Bold,Italic,Bold%20Italic}.ttf" \
		-o $</"MesloLGS NF #1.ttf"
	mv $</MesloLGS\ NF\ Bold%20Italic.ttf $</MesloLGS\ NF\ Bold\ Italic.ttf

# Resources:
#  - [Base16 Shell](https://github.com/tinted-theming/base16-shell)
.PHONY: base16-shell
base16-shell: BASE16_SHELL_REPO := https://github.com/tinted-theming/base16-shell.git
base16-shell: BASE16_THEME_DEFAULT := gruvbox-dark-hard
base16-shell: BASE16_THEME := gruvbox-dark-hard
base16-shell: zsh $(ZSH_CUSTOM)/plugins/base16-shell
	@echo ">>> Cloning Base16 Shell repository to '$(BASE16_SHELL_PATH)'"
	@git clone $(BASE16_SHELL_REPO) $(BASE16_SHELL_PATH)
	@echo ">>> Linking Base16 Shell OMZ plugin"
	@ln -svf $(BASE16_SHELL_PATH)/base16-shell.plugin.zsh \
		$(ZSH_CUSTOM)/plugins/base16-shell/base16-shell.plugin.zsh
	@echo ">>> Testing default Base16 color scheme"
	@$(BASE16_SHELL_PATH)/colortest
	@echo ">>> Select color scheme by running: 'base16_$(BASE16_THEME)'"

# Resources:
#  - [Base16 fzf](https://github.com/tinted-theming/base16-fzf)
.PHONY: base16-fzf
base16-fzf: BASE16_FZF_REPO := https://github.com/tinted-theming/base16-fzf.git
base16-fzf:
	@echo ">>> Cloning Base16 fzf repository to '$(BASE16_FZF_HOME)'"
	@git clone $(BASE16_FZF_REPO) $(BASE16_FZF_HOME)

.PHONY: links
links: \
	$(ALACRITTY_CONFIG_DIR) \
	$(BYOBU_CONFIG_DIR) \
	$(CARGO_HOME) \
	$(FD_CONFIG_HOME) \
	$(RIPGREP_CONFIG_HOME) \
	$(STACK_ROOT) \
	$(XDG_BIN_HOME) \
	$(XDG_CONFIG_HOME)/direnv \
	$(XDG_CONFIG_HOME)/git \
	$(XDG_CONFIG_HOME)/maven \
	$(XDG_CONFIG_HOME)/npm \
	$(XDG_CONFIG_HOME)/nvim/lua \
	$(XDG_CONFIG_HOME)/nvim/scripts \
	$(XDG_CONFIG_HOME)/nvim/vim-plug \
	$(XDG_CONFIG_HOME)/pypoetry \
	$(XDG_CONFIG_HOME)/python \
	$(ZDOTDIR) \
	$(ZSH_CUSTOM)
	@echo "Linking configuration files:"
	@ln -svft ~ $(CFG_DIR)/.zshenv
	@{ \
		for cfg in $$(find $(CFG_DIR)/.config $(CFG_DIR)/.local/share -type f); do \
			ln -svf $$cfg "$(HOME)$${cfg#$(CFG_DIR)}";\
		done;\
	}
	@ln -svft $(XDG_BIN_HOME) $(CFG_DIR)/.local/bin/*
	@echo "Making 'resolvectl' act as 'resolvconf': https://superuser.com/a/1544697"
	@sudo ln -svf /usr/bin/resolvectl /usr/local/bin/resolvconf
	@echo "Making 'g++' act as 'musl-g++': https://github.com/rust-lang/cargo/issues/3359"
	@sudo ln -svf /usr/bin/g++ /usr/bin/musl-g++
	@echo "Making 'lldb-vscode' point to 'lldb-vscode-15'"
	@sudo ln -svf /usr/bin/lldb-vscode-15 /usr/bin/lldb-vscode
	@echo "Finish Poetry setup by manually configuring auth tokens: https://bit.ly/3fdpMNR"

# Installed tools:
#  - libssl-dev: secure sockets layer toolkit
#  - pssh: asynchronous parallel SSH library (https://parallel-ssh.org)
.PHONY: net-tools
net-tools:
	@echo ">>> Installing basic network tools"
	sudo apt install -y curl jq net-tools ncat nmap wget libssl-dev pssh

# Installed tools:
#  - libfuse2: Filesystem in Userspace
#    [AppImage - FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE)
.PHONY: core-tools
core-utils:
	@echo ">>> Installing core utilities"
	sudo apt install -y git lsb-core moreutils libfuse2

.PHONY: apt-utils
apt-utils:
	@echo ">>> Installing utilities that let apt use packages over HTTPS"
	sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Installed tools:
#  - wl-clipboard: copy/paste utilities for Wayland
.PHONY: wl-utils
wl-utils:
	@echo ">>> Installing Wayland copy/paste utilities"
	sudo apt install -y wl-clipboard

# NOTE: python-is-python3 makes python available as python3
python:
	@echo ">>> Installing standard Python libraries"
	sudo apt install -y python3-pip python3-venv python-is-python3

# TODO: Possibly better option could be https://github.com/pyenv/pyenv
.PHONY: python3.6 python3.7 python3.8
python3.6 python3.7 python3.8: python
	@echo ">>> Installing $@"
	sudo add-apt-repository -y ppa:deadsnakes/ppa
	sudo apt update
	sudo apt install -y $@-dev $@-venv

# fzf: a command-line fuzzy finder
#  - https://github.com/junegunn/fzf
#  - Note: installs latest version, apt pkg might be quite old
#  - Note: `zoxide`'s interactive mode requires fzf at least v0.21.0
.PHONY: fzf
fzf: FZF_REPO := https://github.com/junegunn/fzf.git
fzf: core-utils $(XDG_BIN_HOME) $(MAN1_DIR)
ifneq ($(shell which fzf 2> /dev/null),)
	@echo ">>> Updating $@"
	git -C $(FZF_BASE) pull
else
	@echo ">>> Installing $@ to '$(FZF_BASE)'"
	git clone --depth 1 $(FZF_REPO) $(FZF_BASE)
endif
	$(FZF_BASE)/install --bin --no-update-rc
	@gzip -c $(FZF_BASE)/man/man1/fzf.1 | \
		sudo tee $(MAN1_DIR)/fzf.1.gz > /dev/null
	@gzip -c $(FZF_BASE)/man/man1/fzf-tmux.1 | \
		sudo tee $(MAN1_DIR)/fzf-tmux.1.gz > /dev/null

.PHONY: forgit
forgit: FORGIT_REPO := https://github.com/wfxr/forgit.git
forgit: zsh fzf $(ZSH_CUSTOM)/plugins/forgit
ifneq ($(wildcard $(ZSH_CUSTOM)/plugins/forgit/.),)
	@echo ">>> Updating $@"
	@git -C $(ZSH_CUSTOM)/plugins/$@ pull
else
	@echo ">>> Installing $@ to '$(ZSH_CUSTOM)/plugins/$@'"
	@git clone $(FORGIT_REPO) $(ZSH_CUSTOM)/plugins/$@
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"
endif

# lesspipe.sh: display more with less (https://github.com/wofr06/lesspipe)
#  - Note: lesspipe.sh is installed system-wide and thus requires sudo
.PHONY: lesspipe
lesspipe: LESSPIPE_REPO := wofr06/lesspipe
lesspipe: LESSPIPE_DIR := $(shell mktemp -d)
lesspipe: net-tools
	@curl -sSL "$$(gh_latest_release --tar $(LESSPIPE_REPO))" | \
		tar -xzf - --strip-components=1 -C $(LESSPIPE_DIR)
ifneq ($(shell which zsh),)
	cd $(LESSPIPE_DIR) && \
		./configure --shell=$(shell which zsh) && \
		sudo make install
else
	cd $(LESSPIPE_DIR) && ./configure && sudo make install
endif
	@rm -rf "$(LESSPIPE_DIR)"

# TODO: non-snap installation, man page
# Resources:
#  - https://github.com/neovim/neovim/wiki/Installing-Neovim
#  - https://linuxhint.com/vim_spell_check
# Notes:
#  - PPA repository contains an quite old stable release compared to GitHub and
#    Snap (Neovim team does not maintain the PPA packages)
.PHONY: neovim
neovim: $(XDG_STATE_HOME)/nvim/spell
	@echo ">>> Installing $@"
	sudo snap install --beta nvim --classic
	touch $(XDG_STATE_HOME)/nvim/spell/en-utf-8.add

# Installed tools:
#  - coz-profiler: Coz: Causal Profiling (https://github.com/plasma-umass/coz)
#  - git-lfs: Git extension for versioning large files (https://git-lfs.com)
#  - entr: Run arbitrary commands when files change
#    (https://github.com/eradman/entr)
#  - fzf: A command-line fuzzy finder (https://github.com/junegunn/fzf)
#  - heaptrack(-gui): A heap memory profiler for Linux
#    (https://github.com/KDE/heaptrack)
#  - chafa: Image visualization for terminal (https://hpjansson.org/chafa/)
#  - libglpk-dev glpk-*: GLPK toolkit (https://www.gnu.org/software/glpk/) 
#  - libecpg-dev: Postgres instegrations
#  - libimage-exiftool-perl: library and program to read and write meta
#    information in multimedia files (https://exiftool.org)
#  - lldb-15: High-performance debugger (https://lldb.llvm.org)
#  - neofetch: A command-line system information tool
#    (https://github.com/dylanaraps/neofetch)
#  - tshark: Terminal version of wireshark
#  - musl-tools: tools for cross-compilation to musl target
#  - capnproto, libcapnp-dev: Cap'N Proto compiler tools (https://capnproto.org)
#  - protobuf-compiler: `protoc`, compiler for protocol buffer definition files
#    (https://github.com/protocolbuffers/protobuf)
#  - wireguard: fast, modern, secure VPN tunnel (https://www.wireguard.com)
.PHONY: basic-tools
basic-tools: net-tools core-utils apt-utils wl-utils fzf neovim
	@echo ">>> Installing basic tools"
	sudo apt install -y \
		git-lfs \
 		htop \
		iotop \
		iftop \
		tshark \
		neofetch \
		mc \
		tmux \
		byobu \
		tree \
		entr \
		chafa \
		gparted \
		gnome-tweaks \
		blueman \
		mypaint \
		tlp \
		dos2unix \
		pandoc \
		direnv \
		graphviz \
		libzstd-dev \
		libecpg-dev \
		libglpk-dev \
		libimage-exiftool-perl \
		glpk-utils \
		glpk-doc \
		musl-tools \
		lldb-15 \
		heaptrack \
		heaptrack-gui \
		coz-profiler \
		valgrind \
		capnproto \
		libcapnp-dev \
		protobuf-compiler \
		wireguard

# FIXME: Use CPU_MODEL instead of plain 'intel' in sed replacement
# Resources:
#  - [Simple tutorial](https://phoenixnap.com/kb/ubuntu-install-kvm)
#  - [Comprehensive guide](https://bit.ly/339BtPT)
# Notes:
#  - [IOMMU GRUB fix](https://serverfault.com/a/633322)
#  - The other WARN should be fine: https://stackoverflow.com/q/65207563
.PHONY: kvm
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
.PHONY: test-kvm
test-kvm: $(XDG_CACHE_HOME)/vm/$(DEBIAN_ISO)
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
		--cdrom $< \
		--disk path=$(<D)/debian_buster.img,bus=virtio,size=40 \
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
	sudo rm -f $(<D)/debian_buster.img
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
.PHONY: k8s
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
	binenv install kubectl-krew
	@echo ">>> Installing kvm2 driver: https://minikube.sigs.k8s.io/docs/drivers/kvm2/"
	curl -L -o "/tmp/$(KVM2_DRIVER)" "$(KVM2_DRIVER_URL)/$(KVM2_DRIVER)" \
		&& sudo install "/tmp/$(KVM2_DRIVER)" /usr/local/bin/
	@echo ">>> Starting minikube"
	minikube start --cpus 2 --memory 2048 --vm-driver kvm2
	minikube status
	@echo ">>> Installing and initializing helm: https://helm.sh/docs/"
	binenv install helm
	@echo ">>> Installing helm-operator: https://github.com/fluxcd/helm-operator"
	binenv install helm-operator
	@echo ">>> Installing kubectx: https://github.com/ahmetb/kubectx"
	kubectl krew install ctx
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
.PHONY: test-k8s
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

# Installation resources:
#  - https://github.com/devops-works/binenv#linux-bashzsh
# 
# TODO: Verify (gpg) the signature of the checksum file if binenv releases one.
.PHONY: binenv
binenv: BINENV_URL := https://github.com/devops-works/binenv/releases/latest/download
binenv: BINENV_BIN := binenv_linux_$(DIST_ARCH)
binenv: DOWNLOAD_DIR := $(shell mktemp -d)
binenv: $(ZSH_COMPLETIONS) net-tools
ifneq ($(shell which binenv 2> /dev/null),)
	@echo ">>> $@ already installed to '$(BINENV_HOME)'"
else
	@echo ">>> Downloading $@"
	$(WGET) -q -P $(DOWNLOAD_DIR) \
		"$(BINENV_URL)/$(BINENV_BIN)" \
		"$(BINENV_URL)/checksums.txt"
	@echo ">>> Verifying dowloaded $@ file integrity"
	@(cd $(DOWNLOAD_DIR) && \
		sha256sum -c --strict --status --ignore-missing checksums.txt) || \
		(echo ">>> Failed to verify checksum" && rm -rf $(DOWNLOAD_DIR) && exit 1)
	@echo ">>> Installing $@"
	@chmod +x "$(DOWNLOAD_DIR)/$(BINENV_BIN)"
	"$(DOWNLOAD_DIR)/$(BINENV_BIN)" update
	"$(DOWNLOAD_DIR)/$(BINENV_BIN)" install $@
	@echo ">>> Generating zsh completions for $@"
	$@ completion zsh > $</_$@
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"
endif
	@rm -rf $(DOWNLOAD_DIR)

# Installed tools:
#  - duf: Disk Usage/Free Utility - a better 'df' alternative
#    (https://github.com/muesli/duf)
.PHONY: binenv-tools
binenv-tools: DUF_URL := https://github.com/muesli/duf/archive/refs/tags
binenv-tools: binenv $(MAN1_DIR)
	@echo ">>> Installing duf: https://github.com/muesli/duf"
	binenv install duf
	@curl -sSL "$(DUF_URL)/v$$(duf -version | cut -d ' ' -f2).tar.gz" | \
		tar -xzf - --strip-components=1 --wildcards '*/duf.1' --to-command=gzip | \
		sudo tee $(MAN1_DIR)/duf.1.gz > /dev/null

# Installation resources:
#  - https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH
#  - https://github.com/ohmyzsh/ohmyzsh#custom-directory
#  - https://github.com/ohmyzsh/ohmyzsh/issues/9543
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
# Themes:
#  - https://github.com/romkatv/powerlevel10k
# Plugins:
#  - https://github.com/zsh-users/zsh-syntax-highlighting
#  - https://github.com/zsh-users/zsh-history-substring-search
#  - https://github.com/zsh-users/zsh-autosuggestions
.PHONY: zsh
zsh: $(XDG_CACHE_HOME)/zsh core-utils net-tools
ifneq ($(shell which zsh 2> /dev/null),)
	@echo ">>> zsh already installed"
else
	@echo ">>> Installing zsh and oh-my-zsh"
	sudo apt install -y $@
	$@ --version
	sh -c "$$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	sudo chsh -s $$(which $@)
	@echo ">>> Setting up powerlevel10k theme"
	git clone \
		https://github.com/romkatv/powerlevel10k.git \
		$(ZSH_CUSTOM)/themes/powerlevel10k
	sudo apt install -y fonts-powerline
	@echo ">>> Installing zsh plugins"
	git clone \
		https://github.com/zsh-users/zsh-syntax-highlighting.git \
		$(ZSH_CUSTOM)/plugins/zsh-syntax-highlighting
	git clone \
		https://github.com/zsh-users/zsh-history-substring-search \
		$(ZSH_CUSTOM)/plugins/zsh-history-substring-search
	git clone \
		https://github.com/zsh-users/zsh-autosuggestions \
		$(ZSH_CUSTOM)/plugins/zsh-autosuggestions
endif

# Installation resources:
#  - https://github.com/bash-lsp/bash-language-server 
.PHONY: snaps
snaps: golang 
	@echo ">>> Installing cmake"
	sudo snap install --classic cmake
	@echo ">>> Installing bash-language-server"
	sudo snap install --classic bash-language-server
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

.PHONY: pipx
pipx: python
ifneq ($(shell which pipx 2> /dev/null),)
	@echo ">>> $@ already installed, upgrading to the latest version"
	python3 -m pip install --user $@ --upgrade
	python3 -m $@ ensurepath
	@echo ">>> Using $@ $$($@ --version)"
else
	@echo ">>> Installing $@"
	python3 -m pip install --user $@
	python3 -m $@ ensurepath
endif

.PHONY: python-tools
python-tools: OPS :=
python-tools: pipx
	@echo ">>> Installing Python virtual environment"
	pipx install virtualenv $(OPS)
	@echo ">>> Installing Ansible: https://www.ansible.com"
	pipx install --include-deps ansible
	@echo ">>> Installing AWS CLI"
	pipx install awscli $(OPS)
	@echo ">>> Installing pre-commit hooks globally"
	pipx install pre-commit $(OPS)
	@pre-commit init-templatedir $(GIT_TEMPLATE_DIR)
#	@echo ">>> Installing WPS: https://wemake-python-stylegui.de/"
#	pipx install wemake-python-styleguide --include-deps $(OPS)
	@echo ">>> Installing pycobertura: https://github.com/aconrad/pycobertura"
	pipx install pycobertura
	@echo ">>> Installing sqlfluff: https://github.com/sqlfluff/sqlfluff"
	pipx install sqlfluff
	@echo ">>> Installing Kaggle API: https://github.com/Kaggle/kaggle-api"
	pipx install kaggle $(OPS)
	@echo ">>> Installing gdbgui: https://www.gdbgui.com"
	pipx install gdbgui
	@echo ">>> Installing yamllint: https://github.com/adrienverge/yamllint"
	pipx install yamllint

# Installation resources:
#  - https://python-poetry.org/docs/#installation
#  - https://python-poetry.org/docs/#enable-tab-completion-for-bash-fish-or-zsh
.PHONY: poetry
poetry: python zsh $(ZSH_CUSTOM)/plugins/poetry
ifneq ($(shell which poetry 2> /dev/null),)
	@echo ">>> $$($@ --version) already installed"
else
	@echo ">>> Installing Poetry: https://python-poetry.org/docs/"
	curl -sSL https://install.python-poetry.org | python3 -
	$@ self update
	$@ completions zsh > $(ZSH_CUSTOM)/plugins/poetry/_poetry
endif

# Installation resources:
#  - https://sdkman.io/install
#  - https://github.com/matthieusb/zsh-sdkman#installation
#  - Note: Installation won't update rc files since we're using custom `.zshrc`
#    and `.zshenv`
.PHONY: sdk
sdk: SHELL := /bin/bash
sdk: ZSH_SDKMAN_REPO := https://github.com/matthieusb/zsh-sdkman.git
sdk: net-tools zsh
	@echo ">>> Installing SDKMAN: https://sdkman.io/"
	curl -s "https://get.sdkman.io?rcupdate=false" | bash
	source $(SDKMAN_DIR)/bin/sdkman-init.sh
	@echo ">>> Installing zsh-sdkman: https://github.com/matthieusb/zsh-sdkman"
	git clone $(ZSH_SDKMAN_REPO) $(ZSH_CUSTOM)/plugins/zsh-sdkman

.PHONY: jvm-tools
jvm-tools: SHELL := /bin/bash
jvm-tools: $(SDKMAN_DIR)/bin/sdkman-init.sh
	@{ \
		set -e;\
		source $(SDKMAN_DIR)/bin/sdkman-init.sh;\
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
		echo ">>> Installing VisualVM";\
		sdk install visualvm;\
	}

# Haskell toolchain and project builder
#  - [ghcup](https://www.haskell.org/ghcup/)
#  - [stack](https://docs.haskellstack.org/en/stable/README/)
# Additional notes:
#  - ghcup also installs the Haskell Language Server and Stack
#  - ghcup-zsh instegration is already present in .zshrc
.PHONY: haskell
haskell: ghcup

.PHONY: ghcup-deps
ghcup-deps: net-tools
	@echo ">>> Installing ghcup distro packages"
	sudo apt install -y \
		build-essential \
		curl \
		libffi-dev \
		libffi7 \
		libgmp-dev \
		libgmp10 \
		libncurses-dev \
		libncurses5 \
		libtinfo5

.PHONY: ghcup
ghcup: GHCUP_URL := https://gitlab.haskell.org/haskell/ghcup-hs
ghcup: $(ZSH_COMPLETIONS) ghcup-deps
ifneq ($(shell which ghcup 2> /dev/null),)
	@echo ">>> $$($@ --version) already installed"
else
	@echo ">>> Installing Haskell toolchain installer"
	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
	@echo ">>> Dowloading zsh completions for $@"
	curl -sSL -o $</_$@ \
		"$(GHCUP_URL)/-/raw/v$$($@ --numeric-version)/shell-completions/zsh"
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"
endif

# Installed tools:
#  - brittany: Haskell source code formatter
#  - hlint: Haskell source code suggestions
#  - apply-refact: Refactor Haskell source files
#  - data-tree-print: Installed as a brittany dependency
.PHONY: haskell-tools
haskell-tools: haskell
	@echo ">>> Installing brittany: https://github.com/lspitzner/brittany/"
	stack install data-tree-print brittany
	@echo ">>> Installing hlint: https://github.com/ndmitchell/hlint"
	stack install hlint apply-refact

.PHONY: rust
rust: net-tools
ifeq ($(shell which rustc 2> /dev/null),)
	@echo ">>> Installing Rust toolchain"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	. $(HOME)/.cargo/env
	@echo ">>> Installing Rust nightly toolchain"
	rustup install nightly
	@echo ">>> Installing rust-src"
	rustup component add rust-src
	@echo ">>> Installing rust-analyzer"
	rustup component add rust-analyzer
endif
	rustup show

.PHONY: cargo-tools
cargo-tools: rust
	@echo ">>> Installing cargo-readme: https://crates.io/crates/cargo-readme"
	cargo install cargo-readme
	@echo ">>> Installing cargo-expand: https://crates.io/crates/cargo-expand"
	cargo install cargo-expand
	@echo ">>> Installing cargo-nextest: https://crates.io/crates/cargo-nextest"
	cargo install cargo-nextest
	@echo ">>> Installing criterion: https://crates.io/crates/cargo-criterion"
	cargo install cargo-criterion
	@echo ">>> Installing cargo-hack: https://crates.io/crates/cargo-hack"
	cargo install cargo-hack
	@echo ">>> Installing cargo-deny: https://crates.io/crates/cargo-deny"
	cargo install --locked cargo-deny
	@echo ">>> Installing cargo-auditable: https://github.com/rust-secure-code/cargo-auditable"
	cargo install cargo-auditable
	@echo ">>> Installing cargo-audit: https://crates.io/crates/cargo-audit"
	cargo install cargo-audit --features=fix
	@echo ">>> Installing cargo-vet: https://github.com/mozilla/cargo-vet"
	cargo install --locked cargo-vet
	@echo ">>> Installing cargo-tarpaulin: https://github.com/xd009642/tarpaulin"
	cargo install cargo-tarpaulin
	@echo ">>> Installing cargo-llvm-cov: https://github.com/taiki-e/cargo-llvm-cov"
	cargo install cargo-llvm-cov --locked
	rustup component add llvm-tools-preview --toolchain nightly
	@echo ">>> Installing cargo-llvm-lines: https://github.com/dtolnay/cargo-llvm-lines"
	cargo install cargo-llvm-lines
	@echo ">>> Installing cargo-outdated: https://github.com/kbknapp/cargo-outdated"
	cargo install --locked cargo-outdated
	@echo ">>> Installing cargo-udeps: https://github.com/est31/cargo-udeps"
	cargo install --locked cargo-udeps
	@echo ">>> Installing cargo-bloat: https://github.com/RazrFalcon/cargo-bloat"
	cargo install cargo-bloat
	@echo ">>> Installing cargo-watch: https://github.com/watchexec/cargo-watch"
	cargo install cargo-watch
	@echo ">>> Installing cargo-deb: https://github.com/kornelski/cargo-deb"
	cargo install cargo-deb
	@echo ">>> Installing cargo-modules: https://github.com/regexident/cargo-modules"
	cargo install cargo-modules
	@echo ">>> Installing cargo-workspaces: https://github.com/pksunkara/cargo-workspaces"
	cargo install cargo-workspaces
	@echo ">>> Installing cargo-msrv: https://github.com/foresterre/cargo-msrv"
	cargo install cargo-msrv

# Installed tools:
#  - bat: A cat(1) clone with wings (https://github.com/sharkdp/bat)
#  - click: Command Line Interactive Controller for Kubernetes
#  - eza: A modern, maintained replacement for 'ls'
#    (https://github.com/eza-community/eza)
#  - fd: A simple, fast and user-friendly alternative to 'find'
#    (https://github.com/sharkdp/fd)
#  - git-delta: A syntax-highlighting pager for git, diff, and grep output
#    (https://github.com/dandavison/delta)
#  - gping: Ping, but with a graph (https://github.com/orf/gping)
#  - hexyl: A command-line hex viewer (https://github.com/sharkdp/hexyl)
#  - hyperfine: A command-line benchmarking tool
#    (https://github.com/sharkdp/hyperfine)
#  - junitify: takes JSON tests from stdin and writes JUnit XML
#    (https://gitlab.com/Kores/junitify)
#  - just: Just a command runner / simplified make
#    (https://github.com/casey/just)
#  - mcfly: an upgraded ctrl-r where history results make sense for what you're
#    working on right now (https://github.com/cantino/mcfly)
#  - mdbook: Build a book from Markdown files
#    (https://github.com/rust-lang/mdBook)
#  - procs: A modern replacement for ps written in Rust
#    (https://github.com/dalance/procs)
#  - proximity-search: Simple command-line utility for sorting inputs by
#    proximity to a path argument (https://github.com/jonhoo/proximity-sort)
#  - ripgrep: Recursively searches directories for a regex pattern
#    (https://github.com/BurntSushi/ripgrep)
#  - samply: Command-line sampling profiler for macOS and Linux
#    (https://github.com/mstange/samply)
#  - sd: Intuitive find & replace CLI (sed alternative)
#    (https://github.com/chmln/sd)
#  - tokio-console: A debugger for async Rust
#    (https://github.com/tokio-rs/console) 
#  - xh: Friendly and fast tool for sending HTTP requests
#    (https://github.com/ducaale/xh)
#  - zoxide: A smarter cd command (https://github.com/ajeetdsouza/zoxide)
.PHONY: rust-tools
rust-tools: CRATES_SRC := $(CARGO_HOME)/registry/src/index.crates.io-6f17d22bba15001f
rust-tools: zsh rust $(CARGO_ARTIFACTS_DIR) $(MAN1_DIR)
	@echo ">>> Installing bat: https://github.com/sharkdp/bat"
	env BAT_ASSETS_GEN_DIR=$(CARGO_ARTIFACTS_DIR) cargo install --locked bat
	@gzip -c "$(CARGO_ARTIFACTS_DIR)/assets/manual/bat.1" \
		| sudo tee $(MAN1_DIR)/bat.1.gz > /dev/null
	@cp "$(CARGO_ARTIFACTS_DIR)/assets/completions/bat.zsh" "$(ZSH_COMPLETIONS)/_bat"
	@echo ">>> Installing eza: https://eza.rocks"
	cargo install eza
	@cp "$(CRATES_SRC)/eza-$$(eza -v | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')/completions/zsh/_eza" "$(ZSH_COMPLETIONS)/_eza"
	@pandoc  -s -t man \
		$(CRATES_SRC)/eza-$$(eza -v | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')/man/eza.1.md \
		| gzip -c \
		| sudo tee $(MAN1_DIR)/eza.1.gz > /dev/null
	@echo ">>> Installing dust: https://github.com/bootandy/dust"
	cargo install du-dust
	@echo ">>> Installing fd: https://github.com/sharkdp/fd"
	cargo install fd-find
	@echo ">>> Installing git-delta: https://github.com/dandavison/delta"
	cargo install git-delta
	@echo ">>> Installing gping: https://github.com/orf/gping"
	cargo install gping
	@echo ">>> Installing hexyl: https://github.com/sharkdp/hexyl"
	cargo install hexyl
	@pandoc  -s -f markdown -t man \
		$(CRATES_SRC)/$$(hexyl --version | sed 's| |-|g')/doc/hexyl.1.md \
		| gzip -c \
		| sudo tee $(MAN1_DIR)/hexyl.1.gz > /dev/null
	@echo ">>> Installing hyperfine: https://github.com/sharkdp/hyperfine"
	env SHELL_COMPLETIONS_DIR=$(CARGO_ARTIFACTS_DIR) cargo install hyperfine
	@cp "$(CARGO_ARTIFACTS_DIR)/_hyperfine" $(ZSH_COMPLETIONS)
	@gzip -c $(CRATES_SRC)/$$(hyperfine --version | sed 's| |-|g')/doc/hyperfine.1 \
		| sudo tee $(MAN1_DIR)/hyperfine.1.gz > /dev/null
	@echo ">>> Installing junitify: https://gitlab.com/Kores/junitify"
	cargo install junitify
	@echo ">>> Installing just: https://github.com/casey/just"
	cargo install just
	@just --completions zsh > "$(ZSH_COMPLETIONS)/_just"
	@gzip -c "$(CRATES_SRC)/$$(just --version | sed 's| |-|g')/man/just.1" | \
		sudo tee $(MAN1_DIR)/just.1.gz > /dev/null
	@echo ">>> Installing mcfly: https://github.com/cantino/mcfly"
	cargo install mcfly
	@echo ">>> Installing mdbook: https://github.com/rust-lang/mdBook"
	cargo install mdbook
	@echo ">>> Installing procs: https://github.com/dalance/procs"
	cargo install procs
	@procs --gen-completion-out zsh > "$(ZSH_COMPLETIONS)/_procs"
	@echo ">>> Installing proximity-search: https://github.com/jonhoo/proximity-sort"
	cargo install proximity-sort
	@echo ">>> Installing click: https://github.com/databricks/click"
	cargo install click
	@echo ">>> Installing ripgrep: https://github.com/BurntSushi/ripgrep"
	cargo install ripgrep
	@rg --generate complete-zsh > "$(ZSH_COMPLETIONS)/_rg"
	@rg --generate man | gzip -c | sudo tee $(MAN1_DIR)/rg.1.gz > /dev/null
	@echo ">>> Installing samply: https://github.com/mstange/samply"
	cargo install samply
	@echo ">>> Installing sd: https://github.com/chmln/sd"
	cargo install sd
	@cp "$(CRATES_SRC)/$$(sd -V | sd ' ' -)/gen/completions/_sd" $(ZSH_COMPLETIONS)
	@gzip -c "$(CRATES_SRC)/$$(sd -V | sd ' ' -)/gen/sd.1" \
		| sudo tee $(MAN1_DIR)/sd.1.gz > /dev/null
	@echo ">>> Installing tokio-console: https://github.com/tokio-rs/console"
	cargo install --locked tokio-console
	@tokio-console gen-completion zsh > "$(ZSH_COMPLETIONS)/_tokio-console"
	@echo ">>> Installing xh: https://github.com/ducaale/xh"
	cargo install xh
	@cp "$(CRATES_SRC)/$$(xh -V | sed 's| |-|g')/completions/_xh" $(ZSH_COMPLETIONS)
	@gzip -c "$(CRATES_SRC)/$$(xh -V | sed 's| |-|g')/doc/xh.1" | \
		sudo tee $(MAN1_DIR)/xh.1.gz > /dev/null
	@echo ">>> Installing zoxide: https://github.com/ajeetdsouza/zoxide"
	cargo install zoxide --locked
	@gzip -c "$(CRATES_SRC)/$$(zoxide -V | sed 's| |-|g')/man/man1/zoxide.1" | \
		sudo tee $(MAN1_DIR)/zoxide.1.gz > /dev/null

# Resources:
#  - https://github.com/alacritty/alacritty/blob/master/INSTALL.md#dependencies
.PHONY: alacritty
alacritty: DOWNLOAD_URL := https://github.com/alacritty/alacritty/releases/download
alacritty: DOWNLOAD_DIR := $(shell mktemp -d)
alacritty: $(ALACRITTY_CONFIG_DIR) $(MAN1_DIR) $(PIXMAPS_DIR) $(ZSH_COMPLETIONS) net-tools rust
ifeq ($(shell which alacritty 2> /dev/null),)
	@echo ">>> Installing $@ dependencies: https://github.com/alacritty/alacritty"
	@sudo apt install -y \
		pkg-config \
		libfreetype6-dev \
		libfontconfig1-dev \
		libxcb-xfixes0-dev \
		libxkbcommon-dev
	@echo ">>> Configuring $@"
	@{ \
		for cfg in $$(find $(CFG_DIR)/.config/$@ -type f); do \
			ln -svf $$cfg "$(HOME)$${cfg#$(CFG_DIR)}";\
		done;\
	}
else
	@echo ">>> Updating $@: https://github.com/alacritty/alacritty"
endif
	@cargo install $@
	@echo ">>> Fetching release assets for $$($@ -V)"
	@curl -sLO --output-dir $(DOWNLOAD_DIR) \
		"$(DOWNLOAD_URL)/v$$($@ -V | awk {'print $$2'})/{$@.1.gz,_$@,$@.info,Alacritty.desktop,Alacritty.svg}"
	@echo ">>> Configuring $@ terminfo"
	@sudo tic -xe $@,$@-direct "$(DOWNLOAD_DIR)/$@.info"
	@echo ">>> Configuring $@ desktop entry"
	@sudo mv "$(DOWNLOAD_DIR)/Alacritty.svg" $(PIXMAPS_DIR)
	@sudo desktop-file-install "$(DOWNLOAD_DIR)/Alacritty.desktop"
	@sudo update-desktop-database
	@echo ">>> Configuring $@ man pages"
	@sudo mv "$(DOWNLOAD_DIR)/$@.1.gz" $(MAN1_DIR)
	@echo ">>> Configuring $@ zsh completions"
	@mv "$(DOWNLOAD_DIR)/_$@" $(ZSH_COMPLETIONS)
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"
	@rm -rf $(DOWNLOAD_DIR)

# Notes:
#  - Configures the toggle button to be F1
#  - Gnome session must be restarted to pick up the extension, so one has to
#    reboot (or logout & login) and re-run this target to finish the setup
#
# TODO
#  - enable the extension without restarting Gnome session
.PHONY: alacritty-toggle
alacritty-toggle: EXT_REPO := https://github.com/axxapy/gnome-alacritty-toggle
alacritty-toggle: EXT_NAME := toggle-alacritty@itstime.tech
alacritty-toggle: EXT_HOME := $(XDG_DATA_HOME)/gnome-shell/extensions/$(EXT_NAME)
alacritty-toggle: EXT_SCHEMA := org.gnome.shell.extensions.toggle-alacritty
alacritty-toggle:
	@echo ">>> Configuring $@: $(EXT_REPO)"
	@git clone $(EXT_REPO) $(EXT_HOME) 2>/dev/null || true
	@echo ">>> Validating the integrity of compiled $@ schemas"
	@glib-compile-schemas $(EXT_HOME)/schemas && \
		git -C $(EXT_HOME) status --porcelain --untracked-files=no
	@gsettings --schemadir $(EXT_HOME)/schemas \
		set $(EXT_SCHEMA) toggle-key "['F1']"
	@gsettings --schemadir $(EXT_HOME)/schemas \
		set $(EXT_SCHEMA) command $$(which alacritty)
	@gnome-extensions enable $(EXT_NAME) || \
		echo ">>> Restart Gnome session (logout & login) and run this command again"

# Resources:
#  - https://github.com/vercel/install-node
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
# TODO: migrate to https://github.com/nvm-sh/nvm
.PHONY: nodejs
nodejs: VERSION := lts
nodejs: $(XDG_DATA_HOME)/npm net-tools
	@echo ">>> Installing nodejs (LTS)"
	sudo curl -sL install-node.now.sh/$(VERSION) | \
		sudo bash -s -- --prefix="$(XDG_DATA_HOME)/npm" -y

# Install or update pyright globally form a npm package
#  - https://microsoft.github.io/pyright/#/installation?id=npm-package
.PHONY: pyright
pyright:
ifneq ($(shell which pyright 2> /dev/null),)
	@echo ">>> $@ already installed, updating..."
	npm update -g $@
else
	make nodejs
	@echo ">>> Installing $@: https://microsoft.github.io/pyright"
	npm install -g $@
endif

# Install ruby using apt instead of snap
#  - With ruby from snap, `gem install` does not respect cusom `$GEM_HOME` even
#    with `--no-user-install`, see: https://stackoverflow.com/a/70101849 
#  - https://www.ruby-lang.org/en/documentation/installation
#  - TODO: try https://www.ruby-lang.org/en/documentation/installation/#rbenv
.PHONY: ruby
ruby:
	@echo ">>> Installing Ruby"
	sudo apt install -y $@-full

.PHONY: golang
golang: $(GOPATH)
	@echo ">>> Installing Go"
	sudo snap install --classic go

# Formatter for shell programs
#  - used by `prettybat` from [bat-extras](https://github.com/eth-p/bat-extras)
.PHONY: shfmt
shfmt: SHFMT_MOD := mvdan.cc/sh
shfmt: SHFMT_API := v3
shfmt: SHFMT_TAG := latest
shfmt: golang $(MAN1_DIR)
	@echo ">>> Installing $@: https://github.com/mvdan/sh"
	go install "$(SHFMT_MOD)/$(SHFMT_API)/cmd/$@@$(SHFMT_TAG)"
	@pandoc -s -t man \
		"$(GOPATH)/pkg/mod/$(SHFMT_MOD)/$(SHFMT_API)@$$($@ --version)/cmd/$@/$@.1.scd" | \
		gzip -c | \
		sudo tee $(MAN1_DIR)/$@.1.gz > /dev/null

# Makefile linter
#
# TODO: man pages
.PHONY: checkmake
checkmake: CHECKMAKE_TAG := latest
checkmake: golang
	@echo ">>> Installing $@: https://github.com/mrtazz/checkmake"
	go install "github.com/mrtazz/checkmake/cmd/$@@$(CHECKMAKE_TAG)"

# Fast cross-platform HTTP benchmarking tool
.PHONY: bombardier
bombardier: BOMBARDIER_TAG := latest
bombardier: golang
	@echo ">>> Installing $@: https://github.com/codesenberg/bombardier"
	go install "github.com/codesenberg/$@@$(BOMBARDIER_TAG)"

# Like cURL, but for gRPC
.PHONY: grpcurl
grpcurl: GRPCURL_TAG := latest
grpcurl: golang
	@echo ">>> Installing $@: https://github.com/fullstorydev/grpcurl"
	go install "github.com/fullstorydev/grpcurl/cmd/grpcurl@$(GRPCURL_TAG)"

# Installtion resources:
#  - [Official documentation](https://docs.docker.com/engine/install/ubuntu/)
#  - [Official post-instegration](https://docs.docker.com/engine/install/linux-postinstall/)
.PHONY: docker
docker: DOCKER_URL := https://download.docker.com/linux/ubuntu
docker: DOCKER_GPG := $(KEYRINGS_DIR)/docker-archive-keyring.gpg
docker: core-utils apt-utils $(KEYRINGS_DIR)
	@echo ">>> Installing Docker: https://docs.docker.com/engine/install/ubuntu/"
	@echo ">>> Downloading GPG key as '$(DOCKER_GPG)' and configuring apt sources"
	curl -fsSL $(DOCKER_URL)/gpg | gpg --dearmor | sudo tee $(DOCKER_GPG) > /dev/null
	echo "deb [arch=$(DIST_ARCH) signed-by=$(DOCKER_GPG)] $(DOCKER_URL) $$(lsb_release -cs) stable" \
		| sudo tee /etc/apt/sources.list.d/$@.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	@echo ">>> Setting up '$@' user group with current user '$(USER)'"
	sudo groupadd -f $@
	sudo gpasswd -a $(USER) $@
	sudo usermod -aG $@ $(USER)
	@echo ">>> Configuring Docker to start on boot"
	sudo systemctl enable $@.service
	sudo systemctl enable containerd.service
	@echo ">>> Finishing Docker installation"
	sudo service $@ restart
	newgrp $@

# NOTE: This target installs docker-compose using pipx for easier version handling.
.PHONY: docker-compose
docker-compose:
ifneq ($(shell which docker-compose 2> /dev/null),)
	@echo ">>> Already installed $$($@ --version)"
else
	@echo ">>> Installing $@: https://docs.docker.com/compose/install/"
	pipx install $@
endif

.PHONY: test-docker
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
.PHONY: nvidia-docker
nvidia-docker: NVIDIA_DOCKER_PKG := nvidia-docker2
nvidia-docker: NVIDIA_DOCKER_URL := https://nvidia.github.io/nvidia-docker
nvidia-docker: NVIDIA_DOCKER_GPG := $(KEYRINGS_DIR)/nvidia-docker-archive-keyring.gpg
nvidia-docker: DOCKERD_CFG := /etc/docker/daemon.json
nvidia-docker: core-utils net-tools apt-utils $(KEYRINGS_DIR)
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

# TODO: fetch latest version, shell completions, man page
# Hadolint: Dockerfile linter
.PHONY: hadolint
hadolint: REPO_URL := https://github.com/hadolint/hadolint
hadolint: VERSION := 2.12.0
hadolint: net-tools
	@echo ">>> Downloading $@ from $(REPO_URL)"
	$(WGET) -q \
		-O $(XDG_BIN_HOME)/$@ \
		$(REPO_URL)/releases/download/v$(VERSION)/$@-Linux-$(ARCH)
	@chmod +x $(XDG_BIN_HOME)/$@
	@echo ">>> Installed: $$($@ -v)"

# ClickHouse
#  - https://clickhouse.com/docs/en/integrations/sql-clients/cli/
#  - https://clickhouse.com/docs/en/integrations/sql-clients/clickhouse-client-local/
.PHONY: clickhouse
clickhouse: CLICKHOUSE_URL:= https://clickhouse.com/
clickhouse: INSTALL_DIR := $(XDG_BIN_HOME)
clickhouse: net-tools
ifneq ($(shell which clickhouse 2> /dev/null),)
	@echo ">>> $@ already installed"
else
	@echo ">>> Installing or upgrading ClickHouse Client"
	@cd $(INSTALL_DIR) && curl $(CLICKHOUSE_URL) | sh && cd -
	@echo ">>> Using $$($@ client --version)"
endif

# GitHub CLI (https://cli.github.com)
#  - https://github.com/cli/cli/blob/trunk/docs/install_linux.md
.PHONY: gh
gh: GH_URL := https://cli.github.com/packages
gh: GH_GPG := $(KEYRINGS_DIR)/githubcli-archive-keyring.gpg
gh: zsh $(KEYRINGS_DIR)
ifneq ($(shell which gh 2> /dev/null),)
	@echo ">>> $@ already installed"
else
	@echo ">>> Installing Github CLI: https://cli.github.com"
	@curl -fsSL $(GH_URL)/githubcli-archive-keyring.gpg | sudo dd of=$(GH_GPG)
	sudo chmod go+r $(GH_GPG)
	echo "deb [arch=$(DIST_ARCH) signed-by=$(GH_GPG)] $(GH_URL) stable main" | \
		sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
	sudo apt update
	sudo apt install -y $@
	@echo ">>> Installed $$($@ --version)"
endif

# Note: `--no-user-install` forces gem to respect `$GEM_HOME`
.PHONY: travis
travis: ruby
	@echo ">>> Installing Travis CLI: https://github.com/travis-ci/travis.rb"
	gem install $@ --no-document --no-user-install

.PHONY: aws-vault
aws-vault: binenv
	@echo ">>> Installing $@: https://github.com/99designs/aws-vault"
	@binenv update
	binenv install $@
	
.PHONY: set-swappiness
set-swappiness: SWAPPINESS := 10
set-swappiness:
ifeq ($(shell grep "vm.swappiness" /etc/sysctl.conf),)
	@echo ">>> Setting swappiness to $(SWAPPINESS)"
	@echo "# Decrease swap usage to a more reasonable level\nvm.swappiness=$(SWAPPINESS)" | sudo tee -a /etc/sysctl.conf > /dev/null
else
	@echo ">>> Manually change value of 'vm.swappiness' in '/etc/sysctl.conf'"
endif

define DISABLE_ADMIN_FILE_IN_HOME
# Disable ~/.sudo_as_admin_successful file
Defaults !admin_flag
endef

export DISABLE_ADMIN_FILE_IN_HOME

# Resources:
#  - https://github.com/sudo-project/sudo/issues/56
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
#
# Notes:
#  - Requires sudo >= 1.9.6
#  - Contents of the output file is defined by DISABLE_ADMIN_FILE_IN_HOME
.PHONY: disable-sudo-admin-file
disable-sudo-admin-file: OUT_FILE := /etc/sudoers.d/disable_admin_file_in_home
disable-sudo-admin-file:
	@echo ">>> Creating or rewriting file '$(OUT_FILE)'"
	@echo "$$DISABLE_ADMIN_FILE_IN_HOME" | sudo tee $(OUT_FILE) > /dev/null

# Notes:
#  - Modifies /etc/ubuntu-advantage/uaclient.conf
.PHONY: disable-ubuntu-news
disable-ubuntu-news:
	@echo ">>> Disabling Ubuntu news in apt output"
	sudo pro config set apt_news=false

# Resources:
#  - https://github.com/NVIDIA/nvidia-settings/issues/30
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
.PHONY: nvidia-settings-rc-xdg-path
nvidia-settings-rc-xdg-path: NVIDIA_SETTINGS_DESKTOP := /usr/share/applications/nvidia-settings.desktop
nvidia-settings-rc-xdg-path: NVIDIA_SETTINGS_RC := ~/.config/nvidia-settings/nvidia-settings-rc
nvidia-settings-rc-xdg-path: $(XDG_CONFIG_HOME)/nvidia-settings
ifeq ($(shell which nvidia-settings 2> /dev/null),)
	@echo ">>> Nothing to do, nvidia-settings is not installed"
else
	@echo ">>> Setting nvidia-settings config file to '$(NVIDIA_SETTINGS_RC)'"
	@sudo desktop-file-edit \
		--set-key=Exec \
		--set-value='nvidia-settings --config "$(NVIDIA_SETTINGS_RC)"' \
		$(NVIDIA_SETTINGS_DESKTOP)
	@sudo update-desktop-database
endif

# Resources:
#  - https://bitwarden.com/download/
#  - https://bitwarden.com/help/cli/
.PHONY: bitwarden
bitwarden: $(ZSH_COMPLETIONS)
ifneq ($(shell which bw 2> /dev/null),)
	@echo ">>> $$(bw --version) already installed"
else
	@echo ">>> Installing Bitwarden Desktop & CLI"
	sudo snap install bitwarden bw
	@echo ">>> Setting up bw zsh completions"
	bw completion --shell zsh > "$(ZSH_COMPLETIONS)/_bw"
	@echo ">>> Finish bw completion setup by reloading zsh with 'omz reload'"
endif

.PHONY: keybase
keybase: KEYBASE_URI := https://prerelease.keybase.io/keybase_$(DIST_ARCH).deb
keybase: KEYBASE_PKG := $(shell mktemp)
keybase: net-tools
ifneq ($(shell which keybase 2> /dev/null),)
	@echo ">>> $$($@ --version) already installed"
else
	@echo ">>> Installing Keybase: https://keybase.io/docs/the_app/install_linux"
	curl -o $(KEYBASE_PKG) --remote-name $(KEYBASE_URI)
	sudo dpkg -i $(KEYBASE_PKG) || true
	sudo apt install -y -f
	@echo ">>> Complete by running command 'run_keybase'"
endif
	rm -f $(KEYBASE_PKG)

.PHONY: zoom
zoom:
	@echo ">>> Installing zoom client"
	sudo snap install zoom-client

.PHONY: calibre
calibre:
	@echo ">>> Installing calibre"
	sudo apt install -y calibre

.PHONY: fix-ssh-perms
fix-ssh-perms: SSH_DIR := $(HOME)/.ssh
fix-ssh-perms:
	@echo ">>> Setting appropriate file permissions for files in '$(SSH_DIR)'"
	chmod 700 $(SSH_DIR)
	chmod 644 "$(SSH_DIR)/authorized_keys"
	chmod 644 "$(SSH_DIR)/*.pub"
	chmod 600 "$(SSH_DIR)/id_rsa*"
	chmod 600 "$(SSH_DIR)/config"
	chmod 700 "$(SSH_DIR)/config.d"
	chmod 600 "$(SSH_DIR)/known_hosts*"
	chmod 400 "$(SSH_DIR)/*.pem"

