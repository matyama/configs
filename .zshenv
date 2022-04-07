# System and architecture
export ARCH=$(uname -m)

# Compilation flags
# export ARCHFLAGS="-arch $ARCH"

# TODO: Move history management to .zshrc
# History management
#  - https://stackoverflow.com/a/38549502
#  - https://unix.stackexchange.com/a/273863
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export SAVEHIST="${HISTSIZE}"
export HISTFILESIZE=10000
export HISTIGNORE="clear:bg:fg:cd:cd -:cd ..:cd ~:exit:date:w:* --help:h:ls:la:l:ll:exa"
export HISTORY_IGNORE="(clear|bg|fg|cd|cd -|cd ..|cd ~|exit|date|w|* --help|h|ls|la|l|ll|exa)"

zshaddhistory() {
  emulate -L zsh
  ## uncomment if HISTORY_IGNORE should use EXTENDED_GLOB syntax
  # setopt extendedglob
  [[ $1 != ${~HISTORY_IGNORE} ]]
}

setopt hist_ignore_all_dups
setopt hist_ignore_space

# Colored man output
# See: http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline

# fzf
# https://github.com/junegunn/fzf#layout
export FZF_DEFAULT_COMMAND="fd --type file --follow --hidden"
export FZF_CTRL_T_COMMAND="fd --type file --follow --hidden"
export FZF_DEFAULT_OPTS="--height 20% --layout=reverse --border"
