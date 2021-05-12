.PHONY: \
	config \
	pam-env \
	x-cfg \
	zsh-cfg \
	zsh-custom \
	byobu-cfg \
	nvim-cfg \
	poetry-cfg \
	git-cfg \
	guake-cfg \
	install-fonts

ifndef ZSH_CUSTOM
ZSH_CUSTOM=~/.oh-my-zsh/custom
endif

ifndef BYOBU_CONFIG_DIR 
BYOBU_CONFIG_DIR=~/.byobu
endif

FONTS_DIR := ~/.local/share/fonts

~/.config/nvim:
	mkdir -p ~/.config/nvim

~/.config/nvim/vim-plug:
	mkdir -p ~/.config/nvim/vim-plug

~/.config/pypoetry:
	mkdir -p ~/.config/pypoetry

$(FONTS_DIR):
	mkdir -p $(FONTS_DIR)

install-fonts: P10K_URL := https://github.com/romkatv/powerlevel10k-media/raw/master
install-fonts: $(FONTS_DIR)
	@echo "Downloading Meslo Nerd Font for Powerlevel10k"
	curl "$(P10K_URL)/MesloLGS%20NF%20{Regular,Bold,Italic,Bold%20Italic}.ttf" \
		-o $(FONTS_DIR)/"MesloLGS NF #1.ttf"
	mv $(FONTS_DIR)/MesloLGS\ NF\ Bold%20Italic.ttf $(FONTS_DIR)/MesloLGS\ NF\ Bold\ Italic.ttf

x-cfg:
	cp .xsession ~

zsh-cfg:
	cp .p10k.zsh .zshenv .zshrc .zlogout ~ 

zsh-custom:
	cp -a .oh-my-zsh/custom/. $(ZSH_CUSTOM)

byobu-cfg:
	cp -a .byobu/. $(BYOBU_CONFIG_DIR)

nvim-cfg: ~/.config/nvim  ~/.config/nvim/vim-plug
	cp -a .config/nvim/. ~/.config/nvim

poetry-cfg: ~/.config/pypoetry
	cp -a .config/pypoetry/. ~/.config/pypoetry
	@echo "Finish setup by manually configuring auth tokens - see https://python-poetry.org/docs/repositories/#configuring-credentials"

git-cfg:
	cp .gitconfig ~

guake-cfg:
	guake --restore-preferences guake.conf

pam-env:
	cp .pam_environment ~
	@[ "$$(grep 'user_readenv=1' /etc/pam.d/login)" ] || \
		echo "Finish setup by manually updating '/etc/pam.d/login' - see https://askubuntu.com/a/636544"

configure: pam-env x-cfg zsh-cfg zsh-custom byobu-cfg nvim-cfg poetry-cfg git-cfg guake-cfg

