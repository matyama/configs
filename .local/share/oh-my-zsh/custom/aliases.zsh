# ZSH
alias zenv="nvim ${ZDOTDIR}/.zshenv"
alias zconf="nvim ${ZDOTDIR}/.zshrc"

# XDG
alias o="xdg-open"

# Copy/Paste
alias y="xclip -i -selection clipboard"
alias c="xclip -i -selection clipboard"
alias p="xclip -o -selection clipboard"
alias rmclip="echo '' | c"

# Command auto-correction
(( $+commands[fuck] )) && alias f="fuck"

# EDITOR
alias e="nvim"
alias v="nvim"
alias vim="nvim"
alias vi="nvim"
alias oldvim="\vim"
alias vimdiff="nvim -d"

# Search file with fzf and open in with the editor
(( $+commands[fzf] )) && alias ef='e $(fzf)'

# PDF

# Concatenate pdf files passed as arguments and output final pdf to stdout
#  - Example: `pdfconcat in-*.pdf > out.pdf`
alias pdfconcat="gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -dPDFSETTINGS=/prepress -sOutputFile=%stdout"

# Extract given range of pages from a pdf file and output to stdout
#  - Example: `pdfextract 2,6-9,11,42- in.pdf > out.pdf`
#  - TODO: disable or otherwise fix pdfmark error (seem to have no effect)
alias pdfextract='pdfext() { gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sPageList="$1" -sOutputFile=%stdout "$2" ; }; pdfext'

# Git
alias gah="git stash && git pull --rebase && git stash pop"

# make
alias m="make"

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# history
alias hg='history | egrep'

# exa (https://the.exa.website/)
(( $+commands[exa] )) && alias l="exa -lahg@ --git"

# bat (https://github.com/sharkdp/bat)
if (( $+commands[bat] )); then
	alias b="bat"
	alias bp="bat --plain"
fi

# googler (https://github.com/jarun/googler)
(( $+commands[googler] )) && alias s="googler"

# Python
alias py="python3"
alias jl="jupyter lab --ContentsManager.allow_hidden=True"

# Haskell
if (( $+commands[ghc] )); then
	# Quick check if Haskell source file(s) compile
	alias hsc="ghc -no-keep-o-files -no-keep-hi-files"
	alias hscdir="ghc -no-keep-o-files -no-keep-hi-files *.hs"
fi

