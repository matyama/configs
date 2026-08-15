.DEFAULT_GOAL := all

# Absolute path to the directory containing this Makefile
#  - This path remains the same even when invoked with 'make -f ...'
#  - [source](https://stackoverflow.com/a/23324703)
CFG_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Local analogues to XDG directories
CFG_CONFIG_HOME ?= $(CFG_DIR)/.config
CFG_BIN_HOME ?= $(CFG_DIR)/.local/bin
CFG_DATA_HOME ?= $(CFG_DIR)/.local/share

# Make sure XDG is set: https://wiki.archlinux.org/title/XDG_Base_Directory
XDG_CACHE_HOME ?= $(HOME)/.cache
XDG_CONFIG_HOME ?= $(HOME)/.config
XDG_BIN_HOME ?= $(HOME)/.local/bin
XDG_DATA_HOME ?= $(HOME)/.local/share
XDG_STATE_HOME ?= $(HOME)/.local/state

# Extended XDG Base Directory Specification
XDG_APPS_HOME := $(XDG_DATA_HOME)/applications
XDG_DEV_HOME ?= $(HOME)/.local/dev
XDG_FONTS_HOME := $(XDG_DATA_HOME)/fonts
XDG_ICONS_HOME := $(XDG_DATA_HOME)/icons
XDG_MAN_HOME := $(XDG_DATA_HOME)/man
XDG_THEMES_HOME := $(XDG_DATA_HOME)/themes
XDG_TMP_HOME ?= $(XDG_CACHE_HOME)/tmp

GIT_TEMPLATE_DIR ?= $(XDG_DATA_HOME)/git-core/templates

ZDOTDIR ?= $(XDG_CONFIG_HOME)/zsh
ZSH_COMPLETIONS ?= $(XDG_DATA_HOME)/zsh/completions
ZSH_FUNCTIONS ?= $(XDG_DATA_HOME)/zsh/functions

BINENV_BINDIR ?= $(XDG_DATA_HOME)/binenv
BINENV_LINKDIR ?= $(XDG_BIN_HOME)

FZF_BASE ?= $(XDG_DATA_HOME)/fzf

BAT_CONFIG_DIR ?= $(XDG_CONFIG_HOME)/bat
RIPGREP_CONFIG_HOME ?= $(XDG_CONFIG_HOME)/rg

CARGO_HOME ?= $(XDG_DATA_HOME)/cargo

ifndef CARGO_TARGET_DIR
CARGO_TARGET_DIR=$(XDG_CACHE_HOME)/cargo-target
CARGO_RELEASE_DIR=$(CARGO_TARGET_DIR)/release
CARGO_ARTIFACTS_DIR=$(CARGO_RELEASE_DIR)/artifacts
endif

GHCUP_USE_XDG_DIRS ?= 1
CABAL_DIR ?= $(XDG_CONFIG_HOME)/cabal
CABAL_CONFIG ?= $(CABAL_DIR)/config
STACK_ROOT ?= $(XDG_DATA_HOME)/stack

NVM_DIR ?= $(XDG_DATA_HOME)/nvm

GOPATH ?= $(XDG_DATA_HOME)/go

MINIKUBE_HOME ?= $(XDG_DATA_HOME)/minikube
KREW_ROOT ?= $(XDG_DATA_HOME)/krew

ARCH ?= $(shell arch)
DIST_ARCH ?= $(shell dpkg --print-architecture)

# Aliases to make tools respect XDG specification
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
WGET := wget --hsts-file=$(XDG_STATE_HOME)/wget/wget-hsts

DEBIAN_ISO := debian-12.7.0-$(DIST_ARCH)-netinst.iso

LIBVIRT_DEFAULT_URI ?= ""

APT_KEYRINGS := /etc/apt/keyrings
USR_KEYRINGS := /usr/share/keyrings

# TODO: run initial installation or ensure the upgrade script can do so
.PHONY: all
all:
ifeq ($(shell test -x $(XDG_BIN_HOME)/upgrade && echo -n yes 2> /dev/null),yes)
	$(XDG_BIN_HOME)/upgrade
else
	$(CFG_BIN_HOME)/upgrade
endif

# Remove unused applications from the distribution and cleanup HOME
.PHONY: clean
clean:
	@echo ">>> Purging dot files that are disallowed in HOME's root"
	@rm -f $(BANNED_HOME_DOT_FILES)

# Don't pollute HOME with dot files: applications should either respect XDG
# specification or be configured to do so.
BANNED_HOME_DOT_FILES := \
	$(HOME)/.apport-ignore.xml \
	$(HOME)/.bashrc \
	$(HOME)/.bash_history \
	$(HOME)/.bash_logout \
	$(HOME)/.lesshst

# TODO: dependency on rustup, uv, tinty
# TODO: check if the tinted-fzf patch is still necessary
# TODO: other tools not installed via pacman
.PHONY: update
update: TINTED_FZF_HOME := \
	$(XDG_DATA_HOME)/tinted-theming/tinty/repos/tinted-fzf
update:
	@echo ">>> Updating AUR packages..."
	env -u CARGO_TARGET_DIR paru -Sua
	@echo ">>> Updating Rust toolchains..."
	rustup update
	@echo ">>> Updating Rust tools..."
	cargo install --locked proximity-sort
	@echo ">>> Updating Python tools..."
	uv tool upgrade --compile-bytecode --all
	@echo ">>> Updating tinted themes..."
	@git -C $(TINTED_FZF_HOME) reset --hard
	tinty sync
	@chmod +x $(TINTED_FZF_HOME)/ansi/ansi.sh

# TODO: install
#  - just: Just a command runner / simplified make
#    (https://github.com/casey/just)
#  - luajit: Just-In-Time Compiler for Lua (https://luajit.org)
# TODO: add other tests
.PHONY: test
test: test-docker

CACHE_DIRS := \
	$(CABAL_DIR) \
	$(CARGO_ARTIFACTS_DIR) \
	$(XDG_CACHE_HOME)/newsboat/articles \
	$(XDG_CACHE_HOME)/newsboat/podcasts

