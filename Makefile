# Absolute path to the directory containing this Makefile
#  - This path remains the same even when invoked with 'make -f ...'
#  - [source](https://stackoverflow.com/a/23324703)
CFG_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Make sure XDG is set: https://wiki.archlinux.org/title/XDG_Base_Directory

ifndef XDG_CONFIG_HOME
XDG_CONFIG_HOME=$(HOME)/.config
endif

ifndef XDG_BIN_HOME
XDG_BIN_HOME=$(HOME)/.local/bin
endif

ifndef XDG_DATA_HOME
XDG_DATA_HOME=$(HOME)/.local/share
endif

ifndef ZDOTDIR
ZDOTDIR=$(XDG_CONFIG_HOME)/zsh
endif

ifndef ZSH
ZSH=$(XDG_DATA_HOME)/oh-my-zsh
endif

ifndef ZSH_CUSTOM
ZSH_CUSTOM=$(ZSH)/custom
endif

ifndef BASE16_FZF_HOME
BASE16_FZF_HOME=$(XDG_CONFIG_HOME)/base16-fzf
endif

# TODO: currently base16-project hardcodes `$HOME/.config`, use 
# `XDG_CONFIG_HOME` once supported
ifndef BASE16_SHELL_PATH
BASE16_SHELL_PATH=$(HOME)/.config/base16-shell
endif

ifndef ALACRITTY_CONFIG_DIR 
ALACRITTY_CONFIG_DIR=$(XDG_CONFIG_HOME)/alacritty
endif

ifndef BAT_CONFIG_DIR
BAT_CONFIG_DIR=$(XDG_CONFIG_HOME)/bat
endif

ifndef FD_CONFIG_HOME
FD_CONFIG_HOME=$(XDG_CONFIG_HOME)/fd
endif

ifndef RIPGREP_CONFIG_HOME
RIPGREP_CONFIG_HOME=$(XDG_CONFIG_HOME)/rg
endif

ifndef BYOBU_CONFIG_DIR 
BYOBU_CONFIG_DIR=$(XDG_CONFIG_HOME)/byobu
endif

ifndef CARGO_TARGET_DIR
CARGO_TARGET_DIR=$(XDG_CACHE_HOME)/cargo-target
CARGO_RELEASE_DIR=$(CARGO_TARGET_DIR)/release
CARGO_ARTIFACTS_DIR=$(CARGO_RELEASE_DIR)/artifacts
endif

ifndef GEM_HOME
GEM_HOME=$(XDG_CONFIG_HOME)/gem
endif

ifndef GEM_SPEC_CACHE
GEM_SPEC_CACHE=$(XDG_CACHE_HOME)/gem
endif

ifndef TRAVIS_CONFIG_PATH
TRAVIS_CONFIG_PATH=$(XDG_CONFIG_HOME)/travis
endif

ifndef GHCUP_USE_XDG_DIRS
GHCUP_USE_XDG_DIRS=1
endif

ifndef STACK_ROOT
STACK_ROOT=$(XDG_DATA_HOME)/stack
endif

ifndef SDKMAN_DIR
SDKMAN_DIR=$(XDG_DATA_HOME)/sdkman
endif

ifndef GOPATH
GOPATH=$(XDG_DATA_HOME)/go
endif

ifndef MINIKUBE_HOME
MINIKUBE_HOME=$(XDG_DATA_HOME)/minikube
endif

ifndef KREW_ROOT
KREW_ROOT=$(XDG_DATA_HOME)/krew
endif

# The trailing slash is required - see: 
# https://wiki.archlinux.org/title/XDG_Base_Directory
ifndef CRAWL_DIR
CRAWL_DIR=$(XDG_DATA_HOME)/crawl/
endif

DIST_ARCH := $(shell dpkg --print-architecture)

# Aliases to make tools respect XDG specification
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
WGET := wget --hsts-file=$(XDG_CACHE_HOME)/wget-hsts

DEBIAN_ISO := debian-11.3.0-$(DIST_ARCH)-netinst.iso

FONTS_DIR := $(XDG_DATA_HOME)/fonts
MAN1_DIR := /usr/local/share/man/man1
ZSH_COMPLETIONS := $(ZSH)/completions

