.PHONY: install install-pam-env install-xcfg install-zsh-cfg install-zsh-custom install-byobu install-nvim install-poetry-cfg install-git install-guake install-fonts

ifndef ZSH_CUSTOM
ZSH_CUSTOM=~/.oh-my-zsh/custom
endif

ifndef BYOBU_CONFIG_DIR 
BYOBU_CONFIG_DIR=~/.byobu
endif

~/.config/nvim:
	mkdir -p ~/.config/nvim

~/.config/nvim/vim-plug:
	mkdir -p ~/.config/nvim/vim-plug

~/.config/pypoetry:
	mkdir -p ~/.config/pypoetry

~/.local/share/fonts:
	mkdir -p ~/.local/share/fonts

install-fonts: ~/.local/share/fonts
	@echo "Downloading Meslo Nerd Font for Powerlevel10k"
	curl "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20{Regular,Bold,Italic,Bold%20Italic}.ttf" -o ~/.local/share/fonts/"MesloLGS NF #1.ttf"
	mv ~/.local/share/fonts/MesloLGS\ NF\ Bold%20Italic.ttf ~/.local/share/fonts/MesloLGS\ NF\ Bold\ Italic.ttf

install-xcfg:
	cp .xsession ~

install-zsh-cfg:
	cp .p10k.zsh .zshenv .zshrc .zlogout ~ 

install-zsh-custom:
	cp -a .oh-my-zsh/custom/. $(ZSH_CUSTOM)

install-byobu:
	cp -a .byobu/. $(BYOBU_CONFIG_DIR)

install-nvim: ~/.config/nvim  ~/.config/nvim/vim-plug
	cp -a .config/nvim/. ~/.config/nvim

install-poetry-cfg: ~/.config/pypoetry
	cp -a .config/pypoetry/. ~/.config/pypoetry
	@echo "Finish setup by manually configuring auth tokens - see https://python-poetry.org/docs/repositories/#configuring-credentials"

install-git:
	cp .gitconfig ~

install-guake:
	guake --restore-preferences guake.conf

install-pam-env:
	cp .pam_environment ~
	@[ "$$(grep 'user_readenv=1' /etc/pam.d/login)" ] || \
		echo "Finish setup by manually updating '/etc/pam.d/login' - see https://askubuntu.com/a/636544"

install: install-pam-env install-xcfg install-zsh-cfg install-zsh-custom install-byobu install-nvim install-poetry-cfg install-git install-guake

