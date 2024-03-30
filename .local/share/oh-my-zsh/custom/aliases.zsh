# ZSH
alias zenv="nvim ${ZDOTDIR}/.zshenv"
alias zconf="nvim ${ZDOTDIR}/.zshrc"

# XDG
alias o="xdg-open"

# Copy/Paste
alias y="wl-copy"
alias c="wl-copy"
alias p="wl-paste"
alias rmclip="wl-copy -c"

# Find why is a given package installed via apt
#  - Based on a comment under this answer: https://askubuntu.com/a/5637
alias why="apt-cache rdepends --no-{suggests,conflicts,breaks,replaces,enhances} --installed --recurse"

# Bitwarden
#  - https://bitwarden.com/help/cli/#log-in
#  - NOTE: currently using two-step login via an authenticator app
#  - TODO: switch to FIDO2 two-step login method once supported by the app
alias bwl="bw login --method 0 ${EMAIL}"

# Command auto-correction
(( $+commands[fuck] )) && alias f="fuck"

# EDITOR
alias e="nvim"
alias ep="nvim -p"
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

# just
(( $+commands[just] )) && alias j="just"

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# history
alias hg='history | egrep'

# Ansible
if (( $+commands[ansible-lint] )); then
	alias alint="ansible-lint"
fi

# eza (https://eza.rocks)
(( $+commands[eza] )) && alias l="eza -lahg@ --git"

# bat (https://github.com/sharkdp/bat)
if (( $+commands[bat] )); then
	alias b="bat"
	alias bp="bat --plain"
fi

# chafa (https://github.com/hpjansson/chafa)
(( $+commands[chafa] )) && alias imshow="chafa -c 256"

# Docker
if (( $+commands[docker] )); then
	alias dvpd='docker volume rm $(docker volume ls -qf dangling=true)'
fi

# parallel-ssh (https://github.com/ParallelSSH/parallel-ssh)
if (( $+commands[parallel-ssh] )); then
	alias pssh="parallel-ssh"
	alias pscp="parallel-scp"
	alias prsync="parallel-rsync"
	alias pnuke="parallel-nuke"
	alias pslurp="parallel-slurp"
fi

# wireguard (https://wiki.archlinux.org/title/WireGuard)
if (( $+commands[wg-quick] )); then
	alias wgup="sudo wg-quick up"
	alias wgdn="sudo wg-quick down"
fi

# hyperfine (https://github.com/sharkdp/hyperfine)
if (( $+commands[hyperfine] )); then
	alias bench="hyperfine -S zsh"
fi

# Newsboat RSS/Atom feed reader (https://newsboat.org)
if (( $+commands[newsboat] )); then
	alias news="newsboat -q"
	alias podcasts="podboat -a"
fi

# googler (https://github.com/jarun/googler)
(( $+commands[googler] )) && alias s="googler"

# Python
alias py="python3"
alias wp="which python"
alias jl="jupyter lab --ContentsManager.allow_hidden=True"

# Haskell
if (( $+commands[ghc] )); then
	# Quick check if Haskell source file(s) compile
	alias hsc="ghc -no-keep-o-files -no-keep-hi-files"
	alias hscdir="ghc -no-keep-o-files -no-keep-hi-files *.hs"
fi