CONFIG_DIRS := \
	$(RIPGREP_CONFIG_HOME) \
	$(XDG_CONFIG_HOME)/alacritty \
	$(XDG_CONFIG_HOME)/bash \
	$(XDG_CONFIG_HOME)/bitcli \
	$(XDG_CONFIG_HOME)/btop \
	$(XDG_CONFIG_HOME)/environment.d \
	$(XDG_CONFIG_HOME)/fish \
	$(XDG_CONFIG_HOME)/fd \
	$(XDG_CONFIG_HOME)/git \
	$(XDG_CONFIG_HOME)/gtk-3.0 \
	$(XDG_CONFIG_HOME)/mpd \
	$(XDG_CONFIG_HOME)/newsboat \
	$(XDG_CONFIG_HOME)/npm \
	$(XDG_CONFIG_HOME)/nvim/lua \
	$(XDG_CONFIG_HOME)/nvim/lua/plugins \
	$(XDG_CONFIG_HOME)/python \
	$(XDG_CONFIG_HOME)/rmpc \
	$(XDG_CONFIG_HOME)/starship \
	$(XDG_CONFIG_HOME)/tealdeer \
	$(XDG_CONFIG_HOME)/tinted-theming/tinty \
	$(XDG_CONFIG_HOME)/vim \
	$(XDG_CONFIG_HOME)/wget

DATA_DIRS := \
	$(CARGO_HOME) \
	$(NVM_DIR) \
	$(STACK_ROOT) \
	$(XDG_DATA_HOME)/git-core/templates \
	$(XDG_DATA_HOME)/lua-language-server \
	$(XDG_DATA_HOME)/newsboat

# Ensure necessary paths exist
$(CACHE_DIRS) $(CONFIG_DIRS) $(DATA_DIRS) \
	$(GOPATH) \
	$(XDG_BIN_HOME) \
	$(XDG_APPS_HOME) \
	$(XDG_CONFIG_HOME)/mpd/playlists \
	$(XDG_DEV_HOME) \
	$(XDG_FONTS_HOME) \
	$(XDG_ICONS_HOME) \
	$(XDG_ICONS_HOME)/hicolor/scalable/apps \
	$(XDG_MAN_HOME)/man1 \
	$(XDG_MAN_HOME)/man5 \
	$(XDG_THEMES_HOME) \
	$(XDG_TMP_HOME) \
	$(XDG_STATE_HOME)/mpd \
	$(XDG_STATE_HOME)/sqlite3\
	$(XDG_STATE_HOME)/wget:
	mkdir -p $@

$(APT_KEYRINGS) $(USR_KEYRINGS):
	sudo mkdir -p $@

$(CABAL_CONFIG):
	@mkdir -p $$(dirname $@)
	@touch $@

/var/lib/libvirt/images/$(DEBIAN_ISO): ISO_URL := https://cdimage.debian.org/debian-cd/12.7.0/$(DIST_ARCH)/iso-cd
/var/lib/libvirt/images/$(DEBIAN_ISO): net-tools
	@echo ">>> Downloading Debian Bookworm net installer for $(DIST_ARCH)"
	@[ -f $@ ] || sudo $(WGET) -O $@ $(ISO_URL)/$(DEBIAN_ISO)
	sudo chown libvirt-qemu:kvm $@
	sudo chmod 660 $@

DOCKER_CMD := $(shell command -v docker 2> /dev/null)

INTEL_CPU := $(shell egrep 'model name\s+: Intel' /proc/cpuinfo 2> /dev/null)

# Resources:
#  - https://askubuntu.com/a/1263653
#  - default timer: 00:00~24:00/4
.PHONY: snap
snap:
	@echo ">>> Configuring $@"
	sudo snap set system refresh.timer=sun,18:00~20:00/2
	sudo snap set core experimental.refresh-app-awareness=true

