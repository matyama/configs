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
ZSH ?= $(XDG_DATA_HOME)/oh-my-zsh
ZSH_COMPLETIONS := $(ZSH)/completions
ZSH_CUSTOM ?= $(ZSH)/custom
ZSH_PLUGINS ?= $(ZSH_CUSTOM)/plugins
ZSH_THEMES ?= $(ZSH_CUSTOM)/themes

BINENV_BINDIR ?= $(XDG_DATA_HOME)/binenv
BINENV_LINKDIR ?= $(XDG_BIN_HOME)

FZF_BASE ?= $(XDG_DATA_HOME)/fzf
SKIM_BASE ?= $(XDG_DATA_HOME)/skim

BASE16_ALACRITTY_HOME ?= $(XDG_CONFIG_HOME)/tinted-theming/tinted-alacritty
BASE16_FZF_HOME ?= $(XDG_CONFIG_HOME)/tinted-theming/tinted-fzf
BASE16_SHELL_PATH ?= $(XDG_CONFIG_HOME)/tinted-theming/tinted-shell
BASE16_TMUX_HOME ?= $(XDG_CONFIG_HOME)/tinted-theming/tinted-tmux

BAT_CONFIG_DIR ?= $(XDG_CONFIG_HOME)/bat
BYOBU_CONFIG_DIR ?= $(XDG_CONFIG_HOME)/byobu
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
CABAL_DIR ?= $(XDG_CONFIG_HOME)/cabal
CABAL_CONFIG ?= $(CABAL_DIR)/config
STACK_ROOT ?= $(XDG_DATA_HOME)/stack

SDKMAN_DIR ?= $(XDG_DATA_HOME)/sdkman
ZSH_SDKMAN_DIR ?= $(XDG_DATA_HOME)/zsh-sdkman

GOPATH ?= $(XDG_DATA_HOME)/go

MINIKUBE_HOME ?= $(XDG_DATA_HOME)/minikube
KREW_ROOT ?= $(XDG_DATA_HOME)/krew

ARCH ?= $(shell arch)
DIST_ARCH ?= $(shell dpkg --print-architecture)

# Aliases to make tools respect XDG specification
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
WGET := wget --hsts-file=$(XDG_CACHE_HOME)/wget-hsts

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
clean: thunderbird
	sudo apt autoremove --purge -y
	sudo apt autoclean
	@echo ">>> Purging dot files that are disallowed in HOME's root"
	@rm -f $(BANNED_HOME_DOT_FILES)

.PHONY: thunderbird
thunderbird:
	@echo ">>> Uninstalling $@"
	sudo snap remove $@

# Don't pollute HOME with dot files: applications should either respect XDG
# specification or be configured to do so.
BANNED_HOME_DOT_FILES := \
	$(HOME)/.apport-ignore.xml \
	$(HOME)/.bashrc \
	$(HOME)/.bash_history \
	$(HOME)/.bash_logout \
	$(HOME)/.lesshst \
	$(HOME)/.zsh_history

# TODO: add other tests
.PHONY: test
test: test-docker

CACHE_DIRS := \
	$(CABAL_DIR) \
	$(CARGO_ARTIFACTS_DIR) \
	$(XDG_CACHE_HOME)/newsboat/articles \
	$(XDG_CACHE_HOME)/newsboat/podcasts \
	$(XDG_CACHE_HOME)/zsh

CONFIG_DIRS := \
	$(BYOBU_CONFIG_DIR) \
	$(RIPGREP_CONFIG_HOME) \
	$(XDG_CONFIG_HOME)/alacritty \
	$(XDG_CONFIG_HOME)/bash \
	$(XDG_CONFIG_HOME)/bitcli \
	$(XDG_CONFIG_HOME)/direnv \
	$(XDG_CONFIG_HOME)/environment.d \
	$(XDG_CONFIG_HOME)/fd \
	$(XDG_CONFIG_HOME)/git \
	$(XDG_CONFIG_HOME)/gtk-3.0 \
	$(XDG_CONFIG_HOME)/lazygit \
	$(XDG_CONFIG_HOME)/maven \
	$(XDG_CONFIG_HOME)/newsboat \
	$(XDG_CONFIG_HOME)/npm \
	$(XDG_CONFIG_HOME)/nvidia-settings \
	$(XDG_CONFIG_HOME)/nvim/lua \
	$(XDG_CONFIG_HOME)/nvim/lua/plugins \
	$(XDG_CONFIG_HOME)/nvim/spell \
	$(XDG_CONFIG_HOME)/pypoetry \
	$(XDG_CONFIG_HOME)/python \
	$(XDG_CONFIG_HOME)/tealdeer \
	$(XDG_CONFIG_HOME)/tmux \
	$(XDG_CONFIG_HOME)/vim \
	$(XDG_CONFIG_HOME)/zed \
	$(ZDOTDIR)

DATA_DIRS := \
	$(CARGO_HOME) \
	$(STACK_ROOT) \
	$(XDG_DATA_HOME)/git-core/templates \
	$(XDG_DATA_HOME)/lua-language-server \
	$(XDG_DATA_HOME)/newsboat \
	$(XDG_DATA_HOME)/npm \
	$(ZSH_CUSTOM)/plugins/forgit \
	$(ZSH_CUSTOM)/plugins/poetry \
	$(ZSH_CUSTOM)/plugins/tinted-shell \
	$(ZSH_CUSTOM)/plugins/zsh-virsh

# Ensure necessary paths exist
$(CACHE_DIRS) $(CONFIG_DIRS) $(DATA_DIRS) \
	$(GOPATH) \
	$(XDG_BIN_HOME) \
	$(XDG_APPS_HOME) \
	$(XDG_DEV_HOME) \
	$(XDG_FONTS_HOME) \
	$(XDG_ICONS_HOME)/hicolor/scalable/apps \
	$(XDG_MAN_HOME)/man1 \
	$(XDG_MAN_HOME)/man5 \
	$(XDG_THEMES_HOME) \
	$(XDG_TMP_HOME) \
	$(XDG_STATE_HOME)/sqlite3 \
	$(ZSH_COMPLETIONS):
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

NVIDIA_CTRL := $(shell lspci | grep -i nvidia 2> /dev/null)

# Resources:
#  - https://askubuntu.com/a/1263653
#  - default timer: 00:00~24:00/4
.PHONY: snap
snap:
	@echo ">>> Configuring $@"
	sudo snap set system refresh.timer=sun,18:00~20:00/2
	sudo snap set core experimental.refresh-app-awareness=true

