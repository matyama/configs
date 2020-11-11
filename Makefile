.PHONY: install install-xinitrc install-zsh-custom install-byobu install-nvim install-git

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

install-xinitrc:
	cp .xinitrc ~

install-zsh-custom:
	cp -a .oh-my-zsh/custom/. "$(ZSH_CUSTOM)"

install-byobu:
	cp -a .byobu/. "$(BYOBU_CONFIG_DIR)"

install-nvim: ~/.config/nvim  ~/.config/nvim/vim-plug
	cp -a .config/nvim/. ~/.config/nvim

install-git:
	cp .gitconfig ~

install: install-xinitrc install-zsh-custom install-byobu install-nvim install-git

