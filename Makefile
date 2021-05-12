.PHONY: config links guake.conf save-guake-conf install-fonts

# Absolute path to the directory containing this Makefile
#  - This path remains the same even when invoked with 'make -f ...'
#  - [source](https://stackoverflow.com/a/23324703)
CFG_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ifndef ZSH_CUSTOM
ZSH_CUSTOM=~/.oh-my-zsh/custom
endif

ifndef BYOBU_CONFIG_DIR 
BYOBU_CONFIG_DIR=~/.byobu
endif

FONTS_DIR := ~/.local/share/fonts

$(FONTS_DIR):
	mkdir -p $(FONTS_DIR)

$(BYOBU_CONFIG_DIR):
	mkdir -p $(BYOBU_CONFIG_DIR)

$(ZSH_CUSTOM):
	mkdir -p $(ZSH_CUSTOM)

~/.config/nvim/vim-plug:
	mkdir -p ~/.config/nvim/vim-plug

~/.config/pypoetry:
	mkdir -p ~/.config/pypoetry

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

links: $(BYOBU_CONFIG_DIR) ~/.config/nvim/vim-plug ~/.config/pypoetry $(ZSH_CUSTOM)
	@echo "Linking configuration files:"
	@ln -svft ~ \
		$(CFG_DIR)/.xsession \
		$(CFG_DIR)/.gitconfig \
		$(CFG_DIR)/.pam_environment \
		$(CFG_DIR)/.zsh* \
		$(CFG_DIR)/.p10k.zsh
	@{ \
		for cfg in $$(find $(CFG_DIR)/.byobu $(CFG_DIR)/.config $(CFG_DIR)/.oh-my-zsh/custom -type f); do \
			ln -svf $$cfg "$(HOME)$${cfg#$(CFG_DIR)}";\
		done;\
	}
	@[ "$$(grep 'user_readenv=1' /etc/pam.d/login)" ] || \
		echo "Finish pam env setup by manually updating '/etc/pam.d/login' - see https://askubuntu.com/a/636544"
	@echo "Finish Poetry setup by manually configuring auth tokens: https://bit.ly/3fdpMNR"

config: guake.conf links 
