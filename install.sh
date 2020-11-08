#!/bin/bash

set -e 

show_help() {
	echo "install.sh <xinitrc|zsh-custom|byobu|nvim|git|all|-h|--help>"
}

cp_xinitrc() {
	echo ">>> Copying init X config. Use 'source ~/.xinitrc' to apply changes in current shell"
	# FIXME: .xintrc does not seem to have permanent effect (i.e. sometimes is not executed)
	cp .xinitrc ~
	source ~/.xinitrc
}

cp_zsh_custom() {
	if [[ -z "${ZSH_CUSTOM}" ]]; then
		ZSH_CUSTOM=~/.oh-my-zsh/custom
		echo ">>> Using default ZSH_CUSTOM=${ZSH_CUSTOM}"
	fi
	
	echo ">>> Copying custom ZSH configs. Use 'source ~/.zshrc' to apply changes in current shell"
	cp -a .oh-my-zsh/custom/. "${ZSH_CUSTOM}"
}

cp_byobu() {
	if [[ -z "${BYOBU_CONFIG_DIR}" ]]; then
		BYOBU_CONFIG_DIR=~/.byobu
		echo ">>> Using default BYOBU_CONFIG_DIR=${BYOBU_CONFIG_DIR}"
	fi

	echo ">>> Copying custom byobu and tmux configs"
	cp -a .byobu/. "${BYOBU_CONFIG_DIR}"
}

cp_nvim() {
	echo ">>> Copying NeoVim configs"
	mkdir -p ~/.config/nvim ~/.config/nvim/vim-plug
	cp -a .config/nvim/. ~/.config/nvim
}

cp_git() {
	echo ">>> Copying git config"
	cp .gitconfig ~
}

case "${1}" in
	xinitrc)
		cp_xinitrc
		;;
	zsh-custom)
		cp_zsh_custom
		;;
	byobu)
		cp_byobu
		;;
	nvim)
		cp_nvim
		;;
	git)
		cp_git
		;;

	all)
		cp_xinitrc
		cp_zsh_custom
		cp_byoby
		cp_nvim
		cp_git
		;;
	-h|--help)
		show_help
		;;
	*)
		echo ">>> Argument not recognized. Usage:"
		show_help
		exit 1
		;;
esac

