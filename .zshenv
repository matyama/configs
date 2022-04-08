# This file sets environment variables that should be globally set on the system
#
# See:
#  - https://unix.stackexchange.com/a/71258
#  - https://www.zerotohero.dev/zshell-startup-files/
#
# Note:
#  - Since other zsh config files (e.g. `.zprofile` or `.zshrc`) will be loaded
#  after `.zshenv`, environment variable exported here might be overwritten
#  - Namely, this involves `$PATH`, so watch for potential issues

# System and architecture
export ARCH=$(uname -m)

# Compilation flags
# export ARCHFLAGS="-arch $ARCH"

# Editor setup
export VISUAL=nvim
export EDITOR=${VISUAL}
export VIMRC=${XDG_CONFIG_HOME}/nvim/init.vim

# Personal user info
export NAME="Martin Matyášek"
export EMAIL=martin.matyasek@gmail.com

# Binenv
export BINENV_HOME=${HOME}/.binenv

# Poetry
export POETRY_BIN=${HOME}/.poetry/bin

# Rust stuff
export CARGO_BIN=${HOME}/.cargo/bin
export CARGO_INCREMENTAL=1
export RUSTFLAGS="-C target-cpu=native"
export RUST_BACKTRACE=1

# Haskell stack
export STACK_ROOT=${HOME}/.stack

# Go lang
export GOPATH=${HOME}/go
export GOBIN=${GOPATH}/bin

# Kubernetes Krew
export KREW_ROOT=${HOME}/.krew
export KREW_BIN=${KREW_ROOT}/bin

# Ruby
export GEM_HOME=${HOME}/.gem
#export GEM_BIN=${GEM_HOME}/bin
export RUBY_BIN=${GEM_HOME}/ruby/3.0.0/bin

# Base16
export BASE16_FZF_HOME=${XDG_CONFIG_HOME}/base16-fzf
export BASE16_SHELL_HOME=${XDG_CONFIG_HOME}/base16-shell

# Bat
export BAT_CONFIG_DIR=${XDG_CONFIG_HOME}/bat
export BAT_CONFIG_PATH=${BAT_CONFIG_DIR}/config

# fd
export FD_CONFIG_HOME=${XDG_CONFIG_HOME}/fd

# rg
export RIPGREP_CONFIG_HOME="${XDG_CONFIG_HOME}/rg"
export RIPGREP_CONFIG_PATH=${RIPGREP_CONFIG_HOME}/ripgreprc

# Path extension
export PATH=${PATH}:${HOME}/bin
export PATH=${PATH}:${HOME}/.local/bin
export PATH=${PATH}:${CARGO_BIN}
export PATH=${PATH}:${POETRY_BIN}
export PATH=${PATH}:${GOBIN}
#export PATH=${PATH}:${GEM_BIN}
export PATH=${PATH}:${KREW_BIN}
export PATH=${PATH}:${RUBY_BIN}
export PATH=${PATH}:/usr/local/bin
export PATH=${PATH}:${BINENV_HOME}

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

# TODO: move fzf config to .zshrc?
# 
# > Note that it is not important to set things like FZF_DEFAULT_COMMAND
# here since that is only relevant when using an interactive shell, so we may
# as well just set that directly in the shell config.

# fzf
# https://github.com/junegunn/fzf#layout
export FZF_DEFAULT_COMMAND="fd --type file --follow --hidden"
export FZF_CTRL_T_COMMAND="fd --type file --follow --hidden"
export FZF_DEFAULT_OPTS="--height 20% --layout=reverse --border"

# Colored man output
# See: http://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline

# make less better
# X = leave content on-screen
# F = quit automatically if less than one screenfull
# R = raw terminal characters (fixes git diff)
#     see http://jugglingbits.wordpress.com/2010/03/24/a-better-less-playing-nice-with-git/
export LESS="-F -X -R"

