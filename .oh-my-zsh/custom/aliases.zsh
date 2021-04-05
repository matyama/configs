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

# Git
alias gah="git stash && git pull --rebase && git stash pop"

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# exa (https://the.exa.website/)
if [ "$(command -v exa)" ]; then
	alias l="exa -lahg@ --git"
fi

# Python
alias jl="jupyter lab --ContentsManager.allow_hidden=True"