# Resources:
#  - https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme#cli-installation
#  - Note: If not already present, this will install required dependencies
#    (sassc, gtk2-engines-murrine, and gnome-themes-extra)
#  - Installed artifacts:
#   - Installs themes to `$XDG_THEMES_HOME`
#   - Links assets to `$XDG_CONFIG_HOME/gtk-4.0` if `--libadwaita` is specified
#   - Links icons to `$XDG_ICONS_HOME`
#  - Uninstall themes with `./install.sh --uninstall`, manually remove icons
.PHONY: install-themes
install-themes: GRUVBOX_GTK_THEME_URL := https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme
install-themes: GRUVBOX_GTK_THEME_DIR := $(XDG_DATA_HOME)/gruvbox-gtk-theme
install-themes: GRUVBOX_GTK_THEME := grey
install-themes: $(XDG_THEMES_HOME) $(XDG_ICONS_HOME)
ifeq ($(shell test -d $(GRUVBOX_GTK_THEME_DIR) && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating GTK theme repository in '$(GRUVBOX_GTK_THEME_DIR)'"
	@git -C $(GRUVBOX_GTK_THEME_DIR) pull
else
	@echo ">>> Cloning GTK theme repository to '$(GRUVBOX_GTK_THEME_DIR)'"
	@git clone $(GRUVBOX_GTK_THEME_URL) $(GRUVBOX_GTK_THEME_DIR)
endif
	@echo ">>> Installing Gruvbox GTK theme..."
	"$(GRUVBOX_GTK_THEME_DIR)"/themes/install.sh \
		--dest $(XDG_THEMES_HOME) \
		--theme "$(GRUVBOX_GTK_THEME)" \
		--libadwaita \
		--tweaks outline
	@echo ">>> Linking Gruvbox icons..."
	@ln -svft $(XDG_ICONS_HOME) "$(GRUVBOX_GTK_THEME_DIR)"/icons/Gruvbox-Dark
	@ln -svft $(XDG_ICONS_HOME) "$(GRUVBOX_GTK_THEME_DIR)"/icons/Gruvbox-Light

# Notes:
#  - git-core/templates added because the linked git config references it and
#    issues a warning if it's not created (by pre-commit)
.PHONY: links
links: \
	$(CONFIG_DIRS) \
	$(DATA_DIRS) \
	$(XDG_BIN_HOME) \
	/usr/local/bin/resolvconf \
	/usr/bin/musl-g++ \
	/usr/bin/lldb-vscode
	@{ \
		for cfg in $$(find $(CFG_CONFIG_HOME) $(CFG_DATA_HOME) -type f); do \
			ln -svf $$cfg "$(HOME)$${cfg#$(CFG_DIR)}";\
		done;\
	}
	@ln -svft $(XDG_BIN_HOME) $(CFG_BIN_HOME)/*
	@echo "Refreshing systemd user environment (note: requires session restart)"
	@systemctl daemon-reload --user

# https://superuser.com/a/1544697
.PHONY: /usr/local/bin/resolvconf
/usr/local/bin/resolvconf:
	@sudo ln -svf /usr/bin/resolvectl $@

# https://github.com/rust-lang/cargo/issues/3359
.PHONY: /usr/bin/musl-g++
/usr/bin/musl-g++:
	@sudo ln -svf /usr/bin/g++ $@

.PHONY: /usr/bin/lldb-vscode
/usr/bin/lldb-vscode:
	@sudo ln -svf /usr/bin/lldb-vscode-15 $@

# NOTE: python-is-python3 makes python available as python3
python:
	@echo ">>> Installing standard Python libraries"
	sudo apt install -y python3-pip python3-venv python-is-python3

# TODO: Possibly better option could be https://github.com/pyenv/pyenv
.PHONY: python3.6 python3.7 python3.8 python3.9 python3.10 python3.11
python3.6 python3.7 python3.8 python3.9 python3.10 python3.11: python
	@echo ">>> Installing $@"
	sudo add-apt-repository -y ppa:deadsnakes/ppa
	sudo apt update
	sudo apt install -y $@-dev $@-venv

# TODO: deprecate in favor of skim
#  - tools that implicitly use fzf: forgit
#  - possible workaround: `ln -s "$(which skim)" "$XDG_BIN_HOME/fzf"`
#  - https://github.com/ajeetdsouza/zoxide/issues/228
#
# fzf: a command-line fuzzy finder
#  - https://github.com/junegunn/fzf
#  - Note: installs latest version, apt pkg might be quite old
#  - Note: `zoxide`'s interactive mode requires fzf at least v0.21.0
.PHONY: fzf
fzf: FZF_REPO := https://github.com/junegunn/fzf
fzf: core-utils $(XDG_BIN_HOME) $(XDG_MAN_HOME)/man1
ifneq ($(shell which fzf 2> /dev/null),)
	@echo ">>> Updating $@"
	git -C $(FZF_BASE) pull
else
	@echo ">>> Installing $@ to '$(FZF_BASE)'"
	git clone --depth 1 $(FZF_REPO) $(FZF_BASE)
endif
	$(FZF_BASE)/install --bin --no-update-rc
	@ln -svf $(FZF_BASE)/bin/fzf $(XDG_BIN_HOME)/fzf
	@ln -svf $(FZF_BASE)/bin/fzf-tmux $(XDG_BIN_HOME)/fzf-tmux
	@gzip -c $(FZF_BASE)/man/man1/$@.1 > $(XDG_MAN_HOME)/man1/$@.1.gz
	@gzip -c $(FZF_BASE)/man/man1/$@-tmux.1 > $(XDG_MAN_HOME)/man1/$@-tmux.1.gz

# Installed tools:
#  - autoconf: automatic configure script builder
#    (https://www.gnu.org/software/autoconf)
#  - coz-profiler: Coz: Causal Profiling (https://github.com/plasma-umass/coz)
#  - default-jdk: Standard Java or Java compatible Development Kit
#  - entr: Run arbitrary commands when files change
#    (https://github.com/eradman/entr)
#  - fzf: A command-line fuzzy finder (https://github.com/junegunn/fzf)
#  - git-lfs: Git extension for versioning large files (https://git-lfs.com)
#  - heaptrack(-gui): A heap memory profiler for Linux
#    (https://github.com/KDE/heaptrack)
#  - chafa: Image visualization for terminal (https://hpjansson.org/chafa/)
#  - kcat: Generic command line non-JVM Apache Kafka producer and consumer
#    (https://github.com/edenhill/kcat)
#  - libglpk-dev glpk-*: GLPK toolkit (https://www.gnu.org/software/glpk/)
#  - libecpg-dev: Postgres instegrations
#  - libimage-exiftool-perl: library and program to read and write meta
#    information in multimedia files (https://exiftool.org)
#  - libavdevice-dev: FFmpeg library for handling input and output devices
#  - libavformat-dev: FFmpeg library with (de)muxers for multimedia containers
#  - lld: LLD is a new, high-performance linker
#  - lldb-15: High-performance debugger (https://lldb.llvm.org)
#  - tesseract-ocr: Tesseract Open Source OCR Engine
#    (https://github.com/tesseract-ocr/tesseract)
#  - tshark: Terminal version of wireshark
#  - musl-tools: tools for cross-compilation to musl target
#  - capnproto, libcapnp-dev: Cap'N Proto compiler tools (https://capnproto.org)
#  - protobuf-compiler: `protoc`, compiler for protocol buffer definition files
#    (https://github.com/protocolbuffers/protobuf)
#  - redis-tools: Redis command line client and other tools
#  - sqlite3: Command line interface for SQLite 3 (https://www.sqlite.org)
#  - wireguard: fast, modern, secure VPN tunnel (https://www.wireguard.com)
#  - zathura: document viewer (https://pwmt.org/projects/zathura)
.PHONY: basic-tools
basic-tools: \
	fzf \
	pandoc \
	$(XDG_STATE_HOME)/sqlite3
	@echo ">>> Installing basic tools"
	sudo apt install -y \
		autoconf \
		git-lfs \
		tshark \
		entr \
		chafa \
		gparted \
		mypaint \
		tlp \
		dos2unix \
		tesseract-ocr \
		tesseract-ocr-eng \
		direnv \
		graphviz \
		kcat \
		default-jdk \
		libzstd-dev \
		libecpg-dev \
		libglpk-dev \
		libimage-exiftool-perl \
		libavdevice-dev \
		libavformat-dev \
		lld \
		lldb-15 \
		lz4 \
		glpk-utils \
		glpk-doc \
		musl-tools \
		heaptrack \
		heaptrack-gui \
		coz-profiler \
		valgrind \
		capnproto \
		libcapnp-dev \
		protobuf-compiler \
		redis-tools \
		sqlite3 \
		wireguard \
		zathura

# TODO: either remove or install via pacman (and setup fish/bash completions)
#.PHONY: pandoc
#pandoc:
#	@echo ">>> Installing $@"
#	sudo apt install -y $@
#	@echo ">>> Setting up $@ completions"
#	$@ --bash-completion > $</_$@

# Resources:
#  - [Simple tutorial](https://phoenixnap.com/kb/ubuntu-install-kvm)
#  - [Comprehensive guide](https://bit.ly/339BtPT)
# Notes:
#  - IOMMU GRUB fix: https://serverfault.com/a/633322
#  - cgroup GRUB fix: https://unix.stackexchange.com/a/727328
#  - The other WARN should be fine: https://stackoverflow.com/q/65207563
.PHONY: kvm
kvm: core-utils
	@[ "$$(kvm-ok | grep exists)" ] || (kvm-ok && return 1)
	@make -C $(CFG_DIR) kvm-pkgs kvm-group
	sudo systemctl enable libvirtd
	sudo systemctl restart libvirtd
	@echo ">>> Finish by system reboot for the changes to take effect"

.PHONY: kvm-pkgs
ifdef INTEL_CPU
kvm-pkgs: CPU_MODEL := intel
else
kvm-pkgs: CPU_MODEL := amd
endif
kvm-pkgs: GRUB_CMDLINE_LINUX_DEFAULT := "quiet splash $(CPU_MODEL)_iommu=on systemd.unified_cgroup_hierarchy=0"
kvm-pkgs: ARCH_FAMILY := $(shell arch | cut -d_ -f1)
kvm-pkgs:
	@echo ">>> Installing KVM virtualization"
	sudo apt install -y \
		qemu-system-$(ARCH_FAMILY) \
		libvirt-daemon-system \
		libvirt-clients \
		bridge-utils \
		virt-manager
	@echo ">>> Validating virtualization setup"
	@virt-host-validate || echo ">>> Consider fixing problematic entries"
	@echo ">>> Configuring GRUB_CMDLINE_LINUX_DEFAULT to '$(GRUB_CMDLINE_LINUX_DEFAULT)'"
	@sudo sed -i \
		's|^GRUB_CMDLINE_LINUX_DEFAULT=.*$$|GRUB_CMDLINE_LINUX_DEFAULT=$(GRUB_CMDLINE_LINUX_DEFAULT)|' \
		/etc/default/grub
	sudo update-grub
	@echo ">>> Reboot for the GRUB changes to take effect!"

.PHONY: kvm-group
kvm-group:
	@echo ">>> Adding user '$(USER)' to 'libvirt' and 'kvm' groups"
	@echo ">>> Original primary group: $$(id -ng)"
	cat /etc/group | grep libvirt | awk -F':' {'print $$1'} | xargs -n1 sudo adduser $(USER)
	sudo adduser $(USER) kvm
	@echo ">>> Make 'qemu:///system' available to group 'libvirt', not just root"
	@sudo sed -i \
		's|^#\?unix_sock_group = .*\\$$|unix_sock_group = "libvirt"|' \
		/etc/libvirt/libvirtd.conf
	@echo ">>> Configuring QEMU to help with disk permissions"
	@sudo sed -i \
		-e 's|^#\?group = .*\\$$|group = "libvirt"|' \
		-e 's|^#\?dynamic_ownership = .*\\$$|dynamic_ownership = 1|' \
		/etc/libvirt/qemu.conf

# This test is based on https://bit.ly/339BtPT
# Notes:
#  - In order not to require sudo, respectively to have access to the 'default'
#    network, LIBVIRT_DEFAULT_URI should be set to 'qemu:///system'
#  - Groups will be visible after login or [newgrp](https://superuser.com/a/345051) hack
#  - Default storage pool will show up AFTER reboot.
#  - Downloads the DEBIAN_ISO to /var/lib/libvirt/images, in general it must be
#    accessible by `libvirt-qemu:kvm` user:group (required by virt-install).
.PHONY: test-kvm
test-kvm: CDROM := /var/lib/libvirt/images/$(DEBIAN_ISO)
test-kvm: IMAGE := debian_bookworm.qcow2
test-kvm: $(CDROM)
	@echo ">>> User groups should contain 'kvm' and 'libvirt*'"
	id -nG | egrep -ow 'kvm|libvirt|libvirt-\w+'
ifneq ($(LIBVIRT_DEFAULT_URI),qemu:///system)
	$(error LIBVIRT_DEFAULT_URI should be set to 'qemu:///system')
endif
	@echo ">>> Verifying installation"
	virsh list --all
	@echo ">>> Showing storage pools"
	virsh pool-list --all
	@echo ">>> Showing default network created and used by KVM"
	ip addr show virbr0
	@echo ">>> Running test instance of virtual Debian Bookworm"
	virt-install \
		--name debian_bookworm \
		--virt-type=kvm \
		--ram 8192 \
		--vcpus=4 \
		--hvm \
		--cdrom $(CDROM) \
		--install no_install=yes \
		--osinfo detect=on,name=debianbookworm \
		--disk path=$(<D)/$(IMAGE),bus=virtio,size=40 \
		--network network=default,model=virtio \
		--graphics vnc,listen=0.0.0.0 \
		--video=vmvga \
		--noautoconsole
	@echo ">>> Checking that the VM is running"
	@{ \
		VM_STATE=$$(virsh list --all | grep " debian_bookworm " | awk '{ print $$3}');\
		[ "$$VM_STATE" = "running" ] || (echo ">>> VM is not running" && exit 1);\
	}
	@echo ">>> Destroying the VM"
	virsh destroy debian_bookworm
	virsh undefine debian_bookworm
	@echo ">>> Cleaning up the VM storage pool"
	virsh pool-list --details
	virsh pool-autostart images --disable
	virsh pool-autostart dirpool --disable
	virsh pool-destroy images
	virsh pool-destroy dirpool
	sudo rm -f "$(<D)/$(IMAGE)"
	virsh pool-undefine images
	virsh pool-undefine dirpool
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
#  - TODO: https://minikube.sigs.k8s.io/docs/tutorials/nvidia
.PHONY: k8s
k8s: KVM2_DRIVER_URL := https://storage.googleapis.com/minikube/releases/latest
k8s: KVM2_DRIVER := docker-machine-driver-kvm2
k8s: binenv kvm
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
	@echo ">>> Configure kvm2 as the default driver for minikube"
	@minikube config set driver kvm2
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
	@echo ">>> Verified kubectl $$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion')"
endif

# FIXME: Cleanup resources if service request fails
# Resources:
#  - [minikube tutorial](https://kubernetes.io/docs/tutorials/hello-minikube/)
#  - [Minikube with KVM2 driver](https://bit.ly/3tBWEVI)
.PHONY: test-k8s
test-k8s: net-tools
	@echo ">>> Testing minikube installation"
	minikube start --cpus 2 --memory 2048
	minikube status
	minikube config get driver
	kubectl cluster-info
	kubectl get nodes
	kubectl get pods --all-namespaces
	@echo ">>> Running test application in minikube"
	kubectl create deployment hello-minikube \
		--image=k8s.gcr.io/echoserver:1.10 \
		--port=8080
	kubectl wait deploy/hello-minikube --timeout=90s --for condition=available
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
	@echo ">>> Verified kubectl $$(kubectl version --client -o json | jq -r '.clientVersion.gitVersion')"

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
	@echo ">>> $@ already installed to '$(BINENV_BINDIR)'"
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
	@mv "$(DOWNLOAD_DIR)/$(BINENV_BIN)" "$(DOWNLOAD_DIR)/$@"
	@chmod +x "$(DOWNLOAD_DIR)/$@"
	"$(DOWNLOAD_DIR)/$@" update
	"$(DOWNLOAD_DIR)/$@" install $@
	@echo ">>> Generating zsh completions for $@"
	$@ completion zsh > $</_$@
	@echo ">>> Finish $@ completion setup by reloading zsh"
endif
	@rm -rf $(DOWNLOAD_DIR)

.PHONY: uv
uv:
	sudo pacman -Sy --needed --noconfirm uv

.PHONY: python-tools
python-tools: uv
	@echo ">>> Installing ansible with ansible-lint: https://www.ansible.com"
	uv tool install \
		--compile-bytecode \
		--with-executables-from ansible-lint \
		ansible
	@echo ">>> Installing gdbgui: https://www.gdbgui.com"
	uv tool install --compile-bytecode gdbgui
	@echo ">>> Installing maturin: https://www.maturin.rs"
	uv tool install --compile-bytecode maturin
	@echo ">>> Installing pre-commit hooks globally"
	uv tool install --compile-bytecode pre-commit
	@pre-commit init-templatedir $(GIT_TEMPLATE_DIR)
	@echo ">>> Installing ruff: https://docs.astral.sh/ruff"
	uv tool install --compile-bytecode ruff
	@echo ">>> Installing sqlfluff: https://github.com/sqlfluff/sqlfluff"
	uv tool install --compile-bytecode sqlfluff
	@echo ">>> Installing ty: https://docs.astral.sh/ty"
	uv tool install --compile-bytecode ty
	@echo ">>> Installing yamllint: https://github.com/adrienverge/yamllint"
	uv tool install --compile-bytecode yamllint

# Additional plugins
#  - https://github.com/python-lsp/pylsp-mypy
#  - https://github.com/python-lsp/python-lsp-ruff
#  - https://github.com/python-lsp/python-lsp-black
#  - https://github.com/python-rope/pylsp-rope
.PHONY: python-lsp-server
python-lsp-server: uv
	@echo ">>> Installing $@: https://github.com/python-lsp/python-lsp-server"
	uv tool install \
		--compile-bytecode \
		--with pylsp-mypy,python-lsp-black,pylsp-rope \
		--with git+https://github.com/python-lsp/python-lsp-ruff \
		"$@[all]"

# Haskell toolchain and project builder
#  - [ghcup](https://www.haskell.org/ghcup/)
#  - [stack](https://docs.haskellstack.org/en/stable/README/)
# Additional notes:
#  - ghcup also installs the Haskell Language Server and Stack
.PHONY: haskell
haskell: ghcup

.PHONY: ghcup-deps
ghcup-deps: net-tools
	@echo ">>> Installing ghcup distro packages"
	sudo apt install -y \
		build-essential \
		curl \
		libffi-dev \
		libffi8ubuntu1 \
		libgmp-dev \
		libgmp10 \
		libncurses-dev

.PHONY: ghcup
ghcup: GHCUP_URL := https://gitlab.haskell.org/haskell/ghcup-hs
ghcup: $(ZSH_COMPLETIONS) $(CABAL_CONFIG) ghcup-deps
ifneq ($(shell which ghcup 2> /dev/null),)
	@echo ">>> $$($@ --version) already installed"
else
	@echo ">>> Installing Haskell toolchain installer"
	curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
	@echo ">>> Dowloading zsh completions for $@"
	curl -sSL -o $</_$@ \
		"$(GHCUP_URL)/-/raw/v$$($@ --numeric-version)/shell-completions/zsh"
	@echo ">>> Finish $@ completion setup by reloading zsh"
endif

# Installed tools:
#  - fourmolu: Haskell source code formatter
#  - hlint: Haskell source code suggestions
#  - apply-refact: Refactor Haskell source files
.PHONY: haskell-tools
haskell-tools: haskell
	@echo ">>> Installing fourmolu: https://github.com/fourmolu/fourmolu"
	stack install fourmolu
	@echo ">>> Installing hlint: https://github.com/ndmitchell/hlint"
	stack install hlint apply-refact

# Cargo subcommands:
#  - auditable: make production Rust binaries auditable
#  - bloat: find out what takes most of the space in your executable
#  - criterion: run Criterion.rs benchmarks and report the results
#  - deb: generates Debian packages from information in Cargo.toml
#  - depgraph: creates dependency graphs for cargo projects
#  - duplicates: display duplicate dependencies
#  - expand: shows the result of macro expansion and #[derive] expansion
#  - hack: provides various options useful for testing & continuous integration
#  - llvm-lines: count lines of LLVM IR per generic function
#  - modules: visualize/analyze a Rust crate's internal structure
#  - msrv: find the minimum supported Rust version (MSRV)
#  - nextest: a next-generation test runner for Rust
#  - readme: generate README.md content from doc comments
#  - tarpaulin: a code coverage tool for Rust projects
#  - workspaces: a tool for managing cargo workspaces and their crates
CARGO_EXTENSIONS := \
	cargo-auditable \
	cargo-bloat \
	cargo-criterion \
	cargo-deb \
	cargo-depgraph \
	cargo-duplicates \
	cargo-expand \
	cargo-hack \
	cargo-llvm-lines \
	cargo-modules \
	cargo-msrv \
	cargo-nextest \
	cargo-readme \
	cargo-tarpaulin \
	cargo-workspaces

# Cargo subcommands:
#  - asm: display the Assembly, LLVM-IR, MIR and WASM generated for source code
#  - check-external-types: verify which types from other libraries are allowed
#    to be are exposed in their public API
#  - deny: lint dependencies
#  - insta: review tool for insta, a snapshot testing library for Rust
#  - machete: find unused dependencies
#  - outdated: display when dependencies are out of date
#  - semver-checks: scan crate for semver violations
#  - sort:  check if tables and items in a .toml file are lexically sorted
#  - udeps: find unused dependencies in Cargo.toml
#  - vet: supply-chain security for Rust
CARGO_EXTENSIONS_LOCKED := \
	cargo-check-external-types \
	cargo-deny \
	cargo-insta \
	cargo-machete \
	cargo-outdated \
	cargo-semver-checks \
	cargo-show-asm \
	cargo-sort \
	cargo-udeps \
	cargo-vet

.PHONY: $(CARGO_EXTENSIONS)
$(CARGO_EXTENSIONS):
	@echo ">>> Installing $@: https://crates.io/crates/$@"
	cargo install $@

.PHONY: $(CARGO_EXTENSIONS_LOCKED)
$(CARGO_EXTENSIONS_LOCKED):
	@echo ">>> Installing $@: https://crates.io/crates/$@"
	cargo install --locked $@

# Audit Cargo.lock for crates with security vulnerabilities
.PHONY: cargo-audit
cargo-audit:
	@echo ">>> Installing $@: https://crates.io/crates/$@"
	cargo install --locked $@ --features=fix

# Cargo subcommand to easily use LLVM source-based code coverage.
.PHONY: cargo-llvm-cov
cargo-llvm-cov:
	@echo ">>> Installing $@: https://crates.io/crates/$@"
	cargo install --locked $@
	rustup component add llvm-tools-preview --toolchain nightly

.PHONY: cargo-tools
cargo-tools: \
	rust \
	cargo-audit \
	cargo-llvm-cov \
	$(CARGO_EXTENSIONS) \
	$(CARGO_EXTENSIONS_LOCKED)

# TODO: replace click (unmaintained) with k9s
# Installed tools:
#  - click: Command Line Interactive Controller for Kubernetes
#    (https://github.com/databricks/click)
#  - cross: “Zero setup” cross compilation and “cross testing” of Rust crates
#    (https://github.com/cross-rs/cross)
#  - junitify: takes JSON tests from stdin and writes JUnit XML
#    (https://gitlab.com/Kores/junitify)
# TODO: remove the dependency on CRATES_SRC / crates.io index
.PHONY: rust-tools
rust-tools: CRATES_SRC := $(CARGO_HOME)/registry/src/index.crates.io-1949cf8c6b5b557f
rust-tools: rust $(CARGO_ARTIFACTS_DIR) $(XDG_MAN_HOME)/man1
	@echo ">>> Installing junitify: https://gitlab.com/Kores/junitify"
	cargo install junitify
	@echo ">>> Installing click: https://github.com/databricks/click"
	cargo install click
	@echo ">>> Installing sqlx-cli: https://crates.io/crates/sqlx-cli"
	cargo install sqlx-cli
	@sqlx completions zsh > "$(ZSH_COMPLETIONS)/_sqlx"

# TODO: install via pacman
#  - https://github.com/nvm-sh/nvm?tab=readme-ov-file#deeper-shell-integration
#
# Resources:
#  - https://github.com/nvm-sh/nvm#installing-and-updating
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
#
# Notes
#  - The nvm install script clones the nvm repo to `$XDG_CONFIG_HOME/nvm`
#  - https://github.com/nvm-sh/nvm#additional-notes
.PHONY: nvm
nvm: NVM_URL := https://raw.githubusercontent.com/nvm-sh/nvm
nvm: NVM_VERSION := 0.40.2
nvm: net-tools $(NVM_DIR)
	@echo ">>> Downloading and installing nvm ($(NVM_VERSION))"
	PROFILE=/dev/null bash -c \
		'curl -o- "$(NVM_URL)/v$(NVM_VERSION)/install.sh" | bash'
	. "$(NVM_DIR)/nvm.sh"
	@echo ">>> Using $@ $$($@ -v)"

# TODO: install latest LTS NODE_VERSION by default
#
# Resources:
#  - https://nodejs.org/en/download
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
.PHONY: nodejs
nodejs: SHELL := /bin/bash
nodejs: NODE_VERSION := 22
nodejs: $(XDG_CONFIG_HOME)/npm nvm
	@{ \
		set -e;\
		echo ">>> Initializing nvm";\
		source $(NVM_DIR)/nvm.sh;\
		echo ">>> Installing $@ $(NODE_VERSION)";\
		nvm install $(NODE_VERSION);\
	}
	@echo ">>> Linking npm user config..."
	@ln -svft $< $(CFG_CONFIG_HOME)/npm/*

# Resources:
#  - https://www.typescriptlang.org
#  - https://github.com/typescript-language-server/typescript-language-server
.PHONY: typescript
typescript: SHELL := /bin/bash
typescript: nodejs
	@{ \
		set -e;\
		echo ">>> Initializing nvm";\
		source $(NVM_DIR)/nvm.sh;\
		echo ">>> Installing $@: https://www.typescriptlang.org";\
		npm install -g $@ $@-language-server;\
	}
	@echo ">>> Using tsc $$(tsc --version)"

# Resources:
#  - https://github.com/rcjsuen/dockerfile-language-server
#  - https://www.andersevenrud.net/neovim.github.io/lsp/configurations/dockerls
.PHONY: dockerls
dockerls: SHELL := /bin/bash
dockerls: nodejs
	@{ \
		set -e;\
		echo ">>> Initializing nvm";\
		source $(NVM_DIR)/nvm.sh;\
		echo ">>> Installing $@";\
		npm install -g dockerfile-language-server-nodejs;\
	}

.PHONY: yaml-language-server
yaml-language-server: SHELL := /bin/bash
yaml-language-server: nodejs
	@{ \
		set -e;\
		echo ">>> Initializing nvm";\
		source $(NVM_DIR)/nvm.sh;\
		echo ">>> Installing $@";\
		npm install -g $@;\
	}

# Makefile linter
#
# FIXME: use `CHECKMAKE_TAG := latest` when `checkmake --version` is fixed
.PHONY: checkmake
checkmake: CHECKMAKE_TAG := $(shell gh_latest_release mrtazz/checkmake)
checkmake: DOWNLOAD_URL := https://github.com/mrtazz/checkmake/releases/download
checkmake: golang $(XDG_MAN_HOME)/man1
	@echo ">>> Installing $@ (v$(CHECKMAKE_TAG)): https://github.com/mrtazz/checkmake"
	go install "github.com/mrtazz/checkmake/cmd/$@@$(CHECKMAKE_TAG)"
	@echo ">>> Downloading man pages for $@ $(CHECKMAKE_TAG)"
	@curl -sSL "$(DOWNLOAD_URL)/$(CHECKMAKE_TAG)/$@.1" \
		| gzip -c > $(XDG_MAN_HOME)/man1/$@.1.gz

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

# Hadolint: Dockerfile linter
.PHONY: hadolint
hadolint: REPO_URL := https://github.com/hadolint/hadolint
hadolint: VERSION := $(shell gh_latest_release hadolint/hadolint)
hadolint: $(XDG_BIN_HOME) net-tools
	@echo ">>> Downloading $@ ($(VERSION)) from $(REPO_URL)"
	$(WGET) -qO $</$@ $(REPO_URL)/releases/download/$(VERSION)/$@-Linux-$(ARCH)
	@chmod +x $</$@
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

# Code snippet added to /etc/bash.bashrc by bash target
define RUN_USER_BASHRC
# Load bashrc from user's custom location instead of ~/.bashrc
if [ -s "$${XDG_CONFIG_HOME:-$$HOME/.config}/bash/bashrc" ] && [ "$${USER_BASHRC_RUN:-no}" != yes ]; then
	. "$${XDG_CONFIG_HOME:-$$HOME/.config}/bash/bashrc"
fi
endef

export RUN_USER_BASHRC

# Code snippet added to /etc/bash.bash.logout by bash target
define RUN_USER_BASH_LOGOUT
# Load bash_logout from user's custom location instead of ~/.bash_logout
if [ -s "$${XDG_CONFIG_HOME:-$$HOME/.config}/bash/bash_logout" ]; then
	. "$${XDG_CONFIG_HOME:-$$HOME/.config}/bash/bash_logout"
fi
endef

export RUN_USER_BASH_LOGOUT

BASH_CONFIGS := bashrc bash_aliases bash_logout

.PHONY: $(BASH_CONFIGS)
$(BASH_CONFIGS): $(XDG_CONFIG_HOME)/bash
	@echo ">>> Linking custom $@ script"
	@ln -svft $< $(CFG_CONFIG_HOME)/bash/$@

# Notes:
#  - The default location (HOME) for user's files is compiled in, so the only
#    option how to change it is this hack using system-wide configs
#  - Check man bash for supported files (SYSTEM_BASHRC, SYSTEM_BASH_LOGOUT)
.PHONY: bash
bash: SYSTEM_BASHRC := /etc/bash.bashrc
bash: SYSTEM_BASH_LOGOUT := /etc/bash.bash.logout
bash: $(BASH_CONFIGS)
ifeq ($(shell grep USER_BASHRC_RUN /etc/bash.bashrc),)
	@echo ">>> Adding custom bashrc loading to '$(SYSTEM_BASHRC)'"
	@echo "$$RUN_USER_BASHRC" | sudo tee -a "$(SYSTEM_BASHRC)" > /dev/null
endif
ifeq ($(shell grep -i "load bash_logout" /etc/bash.bash.logout),)
	@echo ">>> Adding custom bash_logout loading to '$(SYSTEM_BASH_LOGOUT)'"
	@echo "$$RUN_USER_BASH_LOGOUT" \
		| sudo tee -a "$(SYSTEM_BASH_LOGOUT)" > /dev/null
endif

# Configuration for various GNOME applications
# https://wiki.archlinux.org/title/GNOME
.PHONY: gnome
gnome: \
	nautilus \
	org.gnome.calculator \
	org.gnome.calendar \
	org.gnome.desktop.interface \
	org.gnome.desktop.notifications \
	org.gnome.desktop.privacy \
	org.gnome.system

.PHONY: org.gnome.calculator
org.gnome.calculator:
	@echo ">>> Configuring $@"
	@gsettings set $@ accuracy 9
	@gsettings set $@ angle-units 'radians'
	@gsettings set $@ base 10
	@gsettings set $@ button-mode 'advanced'
	@gsettings set $@ number-format 'automatic'

.PHONY: org.gnome.calendar
org.gnome.calendar:
	@echo ">>> Configuring $@"
	@gsettings set $@ active-view 'week'
	@gsettings set $@ weather-settings "(false, false, '', @mv nothing)"
	@gsettings set $@ week-view-zoom-level 1.0
	@gsettings set $@ window-maximized true

.PHONY: org.gnome.desktop.interface
org.gnome.desktop.interface:
	@echo ">>> Configuring $@"
	@gsettings set $@ clock-format '24h'
	@gsettings set $@ clock-show-date true
	@gsettings set $@ clock-show-seconds true
	@gsettings set $@ clock-show-weekday true
	@gsettings set $@ show-battery-percentage true

.PHONY: org.gnome.desktop.notifications
org.gnome.desktop.notifications:
	@echo ">>> Configuring $@"
	@gsettings set $@ application-children \
		$$( \
			gsettings get $@ application-children \
				| tr "'" '"' \
				| jq -c '. - ["apport-gtk", "org-gnome-dejadup", "thunderbird"]' \
				| tr '"' "'" \
		)
	@gsettings set $@ show-in-lock-screen false

.PHONY: org.gnome.desktop.privacy
org.gnome.desktop.privacy:
	@echo ">>> Configuring $@"
	@gsettings set $@ old-files-age 2
	@gsettings set $@ remove-old-temp-files true
	@gsettings set $@ remove-old-trash-files true
	@gsettings set $@ report-technical-problems false
	@gsettings set $@ send-software-usage-stats false

.PHONY: org.gnome.system
org.gnome.system:
	@echo ">>> Configuring $@"
	@gsettings set $@.locale region 'en_GB.UTF-8'
	@gsettings set $@.location enabled false

# XXX: load in bulk from an .ini file (persisted in this repo)
# - dconf dump /org/gnome/nautilus/ > nautilus.ini
# - dconf load /org/gnome/nautilus/ < nautilus.ini
# - possible issue: dconf ignores schema, so it's blind to defaults
#
# Resources:
#  - https://wiki.archlinux.org/title/GNOME/Files
#  - List current settings: `gsettings list-recursively org.gnome.nautilus`
.PHONY: nautilus
nautilus: \
	$(XDG_CONFIG_HOME)/gtk-3.0/bookmarks \
	org.gnome.nautilus.compression \
	org.gnome.nautilus.icon-view \
	org.gnome.nautilus.list-view \
	org.gnome.nautilus.preferences

.PHONY: org.gnome.nautilus.compression
org.gnome.nautilus.compression:
	@echo ">>> Configuring $@"
	@gsettings set $@ default-compression-format 'zip'

.PHONY: org.gnome.nautilus.icon-view
org.gnome.nautilus.icon-view:
	@echo ">>> Configuring $@"
	@gsettings set $@ default-zoom-level 'small'

.PHONY: org.gnome.nautilus.list-view
org.gnome.nautilus.list-view:
	@echo ">>> Configuring $@"
	@gsettings set $@ default-visible-columns \
		"['name', 'size', 'type', 'owner', 'permissions', 'date_modified']"
	@gsettings set $@ default-zoom-level 'small'
	@gsettings set $@ use-tree-view false

.PHONY: org.gnome.nautilus.preferences
org.gnome.nautilus.preferences:
	@echo ">>> Configuring $@"
	@gsettings set $@ click-policy 'double'
	@gsettings set $@ date-time-format 'simple'
	@gsettings set $@ default-folder-viewer 'list-view'
	@gsettings set $@ default-sort-in-reverse-order false
	@gsettings set $@ default-sort-order 'name'
	@gsettings set $@ recursive-search 'local-only'
	@gsettings set $@ search-filter-time-type 'last_modified'
	@gsettings set $@ show-delete-permanently false
	@gsettings set $@ show-directory-item-counts 'local-only'
	@gsettings set $@ show-image-thumbnails 'never'

.PHONY: $(XDG_CONFIG_HOME)/gtk-3.0/bookmarks
$(XDG_CONFIG_HOME)/gtk-3.0/bookmarks: \
	$(XDG_CONFIG_HOME)/gtk-3.0 $(XDG_DEV_HOME) $(XDG_TMP_HOME)
	@echo ">>> Configuring '$@'"
	@grep -qxF "file://$(XDG_DEV_HOME)" $@ \
		|| echo "file://$(XDG_DEV_HOME)" >> $@
	@grep -qxF "file://$(XDG_TMP_HOME)" $@ \
		|| echo "file://$(XDG_TMP_HOME)" >> $@

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
	@echo ">>> Finish bw completion setup by reloading zsh"
endif

# Installation resources:
#  - apt-key is mostly deprecated, hence the manual GPG key management
#  - https://github.com/keybase/client/issues/24856
.PHONY: keybase
keybase: KEYBASE_URI := https://prerelease.keybase.io/keybase_$(DIST_ARCH).deb
keybase: KEYBASE_PKG := $(shell mktemp)
keybase: KEYBASE_GPG := $(USR_KEYRINGS)/keybase-keyring.gpg
keybase: net-tools $(USR_KEYRINGS)
ifneq ($(shell which keybase 2> /dev/null),)
	@echo ">>> $$($@ --version) already installed"
else
	@echo ">>> Installing Keybase: https://keybase.io/docs/the_app/install_linux"
	curl -o $(KEYBASE_PKG) --remote-name $(KEYBASE_URI)
	sudo dpkg -i $(KEYBASE_PKG) || true
	sudo apt install -y -f
	@curl -fsSL https://keybase.io/docs/server_security/code_signing_key.asc \
		| sudo gpg --dearmor -o "$(KEYBASE_GPG)"
	#@sudo gpg --keyserver keyserver.ubuntu.com --recv-key 656D16C7
	#@sudo gpg --armor --export 656D16C7 | sudo gpg --dearmour -o "$(KEYBASE_GPG)"
	@sed -i \
		's|deb http://|deb [arch=$(DIST_ARCH) signed-by=$(KEYBASE_GPG)] https://|g' \
		/etc/apt/sources.list.d/$@.list
	@echo ">>> Complete by running command 'run_keybase'"
endif
	rm -f $(KEYBASE_PKG)

# Installation resources:
#  - calibre: ebook manager (https://calibre-ebook.com)
.PHONY: calibre
calibre:
	@echo ">>> Installing $@"
	sudo apt install -y $@

# Android Debug Bridge (adb)
#  - https://developer.android.com/tools/adb
#  - https://developer.android.com/studio/run/device#setting-up
.PHONY: adb
adb:
	@echo ">>> Installing $@: https://developer.android.com/tools/adb"
	@sudo apt install -y $@
	@echo ">>> Adding $(LOGNAME) to 'plugdev' group (requires new login)"
	@sudo usermod -aG plugdev $(LOGNAME)

.PHONY: fix-ssh-perms
fix-ssh-perms: SSH_DIR := $(HOME)/.ssh
fix-ssh-perms:
	@echo ">>> Setting appropriate file permissions for files in '$(SSH_DIR)'"
	chmod -f 700 $(SSH_DIR)
	chmod -f 644 "$(SSH_DIR)/authorized_keys"
	chmod -f 600 "$(SSH_DIR)/id_*"
	chmod -f 644 "$(SSH_DIR)/id_*.pub"
	chmod -f 600 "$(SSH_DIR)/config"
	chmod -f 700 "$(SSH_DIR)/config.d"
	chmod -f 600 "$(SSH_DIR)/known_hosts*"
	chmod -f 400 "$(SSH_DIR)/*.pem"