# Ensure necessary paths exist
$(FONTS_DIR) \
	$(ALACRITTY_CONFIG_DIR) \
	$(BAT_CONFIG_DIR)/themes \
	$(BYOBU_CONFIG_DIR) \
	$(CARGO_ARTIFACTS_DIR) \
	$(FD_CONFIG_HOME) \
	$(GOPATH) \
	$(RIPGREP_CONFIG_HOME) \
	$(STACK_ROOT) \
	$(ZDOTDIR) \
	$(ZSH_COMPLETIONS) \
	$(ZSH_CUSTOM) \
	$(ZSH_CUSTOM)/plugins/base16-shell \
	$(ZSH_CUSTOM)/plugins/poetry \
	$(XDG_BIN_HOME) \
	$(XDG_CACHE_HOME)/vm \
	$(XDG_CACHE_HOME)/zsh \
	$(XDG_CONFIG_HOME)/coc \
	$(XDG_CONFIG_HOME)/direnv \
	$(XDG_CONFIG_HOME)/git \
	$(XDG_CONFIG_HOME)/maven \
	$(XDG_CONFIG_HOME)/npm \
	$(XDG_CONFIG_HOME)/nvim/scripts \
	$(XDG_CONFIG_HOME)/nvim/vim-plug \
	$(XDG_CONFIG_HOME)/pypoetry \
	$(XDG_CONFIG_HOME)/python \
	$(XDG_DATA_HOME)/npm \
	$(CRAWL_DIR):
	mkdir -p $@

$(MAN1_DIR):
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
#  - [Base16 Shell](https://github.com/base16-project/base16-shell)
.PHONY: base16-shell
base16-shell: BASE16_SHELL_REPO := https://github.com/base16-project/base16-shell.git
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
#  - [Base16 fzf](https://github.com/base16-project/base16-fzf)
.PHONY: base16-fzf
base16-fzf: BASE16_FZF_REPO := https://github.com/base16-project/base16-fzf.git
base16-fzf:
	@echo ">>> Cloning Base16 fzf repository to '$(BASE16_FZF_HOME)'"
	@git clone $(BASE16_FZF_REPO) $(BASE16_FZF_HOME)

# Resources:
#  - [dconf backup/restore](https://askubuntu.com/a/844907)
#  - [Ubuntu wiki](https://wiki.ubuntu.com/Keybindings)
.PHONY: dconf-dump
dconf-dump:
	@echo "Saving Gnome keybindings:"
	@echo "'/org/gnome/desktop/wm/keybindings/'"
	@dconf dump \
		'/org/gnome/desktop/wm/keybindings/' > \
		$(CFG_DIR)/.config/dconf/gnome-keybindings.dconf
	@echo "'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/'"
	@dconf dump \
		'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' > \
		$(CFG_DIR)/.config/dconf/gnome-custom-keybindings.dconf

.PHONY: dconf-load
dconf-load:
	@echo "Restoring Gnome keybindings:"
	@echo "'/org/gnome/desktop/wm/keybindings/'"
	@dconf load \
		'/org/gnome/desktop/wm/keybindings/' < \
		$(CFG_DIR)/.config/dconf/gnome-keybindings.dconf
	@echo "'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/'"
	@dconf load \
		'/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/' < \
		$(CFG_DIR)/.config/dconf/gnome-custom-keybindings.dconf

