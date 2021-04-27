.PHONY: install install-pam-env install-xcfg install-zsh-cfg install-zsh-custom install-byobu install-nvim install-poetry-cfg install-git install-guake

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

install-xcfg:
	cp .xsession ~

install-zsh-cfg:
	cp .zshenv .zlogout ~ 

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
	@echo "Finish setup by manually updating '/etc/pam.d/login' - see https://askubuntu.com/a/636544"

install: install-pam-env install-xcfg install-zsh-cfg install-zsh-custom install-byobu install-nvim install-poetry-cfg install-git install-guake