.PHONY: install-fonts
install-fonts: P10K_URL := https://github.com/romkatv/powerlevel10k-media/raw/master
install-fonts: $(XDG_FONTS_HOME)
	@echo ">>> Downloading Meslo Nerd Font for Powerlevel10k"
	curl -sSL "$(P10K_URL)/MesloLGS%20NF%20{Regular,Bold,Italic,Bold%20Italic}.ttf" \
		-o $</"MesloLGS NF #1.ttf"
	mv $</MesloLGS\ NF\ Bold%20Italic.ttf $</MesloLGS\ NF\ Bold\ Italic.ttf

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

# Resources:
#  - [Tinted Shell](https://github.com/tinted-theming/tinted-shell)
#  - Note: The ZSH plugin symlink name must match the name specified in the
#    plugins rc section (i.e., `tinted-shell.plugin.zsh`), contrary to the docs
.PHONY: tintted-shell
tinted-shell: BASE16_SHELL_REPO := https://github.com/tinted-theming/tinted-shell
tinted-shell: BASE16_THEME_DEFAULT := gruvbox-dark-hard
tinted-shell: BASE16_THEME := gruvbox-dark-hard
tinted-shell: zsh $(ZSH_CUSTOM)/plugins/tinted-shell
ifeq ($(shell test -d $(BASE16_SHELL_PATH) && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating $@ repository in '$(BASE16_SHELL_PATH)'"
	@git -C $(BASE16_SHELL_PATH) pull
else
	@echo ">>> Cloning $@ repository to '$(BASE16_SHELL_PATH)'"
	@git clone $(BASE16_SHELL_REPO) $(BASE16_SHELL_PATH)
endif
	@echo ">>> Linking $@ OMZ plugin"
	@ln -svf $(BASE16_SHELL_PATH)/base16-shell.plugin.zsh \
		$(ZSH_CUSTOM)/plugins/tinted-shell/tinted-shell.plugin.zsh
	@echo ">>> Testing default color scheme"
	@$(BASE16_SHELL_PATH)/colortest
	@echo ">>> Select color scheme by running: 'base16_$(BASE16_THEME)'"

# Resources:
#  - [tinted-fzf](https://github.com/tinted-theming/tinted-fzf)
.PHONY: tinted-fzf
tinted-fzf: BASE16_FZF_REPO := https://github.com/tinted-theming/tinted-fzf
tinted-fzf:
ifeq ($(shell test -d $(BASE16_FZF_HOME) && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating $@ repository in '$(BASE16_FZF_HOME)'"
	@git -C $(BASE16_FZF_HOME) pull
else
	@echo ">>> Cloning $@ repository to '$(BASE16_FZF_HOME)'"
	@git clone $(BASE16_FZF_REPO) $(BASE16_FZF_HOME)
endif

# Resources:
#  - [tinted-tmux](https://github.com/tinted-theming/tinted-tmux)
.PHONY: tinted-tmux
tinted-tmux: BASE16_TMUX_REPO := https://github.com/tinted-theming/tinted-tmux
tinted-tmux:
ifeq ($(shell test -d $(BASE16_TMUX_HOME) && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating $@ repository in '$(BASE16_TMUX_HOME)'"
	@git -C $(BASE16_TMUX_HOME) pull
else
	@echo ">>> Cloning $@ repository to '$(BASE16_TMUX_HOME)'"
	@git clone $(BASE16_TMUX_REPO) $(BASE16_TMUX_HOME)
endif

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

# Kernel version locked tools (such as `perf` and `x86_energy_perf_policy`)
.PHONY: linux-tools
linux-tools: KERNEL_RELEASE := $(shell uname -r)
linux-tools: PERF_BUILDID_DIR := /var/cache/perf-buildid
linux-tools:
	@echo ">>> Installing tools for kernel $(KERNEL_RELEASE)"
	@sudo apt install -y $@-$(KERNEL_RELEASE)
	@echo ">>> Configuring perf 'buildid.dir=$(PERF_BUILDID_DIR)'"
	@sudo perf config --system buildid.dir=$(PERF_BUILDID_DIR)

# Installed tools:
#  - libssl-dev: secure sockets layer toolkit
#  - pssh: asynchronous parallel SSH library (https://parallel-ssh.org)
.PHONY: net-tools
net-tools:
	@echo ">>> Installing basic network tools"
	sudo apt install -y curl jq net-tools ncat nmap wget libssl-dev pssh

# Installed tools:
#  - cpu-checker: tools to help evaluate certain CPU (or BIOS) features
#    (e.g., kvm-ok)
#  - libfuse2: Filesystem in Userspace
#    [AppImage - FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE)
.PHONY: core-tools
core-utils:
	@echo ">>> Installing core utilities"
	sudo apt install -y cpu-checker git moreutils libfuse2

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

# System performance tools for Linux
sysstat:
	@echo ">>> Installing $@: https://github.com/sysstat/sysstat"
	sudo apt install -y $@
	@echo ">>> Starting $@ data collection"
	sudo systemctl start $@
	sudo systemctl enable $@

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
fzf: FZF_REPO := https://github.com/junegunn/fzf.git
fzf: core-utils $(XDG_BIN_HOME) $(XDG_MAN_HOME)/man1
ifneq ($(shell which fzf 2> /dev/null),)
	@echo ">>> Updating $@"
	git -C $(FZF_BASE) pull
else
	@echo ">>> Installing $@ to '$(FZF_BASE)'"
	git clone --depth 1 $(FZF_REPO) $(FZF_BASE)
endif
	$(FZF_BASE)/install --bin --no-update-rc
	@gzip -c $(FZF_BASE)/man/man1/$@.1 > $(XDG_MAN_HOME)/man1/$@.1.gz
	@gzip -c $(FZF_BASE)/man/man1/$@-tmux.1 > $(XDG_MAN_HOME)/man1/$@-tmux.1.gz

# skim: Fuzzy Finder in rust!
#  - https://github.com/skim-rs/skim
#  - Note: installs version given by SKIM_TAG
.PHONY: skim
skim: SKIM_REPO := https://github.com/skim-rs/skim.git
skim: SKIM_TAG := $(shell gh_latest_release skim-rs/skim)
skim: core-utils rust zsh $(XDG_BIN_HOME) $(XDG_MAN_HOME)/man1 $(ZSH_COMPLETIONS)
ifneq ($(shell which sk 2> /dev/null),)
	@echo ">>> Updating $@"
ifneq ($(shell sk -V | sed 's|sk |v|'),$(SKIM_TAG))
	@git -C $(SKIM_BASE) fetch --all --tags --prune
	git -C $(SKIM_BASE) checkout tags/$(SKIM_TAG)
endif
	git -C $(SKIM_BASE) pull
else
	@echo ">>> Installing $@ to '$(SKIM_BASE)'"
	git clone --depth 1 --branch $(SKIM_TAG) $(SKIM_REPO) $(SKIM_BASE)
endif
	cargo build --release --locked --manifest-path "$(SKIM_BASE)/Cargo.toml"
	@cp $(CARGO_TARGET_DIR)/release/sk $(XDG_BIN_HOME)
	@ln -svf $(SKIM_BASE)/shell/completion.zsh $(ZSH_COMPLETIONS)/_sk
	@ln -svf \
		$(SKIM_BASE)/shell/key-bindings.zsh $(ZSH_CUSTOM)/sk-key-bindings.zsh
	@ln -svf $(SKIM_BASE)/bin/sk-tmux $(XDG_BIN_HOME)/sk-tmux
	@gzip -c $(SKIM_BASE)/man/man1/sk.1 > $(XDG_MAN_HOME)/man1/sk.1.gz
	@gzip -c $(SKIM_BASE)/man/man1/sk-tmux.1 > $(XDG_MAN_HOME)/man1/sk-tmux.1.gz

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

.PHONY: gitui
gitui: rust
	@echo ">>> Installing $@"
	cargo install --locked $@

# TODO: deprecate with gitui 1.0 (interactive rebase, branch structure)
.PHONY: lazygit
lazygit: TAG := latest
lazygit: $(XDG_CONFIG_HOME)/lazygit golang
	@echo ">>> Installing $@: https://github.com/jesseduffield/lazygit"
	go install "github.com/jesseduffield/$@@$(TAG)"
	@echo ">>> Configuring $@"
	@ln -svf \
		"$(CFG_CONFIG_HOME)/$@/config.yml" \
		"$(XDG_CONFIG_HOME)/$@/config.yml"

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
neovim: $(XDG_CONFIG_HOME)/nvim/spell
	@echo ">>> Installing $@"
	sudo snap install --beta nvim --classic
	touch $(XDG_CONFIG_HOME)/nvim/spell/en-utf-8.add

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
#  - tesseract-ocr: Tesseract Open Source OCR Engine
#    (https://github.com/tesseract-ocr/tesseract)
#  - tshark: Terminal version of wireshark
#  - musl-tools: tools for cross-compilation to musl target
#  - capnproto, libcapnp-dev: Cap'N Proto compiler tools (https://capnproto.org)
#  - protobuf-compiler: `protoc`, compiler for protocol buffer definition files
#    (https://github.com/protocolbuffers/protobuf)
#  - redis-tools: Redis command line client and other tools
#    sqlite3: Command line interface for SQLite 3 (https://www.sqlite.org)
#  - wireguard: fast, modern, secure VPN tunnel (https://www.wireguard.com)
.PHONY: basic-tools
basic-tools: \
	linux-tools \
	net-tools \
	core-utils \
	apt-utils \
	wl-utils \
	sysstat \
	fzf \
	tmux \
	neovim \
	$(XDG_STATE_HOME)/sqlite3
	@echo ">>> Installing basic tools"
	sudo apt install -y \
		git-lfs \
		htop \
		iotop \
		iftop \
		tshark \
		neofetch \
		mc \
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
		tesseract-ocr \
		tesseract-ocr-eng \
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
		redis-tools \
		sqlite3 \
		wireguard

.PHONY: tmux
tmux: $(XDG_CONFIG_HOME)/tmux
	@echo ">>> Installing $@: https://github.com/tmux/tmux"
	sudo apt install -y $@
	@echo ">>> Linking $@ confg..."
	@ln -svft $< $(CFG_CONFIG_HOME)/$@/*
	make -C $(CFG_DIR) tinted-$@

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

.PHONY: terraform
terraform: binenv
	@echo ">>> Installing $@: https://developer.hashicorp.com/terraform"
	@binenv update
	binenv install $@
	@echo ">>> Installed: $$($@ -version)"

# Code snippet to be used by test-terraform
define MAIN_TF
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name         = "nginx"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "tutorial"

  ports {
    internal = 80
    external = 8000
  }
}
endef

export MAIN_TF

.PHONY: test-terraform
test-terraform: TF_TEST_DIR := $(shell mktemp -d)
test-terraform:
ifeq ($(shell which terraform 2> /dev/null),)
	$(error terraform command not found)
else
	@echo ">>> Testing $$(terraform -version)"
	@echo "$$MAIN_TF" > $(TF_TEST_DIR)/main.tf
	terraform -chdir="$(TF_TEST_DIR)" init
	terraform -chdir="$(TF_TEST_DIR)" apply -auto-approve
	terraform -chdir="$(TF_TEST_DIR)" destroy -auto-approve
endif
	rm -rf "$(TF_TEST_DIR)"

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
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"
endif
	@rm -rf $(DOWNLOAD_DIR)

# Installed tools:
#  - duf: Disk Usage/Free Utility - a better 'df' alternative
#    (https://github.com/muesli/duf)
.PHONY: binenv-tools
binenv-tools: DUF_URL := https://github.com/muesli/duf/archive/refs/tags
binenv-tools: binenv $(XDG_MAN_HOME)/man1
	@echo ">>> Installing duf: https://github.com/muesli/duf"
	binenv install duf
	@curl -sSL "$(DUF_URL)/v$$(duf -version | cut -d ' ' -f2).tar.gz" \
		| tar -xzf - --strip-components=1 --wildcards '*/duf.1' --to-command=gzip \
		> $(XDG_MAN_HOME)/man1/duf.1.gz

# Installation resources:
#  - https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH
#  - https://github.com/ohmyzsh/ohmyzsh#custom-directory
#  - https://github.com/ohmyzsh/ohmyzsh/issues/9543
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
.PHONY: zsh
zsh: $(XDG_CACHE_HOME)/zsh core-utils net-tools
ifneq ($(shell which zsh 2> /dev/null),)
	@echo ">>> $@ already installed"
else
	@echo ">>> Installing zsh and oh-my-zsh"
	sudo apt install -y $@ fonts-powerline
	$@ --version
	sh -c "$$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	sudo chsh -s $$(which $@)
endif
	@echo ">>> Setting up $@ plugins"
	make -C $(CFG_DIR) $(ZSH_USERS_PLUGINS) $(ZSH_LINKED_PLUGINS)
	@echo ">>> Setting up $@ themes"
	make -C $(CFG_DIR) powerlevel10k

ZSH_USERS_PLUGINS := \
	zsh-syntax-highlighting \
	zsh-history-substring-search \
	zsh-autosuggestions

.PHONY: $(ZSH_USERS_PLUGINS)
$(ZSH_USERS_PLUGINS): core-utils
ifeq ($(shell test -d $(ZSH_PLUGINS)/$@ && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating $@ repository in '$(ZSH_PLUGINS)/$@'"
	@git -C "$(ZSH_PLUGINS)/$@" pull
else
	@echo ">>> Cloning $@ repository to '$(ZSH_PLUGINS)/$@'"
	git clone "https://github.com/zsh-users/$@" "$(ZSH_PLUGINS)/$@"
endif

ZSH_LINKED_PLUGINS := \
	zsh-virsh

.PHONY: $(ZSH_LINKED_PLUGINS)
$(ZSH_LINKED_PLUGINS):
	@echo ">>> Linking $@ plugin to '$(ZSH_PLUGINS)/$@'"
	@mkdir -p "$(ZSH_PLUGINS)/$@"
	@ln -svft \
		"$(ZSH_PLUGINS)/$@" \
		"$(CFG_DATA_HOME)/oh-my-zsh/custom/plugins/$@"/*.zsh

.PHONY: powerlevel10k
powerlevel10k: core-utils
ifeq ($(shell test -d $(ZSH_THEMES)/$@ && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating $@ repository in '$(ZSH_THEMES)/$@'"
	@git -C "$(ZSH_THEMES)/$@" pull
else
	@echo ">>> Cloning $@ repository to '$(ZSH_THEMES)/$@'"
	@git clone https://github.com/romkatv/powerlevel10k "$(ZSH_THEMES)/$@"
endif

# Installation resources:
#  - cmake: software build system for C/C++ (https://cmake.org)
#  - bash-language-server: language server for Bash
#    (https://github.com/bash-lsp/bash-language-server)
.PHONY: cmake bash-language-server slack
cmake bash-language-server slack:
	@echo ">>> Installing $@: https://snapcraft.io/$@"
	sudo snap install --classic $@

# Installation resources:
#  - dbeaver-ce: universal database tool (https://dbeaver.io)
#  - gimp: GNU Image Manipulation Program (https://www.gimp.org)
#  - netron: visualizer for neural network, deep learning & ML models
#    (https://github.com/lutzroeder/netron)
#  - postman: API platform for building & using APIs (https://www.postman.com)
.PHONY: dbeaver-ce gimp googler netron postman skype spotify zoom-client
dbeaver-ce gimp netron postman skype spotify zoom-client:
	@echo ">>> Installing $@: https://snapcraft.io/$@"
	sudo snap install $@

.PHONY: pipx
pipx: python
ifneq ($(shell which pipx 2> /dev/null),)
	@echo ">>> $@ already installed (v$$($@ --version))"
else
	@echo ">>> Installing $@"
	sudo apt update
	sudo apt -y install $@
	$@ ensurepath
endif

.PHONY: python-tools
python-tools: OPS :=
python-tools: pipx
	@echo ">>> Installing Python virtual environment"
	pipx install virtualenv $(OPS)
	@echo ">>> Installing Ansible: https://www.ansible.com"
	pipx install --include-deps ansible
	@echo ">>> Installing pipenv: https://pipenv.pypa.io"
	pipx install pipenv
	@echo ">>> Installing pre-commit hooks globally"
	pipx install pre-commit $(OPS)
	@pre-commit init-templatedir $(GIT_TEMPLATE_DIR)
	@echo ">>> Installing pycobertura: https://github.com/aconrad/pycobertura"
	pipx install pycobertura
	@echo ">>> Installing sqlfluff: https://github.com/sqlfluff/sqlfluff"
	pipx install sqlfluff
	@echo ">>> Installing gdbgui: https://www.gdbgui.com"
	pipx install gdbgui
	@echo ">>> Installing yamllint: https://github.com/adrienverge/yamllint"
	pipx install yamllint

.PHONY: python-lsp-server
python-lsp-server: pipx
	@echo ">>> Installing $@: https://github.com/python-lsp/python-lsp-server"
	pipx install --include-deps "$@[all]"
	@echo ">>> Installing pylsp-mypy: https://github.com/python-lsp/pylsp-mypy"
	pipx inject --include-deps $@ pylsp-mypy
	@echo ">>> Installing python-lsp-ruff: https://github.com/python-lsp/python-lsp-ruff"
	pipx inject --include-deps $@ python-lsp-ruff
	@echo ">>> Installing python-lsp-black: https://github.com/python-lsp/python-lsp-black"
	pipx inject --include-deps $@ python-lsp-black
	@echo ">>> Installing pylsp-rope: https://github.com/python-rope/pylsp-rope"
	pipx inject --include-deps $@ pylsp-rope

# Installation resources:
#  - https://python-poetry.org/docs/#installation
#  - https://python-poetry.org/docs/#enable-tab-completion-for-bash-fish-or-zsh
.PHONY: poetry
poetry: pipx zsh $(ZSH_PLUGINS)/poetry
ifneq ($(shell which poetry 2> /dev/null),)
	@echo ">>> $$($@ --version) already installed, upgrading instead..."
	pipx upgrade poetry
	@echo ">>> Using $$($@ --version)"
else
	@echo ">>> Installing Poetry: https://python-poetry.org/docs/"
	pipx install $@
endif
	@echo ">>> Updating shell completions for $@"
	$@ completions zsh > $(ZSH_PLUGINS)/$@/_$@

# Installation resources:
#  - https://sdkman.io/install
#  - Note: Installation won't update rc files since we're using custom `.zshrc`
#    and `.zshenv`
.PHONY: sdk
sdk: SHELL := /bin/bash
sdk: net-tools
	@echo ">>> Installing SDKMAN: https://sdkman.io/"
	curl -s "https://get.sdkman.io?rcupdate=false" | bash
	source $(SDKMAN_DIR)/bin/sdkman-init.sh
	make -C $(CFG_DIR) zsh-sdkman

# Installation resources:
#  - https://github.com/matthieusb/zsh-sdkman#installation
.PHONY: zsh-sdkman
zsh-sdkman: ZSH_SDKMAN_REPO_URL := https://github.com/matthieusb/zsh-sdkman
zsh-sdkman: ZSH_SDKMAN_PLUGIN_DIR := $(ZSH_CUSTOM)/plugins/zsh-sdkman
zsh-sdkman: zsh
ifeq ($(shell test -d $(ZSH_SDKMAN_PLUGIN_DIR) && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating $@ repository in '$(ZSH_SDKMAN_PLUGIN_DIR)'"
	@git -C $(ZSH_SDKMAN_PLUGIN_DIR) pull
else
	@echo ">>> Cloning $@ repository to '$(ZSH_SDKMAN_PLUGIN_DIR)'"
	@git clone $(ZSH_SDKMAN_REPO_URL) $(ZSH_SDKMAN_PLUGIN_DIR)
endif

.PHONY: jvm-tools
jvm-tools: SHELL := /bin/bash
jvm-tools: JAVA_VERSION := 22.0.1-open
jvm-tools: $(SDKMAN_DIR)/bin/sdkman-init.sh
	@{ \
		set -e;\
		source $<;\
		echo ">>> Installing Java";\
		sdk install java $(JAVA_VERSION);\
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
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"
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

.PHONY: rust
rust: net-tools
ifeq ($(shell which rustc 2> /dev/null),)
	@echo ">>> Installing Rust toolchain"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	. $(XDG_DATA_HOME)/cargo/env
	@echo ">>> Installing Rust nightly toolchain"
	rustup install nightly
	@echo ">>> Installing rust-src"
	rustup component add rust-src
	@echo ">>> Installing rust-analyzer"
	rustup component add rust-analyzer
	@echo ">>> Installing miri"
	rustup +nightly component add miri
endif
	rustup show

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
#  - outdated: display when dependencies are out of date
#  - semver-checks: scan crate for semver violations
#  - udeps: find unused dependencies in Cargo.toml
#  - vet: supply-chain security for Rust
CARGO_EXTENSIONS_LOCKED := \
	cargo-check-external-types \
	cargo-deny \
	cargo-outdated \
	cargo-semver-checks \
	cargo-show-asm \
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
	cargo install $@ --features=fix

# Cargo subcommand to easily use LLVM source-based code coverage.
.PHONY: cargo-llvm-cov
cargo-llvm-cov:
	@echo ">>> Installing $@: https://crates.io/crates/$@"
	cargo install --locked $@
	rustup component add llvm-tools-preview --toolchain nightly

# Watches over project's source for changes & runs commands when they occur
.PHONY: cargo-watch
cargo-watch: DOWNLOAD_URL := https://github.com/watchexec/cargo-watch/releases/download
cargo-watch: DOWNLOAD_DIR := $(shell mktemp -d)
cargo-watch: TARBALL := $(ARCH)-unknown-linux-gnu.tar.xz
cargo-watch: $(ZSH_COMPLETIONS) $(XDG_MAN_HOME)/man1 net-tools rust
	@echo ">>> Installing $@: https://github.com/watchexec/cargo-watch"
	cargo install $@
	@echo ">>> Downloading man pages and zsh completions for $$($@ -V)"
	@curl -sSL "$(DOWNLOAD_URL)/v$$($@ -V | awk {'print $$2'})/$$($@ -V | sed 's| |-v|')-$(TARBALL)" | \
		tar -C $(DOWNLOAD_DIR) -xJf - --strip-components=1 --wildcards */$@.1 */completions/zsh
	@gzip -c $(DOWNLOAD_DIR)/$@.1 > $(XDG_MAN_HOME)/man1/$@.1.gz
	@mv $(DOWNLOAD_DIR)/completions/zsh $</_$@
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"
	@rm -rf $(DOWNLOAD_DIR)

.PHONY: cargo-tools
cargo-tools: \
	rust \
	cargo-audit \
	cargo-llvm-cov \
	cargo-watch \
	$(CARGO_EXTENSIONS) \
	$(CARGO_EXTENSIONS_LOCKED)

# Installed tools:
#  - bat: A cat(1) clone with wings (https://github.com/sharkdp/bat)
#  - bitcli:  Simple CLI tool for URL shortening via Bitly
#    (https://github.com/matyama/bitcli)
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
#  - onefetch: Command-line Git information tool
#    (https://github.com/o2sh/onefetch)
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
#  - stylua: An opinionated Lua code formatter
#    (https://github.com/JohnnyMorganz/StyLua)
#  - tealdeer: A very fast implementation of tldr in Rust
#    (https://github.com/dbrgn/tealdeer)
#  - tokio-console: A debugger for async Rust
#    (https://github.com/tokio-rs/console)
#  - xh: Friendly and fast tool for sending HTTP requests
#    (https://github.com/ducaale/xh)
#  - zoxide: A smarter cd command (https://github.com/ajeetdsouza/zoxide)
.PHONY: rust-tools
rust-tools: CRATES_SRC := $(CARGO_HOME)/registry/src/index.crates.io-6f17d22bba15001f
rust-tools: zsh rust $(CARGO_ARTIFACTS_DIR) $(XDG_MAN_HOME)/man1
	@echo ">>> Installing bat: https://github.com/sharkdp/bat"
	env BAT_ASSETS_GEN_DIR=$(CARGO_ARTIFACTS_DIR) \
		cargo install --locked --force bat
	@gzip -c "$(CARGO_ARTIFACTS_DIR)/assets/manual/bat.1" \
		> $(XDG_MAN_HOME)/man1/bat.1.gz
	@cp "$(CARGO_ARTIFACTS_DIR)/assets/completions/bat.zsh" "$(ZSH_COMPLETIONS)/_bat"
	@echo ">>> Installing bitcli: https://github.com/matyama/bitcli"
	cargo install --locked --git https://github.com/matyama/bitcli
	@echo ">>> Installing eza: https://eza.rocks"
	cargo install eza
	@cp "$(CRATES_SRC)/eza-$$(eza -v | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')/completions/zsh/_eza" "$(ZSH_COMPLETIONS)/_eza"
	@pandoc  -s -t man \
		$(CRATES_SRC)/eza-$$(eza -v | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')/man/eza.1.md \
		| gzip -c > $(XDG_MAN_HOME)/man1/eza.1.gz
	@echo ">>> Installing dust: https://github.com/bootandy/dust"
	cargo install du-dust
	@echo ">>> Installing fd: https://github.com/sharkdp/fd"
	cargo install fd-find
	@cp \
		$(CRATES_SRC)/$$(fd -V | sed 's| |-find-|')/contrib/completion/_fd \
		$(ZSH_COMPLETIONS)
	@gzip -c $(CRATES_SRC)/$$(fd -V | sed 's| |-find-|')/doc/fd.1 \
		> $(XDG_MAN_HOME)/man1/fd.1.gz
	@echo ">>> Installing git-delta: https://github.com/dandavison/delta"
	cargo install git-delta
	@echo ">>> Installing gping: https://github.com/orf/gping"
	cargo install gping
	@echo ">>> Installing hexyl: https://github.com/sharkdp/hexyl"
	cargo install hexyl
	@pandoc  -s -f markdown -t man \
		$(CRATES_SRC)/$$(hexyl --version | sed 's| |-|g')/doc/hexyl.1.md \
		| gzip -c > $(XDG_MAN_HOME)/man1/hexyl.1.gz
	@echo ">>> Installing hyperfine: https://github.com/sharkdp/hyperfine"
	env SHELL_COMPLETIONS_DIR=$(CARGO_ARTIFACTS_DIR) \
		cargo install --locked --force hyperfine
	@cp "$(CARGO_ARTIFACTS_DIR)/_hyperfine" $(ZSH_COMPLETIONS)
	@gzip -c $(CRATES_SRC)/$$(hyperfine --version | sed 's| |-|g')/doc/hyperfine.1 \
		> $(XDG_MAN_HOME)/man1/hyperfine.1.gz
	@echo ">>> Installing junitify: https://gitlab.com/Kores/junitify"
	cargo install junitify
	@echo ">>> Installing just: https://github.com/casey/just"
	cargo install --locked just
	@just --completions zsh > "$(ZSH_COMPLETIONS)/_just"
	@just --man | gzip -c > $(XDG_MAN_HOME)/man1/just.1.gz
	@echo ">>> Installing mcfly: https://github.com/cantino/mcfly"
	cargo install mcfly
	@echo ">>> Installing mdbook: https://github.com/rust-lang/mdBook"
	cargo install mdbook
	@echo ">>> Installing onefetch: https://github.com/o2sh/onefetch"
	cargo install onefetch
	@gzip -c $(CRATES_SRC)/$$(onefetch --version | sed 's| |-|g')/docs/onefetch.1 \
		> $(XDG_MAN_HOME)/man1/onefetch.1.gz
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
	@rg --generate man | gzip -c > $(XDG_MAN_HOME)/man1/rg.1.gz
	@echo ">>> Installing samply: https://github.com/mstange/samply"
	cargo install --locked samply
	@echo ">>> Installing sd: https://github.com/chmln/sd"
	cargo install sd
	@cp "$(CRATES_SRC)/$$(sd -V | sd ' ' -)/gen/completions/_sd" $(ZSH_COMPLETIONS)
	@gzip -c "$(CRATES_SRC)/$$(sd -V | sd ' ' -)/gen/sd.1" \
		> $(XDG_MAN_HOME)/man1/sd.1.gz
	@echo ">>> Installing sqlx-cli: https://crates.io/crates/sqlx-cli"
	cargo install sqlx-cli
	@sqlx completions zsh > "$(ZSH_COMPLETIONS)/_sqlx"
	@echo ">>> Installing stylua: https://github.com/JohnnyMorganz/StyLua"
	cargo install stylua
	make -C $(CFG_DIR) tldr
	@echo ">>> Installing tokio-console: https://github.com/tokio-rs/console"
	cargo install --locked tokio-console
	@tokio-console gen-completion zsh > "$(ZSH_COMPLETIONS)/_tokio-console"
	@echo ">>> Installing xh: https://github.com/ducaale/xh"
	cargo install --locked xh
	@cp "$(CRATES_SRC)/$$(xh -V | sed 's| |-|g')/completions/_xh" $(ZSH_COMPLETIONS)
	@gzip -c "$(CRATES_SRC)/$$(xh -V | sed 's| |-|g')/doc/xh.1" \
		> $(XDG_MAN_HOME)/man1/xh.1.gz
	@echo ">>> Installing zoxide: https://github.com/ajeetdsouza/zoxide"
	cargo install zoxide --locked
	@gzip -c "$(CRATES_SRC)/$$(zoxide -V | sed 's| |-|g')/man/man1/zoxide.1" \
		> $(XDG_MAN_HOME)/man1/zoxide.1.gz

# TOML linter, formatter, and LSP
.PHONY: taplo
taplo: rust
	@echo ">>> Installing $@ CLI & LSP: https://github.com/tamasfe/taplo"
	cargo install --features lsp --locked taplo-cli

.PHONY: tldr
tldr: DOWNLOAD_URL := https://github.com/dbrgn/tealdeer/releases/download
tldr: $(ZSH_COMPLETIONS) $(XDG_CONFIG_HOME)/tealdeer net-tools rust
	@echo ">>> Installing $@: https://github.com/dbrgn/tealdeer"
	cargo install tealdeer
	@echo ">>> Configuring $$($@ -v)"
	@ln -svft $(XDG_CONFIG_HOME)/tealdeer $(CFG_CONFIG_HOME)/tealdeer/*
	@echo ">>> Downloading zsh completions for $$($@ -v)"
	@curl -sSL -o $</_$@ \
		"$(DOWNLOAD_URL)/v$$($@ -v | awk {'print $$2'})/completions_zsh"

# Resources:
#  - https://github.com/alacritty/alacritty/blob/master/INSTALL.md
# TODO: run alacritty on GPU (e.g., using `switcherooctl launch <CMD>`)
#  - https://github.com/alacritty/alacritty/issues/3587
.PHONY: alacritty
alacritty: DOWNLOAD_URL := https://github.com/alacritty/alacritty/releases/download
alacritty: DOWNLOAD_DIR := $(shell mktemp -d)
alacritty: BASE16_THEME := gruvbox-dark-hard
alacritty: \
	$(XDG_APPS_HOME) \
	$(XDG_CONFIG_HOME)/alacritty \
	$(XDG_ICONS_HOME)/hicolor/scalable/apps \
	$(XDG_MAN_HOME)/man1 \
	$(XDG_MAN_HOME)/man5 \
	$(ZSH_COMPLETIONS) \
	net-tools \
	rust \
	tinted-alacritty
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
		"$(DOWNLOAD_URL)/v$$($@ -V | awk {'print $$2'})/{$@.1.gz,$@-msg.1.gz,$@.5.gz,$@-bindings.5.gz,_$@,$@.info,Alacritty.desktop,Alacritty.svg}"
	@echo ">>> Configuring $@ terminfo"
	@sudo tic -xe $@,$@-direct "$(DOWNLOAD_DIR)/$@.info"
	@echo ">>> Configuring $@ desktop entry"
	@mv "$(DOWNLOAD_DIR)/Alacritty.svg" $(XDG_ICONS_HOME)/hicolor/scalable/apps
	@desktop-file-install --dir $(XDG_APPS_HOME) --rebuild-mime-info-cache \
		"$(DOWNLOAD_DIR)/Alacritty.desktop"
	@echo ">>> Configuring $@ man pages"
	@mv "$(DOWNLOAD_DIR)/$@"*.1.gz $(XDG_MAN_HOME)/man1
	@mv "$(DOWNLOAD_DIR)/$@"*.5.gz $(XDG_MAN_HOME)/man5
	@echo ">>> Configuring $@ zsh completions"
	@mv "$(DOWNLOAD_DIR)/_$@" $(ZSH_COMPLETIONS)
	@echo ">>> Configuring $@ colors theme"
	@ln -svf \
		"$(BASE16_ALACRITTY_HOME)/colors-256/base16-$(BASE16_THEME).toml" \
		"$(XDG_CONFIG_HOME)/$@/colors.toml"
	@echo ">>> Finish $@ completion setup by reloading zsh with 'omz reload'"
	@rm -rf $(DOWNLOAD_DIR)

# Base16 and Base24 themes for Alacritty
# https://github.com/tinted-theming/tinted-alacritty
.PHONY: tinted-alacritty
tinted-alacritty: URL := https://github.com/tinted-theming/tinted-alacritty.git
tinted-alacritty:
ifeq ($(shell test -d $(BASE16_ALACRITTY_HOME) && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating $@ repository in '$(BASE16_ALACRITTY_HOME)'"
	@git -C $(BASE16_ALACRITTY_HOME) pull
else
	@echo ">>> Cloning $@ repository to '$(BASE16_ALACRITTY_HOME)'"
	@git clone $(URL) $(BASE16_ALACRITTY_HOME)
endif

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
ifeq ($(shell test -d $(EXT_HOME) && echo -n yes 2> /dev/null),yes)
	@echo ">>> Updating $@ repository in '$(EXT_HOME)'"
	@git -C $(EXT_HOME) pull
else
	@echo ">>> Cloning $@ repository to '$(EXT_HOME)'"
	@git clone $(EXT_REPO) $(EXT_HOME)
endif
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

.PHONY: lua-language-server
lua-language-server: VERSION := $(shell gh_latest_release LuaLS/lua-language-server)
lua-language-server: PLATFORM := linux-x64
lua-language-server: REPO := https://github.com/LuaLS/lua-language-server
lua-language-server: $(XDG_DATA_HOME)/lua-language-server luajit
	@echo ">>> Installing $@ (v$(VERSION)): https://luals.github.io"
	@curl -sSL \
		"$(REPO)/releases/download/$(VERSION)/$@-$(VERSION)-$(PLATFORM).tar.gz" \
		| tar -C $< -xzf -
	@ln -svf $</bin/$@ $(XDG_BIN_HOME)/$@

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
shfmt: golang $(XDG_MAN_HOME)/man1
	@echo ">>> Installing $@: https://github.com/mvdan/sh"
	go install "$(SHFMT_MOD)/$(SHFMT_API)/cmd/$@@$(SHFMT_TAG)"
	@pandoc -s -t man \
		"$(GOPATH)/pkg/mod/$(SHFMT_MOD)/$(SHFMT_API)@$$($@ --version)/cmd/$@/$@.1.scd" \
		| gzip -c > $(XDG_MAN_HOME)/man1/$@.1.gz

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

# Installtion resources:
#  - [Official documentation](https://docs.docker.com/engine/install/ubuntu)
#  - [Official post-installation](https://docs.docker.com/engine/install/linux-postinstall)
#  - Note: `docker-compose` is now a sub-command `docker compose`
.PHONY: docker
docker: DOCKER_URL := https://download.docker.com/linux/ubuntu
docker: DOCKER_GPG := $(USR_KEYRINGS)/docker-archive-keyring.gpg
docker: core-utils apt-utils $(USR_KEYRINGS)
	@echo ">>> Downloading GPG key as '$(DOCKER_GPG)' & configuring apt sources"
	curl -fsSL $(DOCKER_URL)/gpg | sudo gpg --dearmor -o "$(DOCKER_GPG)"
	echo "deb [arch=$(DIST_ARCH) signed-by=$(DOCKER_GPG)] $(DOCKER_URL) $$(lsb_release -cs) stable" \
		| sudo tee /etc/apt/sources.list.d/$@.list > /dev/null
	@echo ">>> Installing $@: https://docs.docker.com/engine/install/ubuntu"
	sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
	@echo ">>> Setting up '$@' user group with current user '$(USER)'"
	sudo groupadd -f $@
	sudo gpasswd -a $(USER) $@
	sudo usermod -aG $@ $(USER)
	@echo ">>> Configuring Docker to start on boot"
	sudo systemctl enable $@.service containerd.service
	@echo ">>> Finishing Docker installation"
	sudo service $@ restart
	newgrp $@

.PHONY: test-docker
test-docker:
ifndef DOCKER_CMD
	$(error docker command not found)
else
	@echo ">>> Testing $$(docker --version)"
	docker run --rm hello-world:latest
	docker rmi -f hello-world:latest
endif

# FIXME: Unable to locate package nvidia-docker2
#  - possibly follow
#    https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html
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
nvidia-docker: NVIDIA_DOCKER_GPG := $(USR_KEYRINGS)/nvidia-docker-archive-keyring.gpg
nvidia-docker: DOCKERD_CFG := /etc/docker/daemon.json
nvidia-docker: core-utils net-tools apt-utils $(USR_KEYRINGS)
ifdef NVIDIA_CTRL
	@echo ">>> Installing NVIDIA Docker"
	@echo ">>> Downloading GPG key as '$(NVIDIA_DOCKER_GPG)' and configuring apt sources"
	curl -fsSL "$(NVIDIA_DOCKER_URL)/gpgkey" \
		| sudo gpg --dearmor -o "$(NVIDIA_DOCKER_GPG)"
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

# GitHub CLI (https://cli.github.com)
#  - https://github.com/cli/cli/blob/trunk/docs/install_linux.md
.PHONY: gh
gh: GH_URL := https://cli.github.com/packages
gh: GH_GPG := $(USR_KEYRINGS)/githubcli-archive-keyring.gpg
gh: zsh $(USR_KEYRINGS)
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

.PHONY: aws-cli
aws-cli:
	@echo ">>> Installing $@: https://docs.aws.amazon.com/cli/latest"
	@sudo snap install $@ --classic
	@echo ">>> Installed $$(aws --version)"

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
#
# TODO: figure out a way how to avoid explicit line ranges when (un)commenting
.PHONY: bash
bash: SYSTEM_BASHRC := /etc/bash.bashrc
bash: SYSTEM_BASH_LOGOUT := /etc/bash.bash.logout
bash: $(BASH_CONFIGS)
	@echo ">>> Enabling bash completion in interactive shells system-wide"
	@{ \
		LINE=$$(grep -in "enable bash completion" $(SYSTEM_BASHRC) | cut -d: -f1);\
		sudo sed -i "$$((LINE + 1)),$$((LINE + 7))"' s|^#||' "$(SYSTEM_BASHRC)";\
	}
	@echo ">>> Disabling sudo hint system-wide"
	@{ \
		LINE=$$(grep -in "sudo hint" $(SYSTEM_BASHRC) | cut -d: -f1);\
		sudo sed -i "$$((LINE + 1)),$$((LINE + 11))"' s|^#*|#|' "$(SYSTEM_BASHRC)";\
	}
ifeq ($(shell grep USER_BASHRC_RUN /etc/bash.bashrc),)
	@echo ">>> Adding custom bashrc loading to '$(SYSTEM_BASHRC)'"
	@echo "$$RUN_USER_BASHRC" | sudo tee -a "$(SYSTEM_BASHRC)" > /dev/null
endif
ifeq ($(shell grep -i "load bash_logout" /etc/bash.bash.logout),)
	@echo ">>> Adding custom bash_logout loading to '$(SYSTEM_BASH_LOGOUT)'"
	@echo "$$RUN_USER_BASH_LOGOUT" \
		| sudo tee -a "$(SYSTEM_BASH_LOGOUT)" > /dev/null
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

# Disable crash reporting service altogether to increase privacy & security
#  - Note that it also prevents the service from polluting HOME with the
#    ~/.apport-ignore.xml file
#  - https://askubuntu.com/a/93467
#  - XXX: `sudo apt purge -y apport apport-gtk apport-retrace apport-symptoms`
.PHONY: disable-apport-service
disable-apport-service:
	@echo ">>> Disabling apport service"
	sudo systemctl disable apport.service
	@echo ">>> Preventing apport service from starting after boot"
	@sudo sed -ri 's|^enabled\=(.+)$$|enabled\=0|g' /etc/default/apport
	@echo ">>> Purging configuration files"
	@rm -f ~/.apport-ignore.xml

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

# Configuration for various GNOME applications
# https://wiki.archlinux.org/title/GNOME
.PHONY: gnome
gnome: \
	evince \
	nautilus \
	com.ubuntu.update-notifier \
	org.gnome.calculator \
	org.gnome.calendar \
	org.gnome.desktop.interface \
	org.gnome.desktop.notifications \
	org.gnome.desktop.privacy \
	org.gnome.shell.ubuntu \
	org.gnome.system

.PHONY: com.ubuntu.update-notifier
com.ubuntu.update-notifier:
	@echo ">>> Configuring $@"
	@gsettings set $@ hide-reboot-notification true
	@gsettings set $@ show-apport-crashes false

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

.PHONY: org.gnome.shell.ubuntu
org.gnome.shell.ubuntu:
	@echo ">>> Configuring $@"
	@gsettings set $@ color-scheme 'default'

.PHONY: org.gnome.system
org.gnome.system:
	@echo ">>> Configuring $@"
	@gsettings set $@.locale region 'en_GB.UTF-8'
	@gsettings set $@.location enabled false

# XXX: set metadata:envince:xyz on pdf files
#  — https://unix.stackexchange.com/a/398111
#
# Resources:
#  - List current settings `gsettings list-recursively org.gnome.Evince`
.PHONY: evince
evince: org.gnome.Evince.Default

.PHONY: org.gnome.Evince.Default
org.gnome.Evince.Default:
	@echo ">>> Configuring $@"
	@gsettings set $@ continuous true
	@gsettings set $@ dual-page false
	@gsettings set $@ dual-page-odd-left false
	@gsettings set $@ inverted-colors false
	@gsettings set $@ show-sidebar true
	@gsettings set $@ sidebar-page 'links'
	@gsettings set $@ sidebar-size 216
	@gsettings set $@ sizing-mode 'automatic'
	@gsettings set $@ window-ratio "(2.0, 1.0)"
	@gsettings set $@ zoom 1.0

# XXX: load in bulk from an .ini file (persisted in this repo)
# - dconf dump /org/gnome/nautilus/ > nautilus.ini
# - dconf load /org/gnome/nautilus/ < nautilus.ini
# - possible issue: dconf ignores schema, so it's blind to defaults
#
# TODO: custom script to add metadata:evince to .pdf files
#  - https://wiki.archlinux.org/title/GNOME/Files
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
	@echo ">>> Finish bw completion setup by reloading zsh with 'omz reload'"
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
#  - official web page: https://zed.dev/docs/linux
#  - config docs: https://zed.dev/docs/configuring-zed
#  - installed artifacts: `~/.local/zed.app/`, `~/.local/bin/zed`,
#    `~/.local/share/applications/dev.zed.Zed.desktop`
#  - linked configs: `~/.config/zed/{keymap,settings}.json`
.PHONY: zed
zed: $(XDG_CONFIG_HOME)/zed net-tools
ifeq ($(shell which zed 2> /dev/null),)
	@echo ">>> Downloading & running $@ installer"
	curl https://zed.dev/install.sh | sh
endif
	@echo "Configuring $@ $$($@ -v | cut -d' ' -f2)"
	@ln -svft $(XDG_CONFIG_HOME)/$@ $(CFG_CONFIG_HOME)/$@/keymap.json
	@ln -svft $(XDG_CONFIG_HOME)/$@ $(CFG_CONFIG_HOME)/$@/settings.json

# Installation resources:
#  - calibre: ebook manager (https://calibre-ebook.com)
#  - luajit: Just-In-Time Compiler for Lua (https://luajit.org)
#  - mpv: command line video player (https://mpv.io)
.PHONY: calibre luajit mpv
calibre luajit mpv:
	@echo ">>> Installing $@"
	sudo apt install -y $@

# Installation resources:
#  - Needs pre-existing config directory to pick it up instead of HOME, see:
#    https://github.com/newsboat/newsboat/issues/2658#issuecomment-1886815612
#  - FIXME: snap install does not work, so this is a hacky workaround that
#    installs newsboat directly from an older (22.04) deb package
#  - TODO: consider installing latest version from source or fix snap install
#  - TODO: link default `urls` config file once it supports private includes
.PHONY: newsboat
newsboat: DEB_PKG := newsboat_2.21-1_$(DIST_ARCH).deb
newsboat: DOWNLOAD_URL := https://cz.archive.ubuntu.com/ubuntu/pool/universe/n
newsboat: DOWNLOAD_DIR := $(shell mktemp -d)
newsboat: \
	$(XDG_CONFIG_HOME)/newsboat \
	$(XDG_CACHE_HOME)/newsboat/articles \
	$(XDG_CACHE_HOME)/newsboat/podcasts \
	$(XDG_DATA_HOME)/newsboat \
	mpv
ifeq ($(shell which newsboat 2> /dev/null),)
	@echo ">>> Installing $@ dependencies"
	sudo apt install -y libstfl0
	@echo ">>> Downloading $@"
	$(WGET) -q -P $(DOWNLOAD_DIR) "$(DOWNLOAD_URL)/$@/$(DEB_PKG)"
	@echo ">>> Verifying dowloaded $@ file integrity"
	@(echo -n \
		"8522128a78c6ef705b825cabd712e06a28616d216a2788f653c2bec821f4673c $(DOWNLOAD_DIR)/$(DEB_PKG)" \
		| sha256sum -c --strict --status --ignore-missing -) || \
		(echo ">>> Failed to verify checksum" && rm -rf $(DOWNLOAD_DIR) && exit 1)
	@echo ">>> Installing $@"
	sudo dpkg -i "$(DOWNLOAD_DIR)/$(DEB_PKG)" \
		|| (rm -rf $(DOWNLOAD_DIR) && exit 1)
endif
	@echo ">>>> Configuring $@ (note: edit '$</urls' manually)"
	@touch $</urls && chmod u=rw,g=r,o= $</urls
	@ln -svft $< $(CFG_CONFIG_HOME)/$@/*
	@echo ">>> Installed $$($@ -v | head -1)"

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