.PHONY: links
links: \
	$(ALACRITTY_CONFIG_DIR) \
	$(BYOBU_CONFIG_DIR) \
	$(FD_CONFIG_HOME) \
	$(RIPGREP_CONFIG_HOME) \
	$(STACK_ROOT) \
	$(XDG_BIN_HOME) \
	$(XDG_CONFIG_HOME)/coc \
	$(XDG_CONFIG_HOME)/direnv \
	$(XDG_CONFIG_HOME)/git \
	$(XDG_CONFIG_HOME)/maven \
	$(XDG_CONFIG_HOME)/npm \
	$(XDG_CONFIG_HOME)/nvim/vim-plug \
	$(XDG_CONFIG_HOME)/nvim/scripts \
	$(XDG_CONFIG_HOME)/pypoetry \
	$(XDG_CONFIG_HOME)/python \
	$(ZDOTDIR) \
	$(ZSH_CUSTOM)
	@echo "Linking configuration files:"
	@ln -svft ~ $(CFG_DIR)/.zshenv
	@{ \
		for cfg in $$(find $(CFG_DIR)/.config $(CFG_DIR)/.local/share -type f -not -name '*.dconf'); do \
			ln -svf $$cfg "$(HOME)$${cfg#$(CFG_DIR)}";\
		done;\
	}
	@ln -svft $(XDG_BIN_HOME) $(CFG_DIR)/.local/bin/*
	@echo "Finish Poetry setup by manually configuring auth tokens: https://bit.ly/3fdpMNR"

.PHONY: config
config: dconf-load links

# Installed tools:
#  - libssl-dev: secure sockets layer toolkit
.PHONY: net-tools
net-tools:
	@echo ">>> Installing basic network tools"
	sudo apt install -y curl jq net-tools wget libssl-dev

.PHONY: core-tools
core-utils:
	@echo ">>> Installing core utilities"
	sudo apt install -y git lsb-core moreutils

.PHONY: apt-utils
apt-utils:
	@echo ">>> Installing utilities that let apt use packages over HTTPS"
	sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Installed tools:
#  - xclip: X11 clipboard selection
#  - xdotool: X11 automation tool (https://github.com/jordansissel/xdotool)
.PHONY: x-utils
x-utils:
	@echo ">>> Installing X11 utilities"
	sudo apt install -y xclip xdotool

# NOTE: python-is-python3 makes python available as python3
python:
	@echo ">>> Installing standard Python libraries"
	sudo apt install -y python3-pip python3-venv python-is-python3

# TODO: Possibly better option could be https://github.com/pyenv/pyenv
.PHONY: python3.6 python3.7
python3.6 python3.7: python
	@echo ">>> Installing $@"
	sudo add-apt-repository -y ppa:deadsnakes/ppa
	sudo apt update
	sudo apt install -y $@-dev $@-venv

# Installed tools:
#  - fzf: A command-line fuzzy finder (https://github.com/junegunn/fzf)
#  - chafa: Image visualization for terminal (https://hpjansson.org/chafa/)
#  - libglpk-dev glpk-*: GLPK toolkit (https://www.gnu.org/software/glpk/) 
#  - libecpg-dev: Postgres instegrations
#  - neofetch: A command-line system information tool
#    (https://github.com/dylanaraps/neofetch)
#  - tshark: Terminal version of wireshark
.PHONY: basic-tools
basic-tools: net-tools core-utils apt-utils x-utils python
	@echo ">>> Installing basic tools"
	sudo apt install -y \
		htop \
		iotop \
		iftop \
		tshark \
		neofetch \
		mc \
		neovim \
		tmux \
		byobu \
		tree \
		fzf \
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
	binenv install krew
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
binenv-tools: binenv
	@echo ">>> Installing duf: https://github.com/muesli/duf"
	binenv install duf

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

.PHONY: snaps
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

.PHONY: pipx
pipx: python
ifneq ($(shell which pipx 2> /dev/null),)
	@echo ">>> $@ $$($@ --version) already installed"
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
	# @echo ">>> Installing Pipenv: https://pipenv.pypa.io/"
	# pipx install pipenv $(OPS)  
	@echo ">>> Installing AWS CLI"
	pipx install awscli $(OPS)
	@echo ">>> Installing Pythonize: https://github.com/CZ-NIC/pz"
	pipx install pz $(OPS)
	@echo ">>> Installing The Fuck shell command corrector: https://github.com/nvbn/thefuck"
	pipx install thefuck $(OPS)
	@echo ">>> Installing pre-commit hooks globally"
	pipx install pre-commit $(OPS)
#	@echo ">>> Installing black formatter for Python"
#	pipx install black $(OPS)
#	@echo ">>> Installing WPS: https://wemake-python-stylegui.de/"
#	pipx install wemake-python-styleguide --include-deps $(OPS)
	@echo ">>> Installing Kaggle API: https://github.com/Kaggle/kaggle-api"
	pipx install kaggle $(OPS)

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
	@echo ">>> Installing cargo-audit: https://crates.io/crates/cargo-audit"
	cargo install cargo-audit --features=fix
	@echo ">>> Installing cargo-llvm-lines: https://github.com/dtolnay/cargo-llvm-lines"
	cargo install cargo-llvm-lines
	@echo ">>> Installing cargo-outdated: https://github.com/kbknapp/cargo-outdated"
	cargo install --locked cargo-outdated
	@echo ">>> Installing cargo-udeps: https://github.com/est31/cargo-udeps"
	cargo install --locked cargo-udeps

# TODO: generalize the hardcoded value of `CARGO_GH`
# Installed tools:
#  - bat: A cat(1) clone with wings (https://github.com/sharkdp/bat)
#  - click: Command Line Interactive Controller for Kubernetes
#  - exa: A modern replacement for 'ls' (https://github.com/ogham/exa)
#  - fd: A simple, fast and user-friendly alternative to 'find'
#    (https://github.com/sharkdp/fd)
#  - git-delta: A syntax-highlighting pager for git, diff, and grep output
#    (https://github.com/dandavison/delta)
#  - gping: Ping, but with a graph (https://github.com/orf/gping)
#  - hyperfine: A command-line benchmarking tool
#    (https://github.com/sharkdp/hyperfine)
#  - mdbook: Build a book from Markdown files
#    (https://github.com/rust-lang/mdBook)
#  - proximity-search: Simple command-line utility for sorting inputs by
#    proximity to a path argument (https://github.com/jonhoo/proximity-sort)
#  - ripgrep: Recursively searches directories for a regex pattern
#    (https://github.com/BurntSushi/ripgrep)
.PHONY: rust-tools
rust-tools: CARGO_GH := $(CARGO_HOME)/registry/src/github.com-1ecc6299db9ec823
rust-tools: RG_URL := https://github.com/BurntSushi/ripgrep/releases/download
rust-tools: RG_PKG := $(shell mktemp)
rust-tools: zsh rust $(CARGO_ARTIFACTS_DIR) $(MAN1_DIR)
	@echo ">>> Installing bat: https://github.com/sharkdp/bat"
	cargo install --locked bat
	@gzip -c "$$(cargo-latest-dirname bat)/out/assets/manual/bat.1" \
		| sudo tee $(MAN1_DIR)/bat.1.gz > /dev/null
	@cp "$$(cargo-latest-dirname bat)/out/assets/completions/bat.zsh" "$(ZSH_COMPLETIONS)/_bat"
	@echo ">>> Installing exa: https://the.exa.website/"
	cargo install exa
	@cp "$(CARGO_GH)/exa-$$(exa -v | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')/completions/completions.zsh" "$(ZSH_COMPLETIONS)/_exa"
	@pandoc  -s -t man \
		$(CARGO_GH)/exa-$$(exa -v | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')/man/exa.1.md \
		| gzip -c \
		| sudo tee $(MAN1_DIR)/exa.1.gz > /dev/null
	@echo ">>> Installing dust: https://github.com/bootandy/dust"
	cargo install du-dust
	@echo ">>> Installing fd: https://github.com/sharkdp/fd"
	cargo install fd-find
	@echo ">>> Installing git-delta: https://github.com/dandavison/delta"
	cargo install git-delta
	@echo ">>> Installing gping: https://github.com/orf/gping"
	cargo install gping
	@echo ">>> Installing hyperfine: https://github.com/sharkdp/hyperfine"
	env SHELL_COMPLETIONS_DIR=$(CARGO_ARTIFACTS_DIR) cargo install hyperfine
	@cp "$(CARGO_ARTIFACTS_DIR)/_hyperfine" $(ZSH_COMPLETIONS)
	@gzip -c $(CARGO_GH)/$$(hyperfine --version | sed 's| |-|g')/doc/hyperfine.1 \
		| sudo tee $(MAN1_DIR)/hyperfine.1.gz > /dev/null
	@echo ">>> Installing mdbook: https://github.com/rust-lang/mdBook"
	cargo install mdbook
	@echo ">>> Installing proximity-search: https://github.com/jonhoo/proximity-sort"
	cargo install proximity-sort
	@echo ">>> Installing click: https://github.com/databricks/click"
	cargo install click
	@echo ">>> Installing ripgrep: https://github.com/BurntSushi/ripgrep"
	cargo install ripgrep
	@$(WGET) -q -O $(RG_PKG) "$(RG_URL)/$$(rg -V | cut -d ' ' -f2)/$$(rg -V | sed 's| |_|g')_$(DIST_ARCH).deb"
	@ar -p $(RG_PKG) data.tar.xz | \
		tar -xOJf - --strip-components=4 --wildcards '*/rg.1.gz' | \
		sudo tee $(MAN1_DIR)/rg.1.gz > /dev/null
	@rm -f $(RG_PKG)

