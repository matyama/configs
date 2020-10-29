#!/bin/bash

set -e 

show_help() {
	echo "install.sh <xinitrc|zsh-custom|nvim|all|-h|--help>"
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

cp_nvim() {
	echo ">>> Copying NeoVim configs"
	mkdir -p ~/.config/nvim
	cp -a .config/nvim/. ~/.config/nvim
}

case "${1}" in
	xinitrc)
		cp_xinitrc
		;;
	zsh-custom)
		cp_zsh_custom
		;;
	nvim)
		cp_nvim
		;;
	all)
		cp_xinitrc
		cp_zsh_custom
		cp_nvim
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

