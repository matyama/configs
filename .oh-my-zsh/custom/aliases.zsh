# ZSH
alias zshreload="source ~/.zshrc"
alias zshconfig="nvim ~/.zshrc"

# XDG
alias o="xdg-open"

# Copy/Paste
alias y="xclip -i -selection clipboard"
alias c="xclip -i -selection clipboard"
alias p="xclip -o -selection clipboard"
alias rmclip="echo '' | c"

# Command auto-correction
if [ "$(command -v fuck)" ]; then
	alias f="fuck"
fi

# EDITOR
alias e="nvim"
alias v="nvim"
alias vim="nvim"
alias vi="nvim"
alias oldvim="\vim"
alias vimdiff="nvim -d"

# PDF

# Concatenate pdf files passed as arguments and output final pdf to stdout
alias pdfconcat="gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -dPDFSETTINGS=/prepress -sOutputFile=/dev/stdout"

# Git
alias gah="git stash && git pull --rebase && git stash pop"

# make
alias m="make"

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# exa (https://the.exa.website/)
if [ "$(command -v exa)" ]; then
	alias l="exa -lahg@ --git"
	alias lcd="l && cd"
	alias cdl='cdls() { cd "$@" && l; }; cdls'
fi

# bat (https://github.com/sharkdp/bat)
if [ "$(command -v bat)" ]; then
	alias b="bat"
	alias bp="bat --plain"
fi

# googler (https://github.com/jarun/googler)
if [ "$(command -v googler)" ]; then
	alias s="googler"
fi

# Python
alias jl="jupyter lab --ContentsManager.allow_hidden=True"

# Haskell
if [ "$(command -v ghc)" ]; then
	# Quick check if Haskell source file(s) compile
	alias hsc="ghc -no-keep-o-files -no-keep-hi-files"
	alias hscdir="ghc -no-keep-o-files -no-keep-hi-files *.hs"
fi