.PHONY: alacritty
alacritty: DOWNLOAD_URL := https://github.com/alacritty/alacritty/releases/download
alacritty: $(ALACRITTY_CONFIG_DIR) $(MAN1_DIR) $(ZSH_COMPLETIONS) net-tools x-utils
ifeq ($(shell which alacritty 2> /dev/null),)
	@echo ">>> Installing $@: https://github.com/alacritty/alacritty"
	sudo snap install --classic $@
	@echo ">>> Configuring $@"
	@{ \
		for cfg in $$(find $(CFG_DIR)/.config/$@ -type f); do \
			ln -svf $$cfg "$(HOME)$${cfg#$(CFG_DIR)}";\
		done;\
	}
else
	@echo ">>> Updating $@"
	sudo snap refresh $@
endif
	@echo ">>> Fetching man pages for $$($@ -V)"
	@sudo $(WGET) -qcNP $(MAN1_DIR) "$(DOWNLOAD_URL)/v$$($@ -V | awk {'print $$2'})/$@.1.gz"
	@echo ">>> Fetching zsh completions for $$($@ -V)"
	@$(WGET) -qcNP $(ZSH_COMPLETIONS) "$(DOWNLOAD_URL)/v$$($@ -V | awk {'print $$2'})/_$@"
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"

# Resources:
#  - https://github.com/vercel/install-node
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
# TODO: migrate to https://github.com/nvm-sh/nvm
.PHONY: nodejs
nodejs: $(XDG_DATA_HOME)/npm net-tools
	@echo ">>> Installing nodejs (LTS)"
	sudo curl -sL install-node.now.sh/lts | \
		sudo bash -s -- --prefix="$(XDG_DATA_HOME)/npm" -y

# Install ruby using apt instead of snap
#  - With ruby from snap, `gem install` does not respect cusom `$GEM_HOME` even
#    with `--no-user-install`, see: https://stackoverflow.com/a/70101849 
#  - https://www.ruby-lang.org/en/documentation/installation
#  - TODO: try https://www.ruby-lang.org/en/documentation/installation/#rbenv
.PHONY: ruby
ruby:
	@echo ">>> Installing Ruby"
	sudo apt install -y $@-full

# Installtion resources:
#  - [Official documentation](https://docs.docker.com/engine/install/ubuntu/)
#  - [Official post-instegration](https://docs.docker.com/engine/install/linux-postinstall/)
.PHONY: docker
docker: DOCKER_URL := https://download.docker.com/linux/ubuntu
docker: DOCKER_GPG := /usr/share/keyrings/docker-archive-keyring.gpg
docker: core-utils apt-utils
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

.PHONY: google-chrome
google-chrome: CHROME_PKG := google-chrome-stable_current_$(DIST_ARCH).deb
google-chrome: net-tools
ifneq ($(shell which google-chrome 2> /dev/null),)
	@echo ">>> Google Chrome already installed"
else
	@echo ">>> Downloading and installing Google Chrome"
	$(WGET) -O /tmp/$(CHROME_PKG) https://dl.google.com/linux/direct/$(CHROME_PKG)
	sudo apt install -y /tmp/$(CHROME_PKG)
endif
	rm -rf /tmp/$(CHROME_PKG)

# https://github.com/cli/cli
.PHONY: gh
gh: zsh
ifneq ($(shell which gh 2> /dev/null),)
	@echo ">>> $@ already installed"
else
	@echo ">>> Installing Github CLI"
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
	sudo apt-add-repository https://cli.github.com/packages
	sudo apt update
	sudo apt install -y $@
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

# Resources:
#  - [Automating setup](https://bit.ly/2SMFmsj)
.PHONY: jetbrains-toolbox
jetbrains-toolbox: TOOLBOX_URL := "https://data.services.jetbrains.com/products/download?platform=linux&code=TBA"
jetbrains-toolbox: TOOLBOX_DIR := $(shell mktemp -d)
jetbrains-toolbox: net-tools
ifneq ($(shell which jetbrains-toolbox 2> /dev/null),)
	@echo ">>> JetBrains Toolbox already installed"
else
	@echo ">>> Downloading and unpacking $(TOOLBOX_URL)"
	curl -sL $(TOOLBOX_URL) | tar -xvzf - --strip-components=1 -C $(TOOLBOX_DIR)
	@echo ">>> Installing JetBrains Toolbox"
	$(TOOLBOX_DIR)/$@
endif
	rm -rf $(TOOLBOX_DIR)

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

.PHONY: games
games: crawl

.PHONY: crawl
crawl: $(CRAWL_DIR) net-tools
ifneq ($(shell which crawl 2> /dev/null),)
	@echo ">>> $$($@ --version | head -n1) already installed"
else
	@echo ">>> Installing Dungeon Crawl Stone Soup: https://crawl.develz.org/"
	echo 'deb https://crawl.develz.org/debian crawl 0.23' | sudo tee -a /etc/apt/sources.list
	$(WGET) https://crawl.develz.org/debian/pubkey -O - | sudo apt-key add -
	sudo apt update
	sudo apt install -y $@ $@-tiles
endif

.PHONY: fix-ssh-perms
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

