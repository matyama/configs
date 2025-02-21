# shellcheck shell=bash

export DEFAULT_USER=matyama

########################################################
##### UPDATE FPATH
########################################################

# TODO: add completions conditionally only if binary is installed
# Export directory for user-defined completions
export ZSH="${XDG_DATA_HOME:-$HOME/.local}/zsh"
export ZSH_COMPLETIONS="${ZSH}/completions"
export ZSH_FUNCTIONS="${ZSH}/functions"

# Modify fpath
# shellcheck disable=SC2206
typeset -gaU fpath=($fpath $ZSH_COMPLETIONS)

########################################################
##### SETUP PLUGIN MANAGER (ZINIT)
########################################################

# Set up the directory to store zinit and plugins
export ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
ZINIT_DATA_DIR="$(dirname ${ZINIT_HOME})"
export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$XDG_CACHE_HOME/zinit}"

# Download zinit, if it's not there yet
if [ ! -d "${ZINIT_HOME}" ]; then
  mkdir -p \
    "${ZINIT_DATA_DIR}" \
    "${ZSH_CACHE_DIR}"/completions \
    "${ZSH_COMPLETIONS}" \
    "${ZSH_FUNCTIONS}"

  git clone https://github.com/zdharma-continuum/zinit "${ZINIT_HOME}"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

########################################################
##### PROMPT / THEME
########################################################

# Reevaluate the prompt string each time zsh wants to display a prompt
setopt promptsubst

ZSH_THEME=romkatv/powerlevel10k

# XXX: wait/load
# Prompt: Powerlevel10k
# To customize prompt, run `p10k configure` or edit `POWERLEVEL9K_CONFIG_FILE`
zinit wait'!' lucid nocd \
  if'[[ "${ZSH_THEME}" = */powerlevel10k ]]' \
  atinit"!
    # Disable p10k configuration wizard
    POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true" \
  atload"!
    # Set p10k configuration file
    case ${TERM_PROGRAM:-$TERM} in
      # Rainbow prompt style does now display correctly in vscode terminal, so
      # use p10k-vscode.zsh there instead.
      vscode)
        POWERLEVEL9K_CONFIG_FILE=${XDG_CONFIG_HOME}/zsh/p10k-vscode.zsh
        ;;
      *)
        POWERLEVEL9K_CONFIG_FILE=${XDG_CONFIG_HOME}/zsh/p10k.zsh
        ;;
    esac
    source \${POWERLEVEL9K_CONFIG_FILE}
    _p9k_precmd" \
  for "${ZSH_THEME}"

# XXX: Prompt: Starship
#  - https://zdharma-continuum.github.io/zinit/wiki/Multiple-prompts
#zinit lucid for \
#    as"command" \
#    from"gh-r" \
#    atinit"
#      export N_PREFIX=$HOME/n
#      [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"" \
#    atload'eval "$(starship init zsh)"' \
#    starship/starship

########################################################
##### ZINIT PLUGINS, SNIPPETS, AND COMPLETIONS
########################################################

# XXX: wait with some high precedence (e.g., 0a)
# XXX: move some of OMZL::git.zsh to git aliases instead
# TODO: maybe set some OMZL::directories.zsh options / aliases
# TODO: update c/p aliases to use clipcopy/clippaste
# TODO: replace OMZL::history with PZT::modules/history
#  - or set manually
#
# Priority plugins/libs
#  1. Load history early to prevent empty history stack for other plugins
#  2. Load OMZ library snippets, some of which are pre-requisites for plugins
#  3. Load tmux first to prevent jumps when it is loaded after zshrc
#     (adds some useful aliases for tmux)
zinit lucid for \
  is-snippet \
  OMZL::{'clipboard','completion','git','grep','history','key-bindings'}.zsh \
  has"tmux" atinit"
      ZSH_TMUX_FIXTERM=false
      ZSH_TMUX_AUTOSTART=false
      ZSH_TMUX_AUTOCONNECT=false" \
  OMZP::tmux

# FIXME: aws completions
# XXX: deprecate OMZP::history (add to custom aliases or OMZL::history atload)
# TODO: deprecate OMZP::minikube (resp., generate as completions)
# TODO: deprecate OMZP::poetry (resp., generate as completions)
# TODO: OMZP::poetry is just completion definition
# TODO: OMZP::poetry just generates and sources completions (gen on update)
# XXX: OMZ::git -> gitfast (zinit svn snippet for OMZP::gitfast)
# TODO: https://zdharma-continuum.github.io/zinit/wiki/Direnv-explanation
#
#
# Resuorces:
#  - https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
#  - https://github.com/zdharma-continuum/zinit#migration
#  - https://zdharma-continuum.github.io/zinit/wiki/Example-Oh-My-Zsh-setup
#
# OMZ plugins/snippets/completions
#  - ansible                       adds some useful aliases for ansible
#  - aws                           completion support for awscli & few utilities
#  - copybuffer                    copy shell buffer to clipboard with ctrl-o
#  - direnv                        creates the direnv hook
#  - docker                        adds auto-completion and aliases for docker
#  - docker-compose                adds completion & some aliases
#  - fzf                           enables fuzzy auto-completion & key bindings
#  - gh                            adds completion for the GitHub CLI
#  - git                           adds many aliases & few useful functions
#  - helm                          adds completion for helm
#  - history                       adds a couple of convenient aliases
#  - kubectl                       adds completion & some aliases
#  - minikube                      adds completion for minikube
#  - nmap                          adds some useful aliases for Nmap
#  - pip                           adds completion & some aliases
#  - poetry                        adds completion & keeps it up to date
#  - rust                          adds completion for rustc, rustup and cargo
#  - sdk                           adds auto-completion for sdk
#  - stack                         adds auto-completion for stack
#  - terraform                     adds completion, aliases & a prompt function
#  - zsh-interactive-cd            provides fish-like interactive cd completion
zinit wait lucid for \
  has'ansible' OMZP::ansible \
  has'aws' OMZP::aws \
  OMZP::copybuffer \
  has'direnv' OMZP::direnv \
  has'docker' OMZP::docker \
  has'docker' as'completion' \
  atinit"
    # Enable option stacking in docker auto-completion
    #  - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker#settings
    zstyle ':completion:*:*:docker:*' option-stacking yes
    zstyle ':completion:*:*:docker-*:*' option-stacking yes" \
  OMZP::docker/completions/_docker \
  has'docker-compose' OMZP::docker-compose \
  has'docker-compose' as'completion' OMZP::docker-compose/_docker-compose \
  has'fzf' OMZP::fzf \
  has'gh' OMZP::gh \
  OMZP::git \
  has'helm' OMZP::helm \
  OMZP::history \
  has'kubectl' OMZP::kubectl \
  has'minikube' OMZP::minikube \
  has'nmap' OMZP::nmap \
  has'pip' OMZP::pip \
  has'pip' as'completion' OMZP::pip/_pip \
  has'poetry' OMZP::poetry \
  has'rustc' as'completion' OMZP::rust/_rustc \
  has'rustup' has'cargo' OMZP::rust \
  OMZP::sdk \
  has'stack' OMZP::stack \
  has'terraform' OMZP::terraform \
  has'terraform' as'completion' OMZP::terraform/_terraform \
  OMZP::zsh-interactive-cd

# FIXME: zsh-autosuggestions is too slow to load
# Resources
#  - aws-vault: provides autocompletion
#  - forgit: interactive git+fzf & overrides git aliases
#    https://github.com/wfxr/forgit
#  - mcfly: intelligent history search
#    https://github.com/cantino/mcfly
#  - pandoc: pandoc autocompletion
#  - pipx: pipx autocompletion
#    https://pipx.pypa.io/latest/installation/#shell-completion
#  - skim: loads skim key-bindings
#    https://github.com/skim-rs/skim
#  - zoxide: smarter cd command
#    https://github.com/ajeetdsouza/zoxide
#  - zsh-autosuggestions: provides fish-like autosuggestions
#    https://github.com/zsh-users/zsh-autosuggestions
#
# XXX: forgit: alternatively use `atload"!PATH+=:${FORGIT_INSTALL_DIR}/bin"`
# XXX: pandoc, pipx: ensure `autoload -U +X bashcompinit && bashcompinit`
zinit wait lucid for \
  has'aws-vault' as'completion' is-snippet id-as'aws-vault' \
  atinit'source ${ZINIT_DATA_DIR}/snippets/aws-vault/aws-vault' \
  https://raw.githubusercontent.com/99designs/aws-vault/master/contrib/completions/zsh/aws-vault.zsh \
  has'fzf' atclone="ln -sft ${XDG_BIN_HOME} \$PWD/bin/*" atpull"%atclone" \
  atinit"export FORGIT_COPY_CMD='wl-copy'" \
  wfxr/forgit \
  has'mcfly' as'null' id-as'mcfly' \
  atinit"
      MCFLY_KEY_SCHEME=vim
      MCFLY_FUZZY=2
      MCFLY_RESULTS=20
      MCFLY_HISTORY_LIMIT=10000
      # NOTE: overrides Ctrl+R from the OMZP::fzf plugin above
      eval $(mcfly init zsh)" \
  zdharma-continuum/null \
  has'pandoc' as'null' id-as'pandoc' \
  atinit='eval "$(pandoc --bash-completion)"' \
  zdharma-continuum/null \
  has'pipx' as'null' id-as'pipx' \
  atinit'eval "$(register-python-argcomplete pipx)"' \
  zdharma-continuum/null \
  has'sk' as'null' id-as'skim' \
  atinit'source "${SKIM_BASE}/shell/key-bindings.zsh"' \
  zdharma-continuum/null \
  has'zoxide' as'null' id-as'zoxide' \
  atinit"
      eval $(zoxide init --cmd cd zsh)
      alias cdf=cdi" \
  zdharma-continuum/null \
  atinit"
    # Disable suggestion for large buffers
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
    # Accept autosuggestion with <Ctrl><Space>
    bindkey '^ ' autosuggest-accept
    # Accept and execute current suggestion with Ctrl+x
    bindkey '^x' autosuggest-execute" \
  atload="!_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions

# TODO: fast-syntax-highlighting (zsh-syntax-highlighting is too slow to load)
# https://github.com/zdharma-continuum/fast-syntax-highlighting
#zinit wait lucid for \
# atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
#    zdharma-continuum/fast-syntax-highlighting
#
# zsh-syntax-highlighting: provides fish-like syntax highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting
zinit wait'0a' lucid for \
  zsh-users/zsh-syntax-highlighting

# zsh-history-substring-search: provides fish-like history search feature
# https://github.com/zsh-users/zsh-history-substring-search

# NOTE: https://github.com/zsh-users/zsh-history-substring-search/issues/110
function _history_substring_search_config() {
  # Move up/down with arrows
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}

# NOTE: must be load after zsh-syntax-highlighting, hence the 0b wait slot
zinit wait'0b' lucid for \
  atload"
    HISTORY_SUBSTRING_SEARCH_FUZZY=true
    _history_substring_search_config" \
  zsh-users/zsh-history-substring-search

# XXX: zsh-completions
# zinit wait lucid for \
#   blockf atpull'zinit creinstall -q .' \
#     zsh-users/zsh-completions

# XXX: maybe even install sdk here
# https://zdharma-continuum.github.io/zinit/wiki/GALLERY/#programs
#
# zsh-sdkman: adds aliases and completion scripts for sdk
# https://github.com/matthieusb/zsh-sdkman
zinit wait'1' lucid for \
  if'[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]' \
  atpull'sdk selfupdate' \
  atinit"source ${SDKMAN_DIR}/bin/sdkman-init.sh" \
  matthieusb/zsh-sdkman

########## TODO: move the below somewhere else

# fzf
#  - https://github.com/junegunn/fzf#layout
#  - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf#settings
export FZF_BASE="${FZF_BASE:-$XDG_DATA_HOME/fzf}"
export FZF_DEFAULT_COMMAND="fd --type file --follow --hidden"
export FZF_CTRL_T_COMMAND="fd --type file --follow --hidden"
export FZF_DEFAULT_OPTS="--height 25% --layout=reverse --border"

# skim
#  - https://github.com/lotabout/skim
#  - NOTE: SKIM_DEFAULT_OPTIONS reuse FZF_DEFAULT_OPTS with `--color` set below
export SKIM_BASE="${SKIM_BASE:-$XDG_DATA_HOME/skim}"
export SKIM_DEFAULT_COMMAND="${FZF_DEFAULT_COMMAND}"
export SKIM_CTRL_T_COMMAND="${FZF_CTRL_T_COMMAND}"

# switch to given fuzzy finder (fzf | sk, default: fzf)
function fzf_prog() {
  export FZF="${1:-fzf}"
}
export fzf_prog

# set default fuzzy finder
fzf_prog fzf

# TODO: organize (split up and move to apps, leave here just generic ones)
########################################################
##### ALIASES
########################################################

# ZSH
alias zenv='nvim ${ZDOTDIR}/.zshenv'
alias zconf='nvim ${ZDOTDIR}/.zshrc'

# XDG
alias o='xdg-open'

# Copy/Paste
alias y='wl-copy'
alias c='wl-copy'
alias p='wl-paste'
alias rmclip='wl-copy -c'

# Find why is a given package installed via apt
#  - Based on a comment under this answer: https://askubuntu.com/a/5637
alias why='apt-cache rdepends --no-{suggests,conflicts,breaks,replaces,enhances} --installed --recurse'

# List GPUs or launch a command on a GPU
if [[ "${commands[switcherooctl]}" ]]; then
  alias lsgpu='switcherooctl list'
  alias gpuexec='switcherooctl launch -g 1'
fi

# Bitwarden
#  - https://bitwarden.com/help/cli/#log-in
#  - NOTE: currently using two-step login via an authenticator app
#  - TODO: switch to FIDO2 two-step login method once supported by the app
alias bwl='bw login --method 0 ${EMAIL}'

# EDITOR
alias e='nvim'
alias ep='nvim -p'
alias vim='vi -u ${VIMRC}' # vi is actually vim, but use custom vimrc
alias vimdiff='nvim -d'

# Search file with a fuzzy finder (fzf|sk) and open it with the editor
alias ef='e $("${FZF:-fzf}" --preview="bat --style=numbers --color=always {}")'

# Search installed packages with a fuzzy finder (fzf|sk)
function fpkg() {
  dpkg -l | rg -N '^ii\s(.*)$' -or '$1' | "${FZF:-fzf}"
}

# Remove colors from output (https://stackoverflow.com/a/18000433)
alias decolorize='sed -r "s/\\x1B\\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g"'

# PDF

# Concatenate pdf files passed as arguments and output final pdf to stdout
#  - Example: `pdfconcat in-*.pdf > out.pdf`
alias pdfconcat="gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dAutoRotatePages=/None -dPDFSETTINGS=/prepress -sOutputFile=%stdout"

# Extract given range of pages from a pdf file and output to stdout
#  - Example: `pdfextract 2,6-9,11,42- in.pdf > out.pdf`
#  - TODO: disable or otherwise fix pdfmark error (seem to have no effect)
# shellcheck disable=SC2142
alias pdfextract='pdfext() { gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sPageList="$1" -sOutputFile=%stdout "$2" ; }; pdfext'

# Git
alias gah="git stash && git pull --rebase && git stash pop"
[[ "${commands[gitui]}" ]] && alias gui="gitui --watcher"
[[ "${commands[lazygit]}" ]] && alias lg="lazygit"

# make
alias m="make"

# just
[[ "${commands[just]}" ]] && alias j="just"

# grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# history
alias hg='history | egrep'

# Ansible
# NOTE: must use local variable, otherwise shfmt breaks it into "<lhs> - <rhs>"
_zshrc_cmd="ansible-lint"
if [[ "${commands[$_zshrc_cmd]}" ]]; then
  alias alint="ansible-lint"
fi

# eza (https://eza.rocks)
[[ "${commands[eza]}" ]] && alias l="eza -lahg@ --git"

# bat (https://github.com/sharkdp/bat)
if [[ "${commands[bat]}" ]]; then
  alias b="bat"
  alias bp="bat --plain"
fi

# bitcli (https://github.com/matyama/bitcli)
if [[ "${commands[bitcli]}" ]]; then
  alias short="bitcli shorten"
  alias shorto="bitcli --offline"
fi

# bluetui (https://github.com/pythops/bluetui)
[[ "${commands[bluetui]}" ]] && alias bt="bluetui"

# chafa (https://github.com/hpjansson/chafa)
[[ "${commands[chafa]}" ]] && alias imshow="chafa -c 256"

# TODO: move to as atinit on the docker plugin
# Docker
if [[ "${commands[docker]}" ]]; then
  alias dvpd='docker volume rm $(docker volume ls -qf dangling=true)'
fi

# parallel-ssh (https://github.com/ParallelSSH/parallel-ssh)
_zshrc_cmd="parallel-ssh"
if [[ "${commands[$_zshrc_cmd]}" ]]; then
  alias pssh="parallel-ssh"
  alias pscp="parallel-scp"
  alias prsync="parallel-rsync"
  alias pnuke="parallel-nuke"
  alias pslurp="parallel-slurp"
fi

# wireguard (https://wiki.archlinux.org/title/WireGuard)
_zshrc_cmd="wg-quick"
if [[ "${commands[$_zshrc_cmd]}" ]]; then
  alias wgup="sudo wg-quick up"
  alias wgdn="sudo wg-quick down"
fi

# hyperfine (https://github.com/sharkdp/hyperfine)
if [[ "${commands[hyperfine]}" ]]; then
  alias bench="hyperfine -S zsh"
fi

# Newsboat RSS/Atom feed reader (https://newsboat.org)
if [[ "${commands[newsboat]}" ]]; then
  alias news="newsboat -q"
  alias podcasts="podboat -a"
fi

# Python
alias py="python3"
alias wp="which python"
alias jl="jupyter lab --ContentsManager.allow_hidden=True"

# Haskell
if [[ "${commands[ghc]}" ]]; then
  # Quick check if Haskell source file(s) compile
  alias hsc="ghc -no-keep-o-files -no-keep-hi-files"
  alias hscdir="ghc -no-keep-o-files -no-keep-hi-files *.hs"
fi

# YouTube download (https://github.com/yt-dlp/yt-dlp)
_zshrc_cmd="yt-dlp"
if [[ "${commands[$_zshrc_cmd]}" ]]; then
  alias yt2mp3="yt-dlp --extract-audio --audio-format mp3 --audio-quality 0"
fi

########################################################
##### USER CONFIGURATION
########################################################

# History management
#  - https://stackoverflow.com/a/38549502
#  - https://stackoverflow.com/a/19454838
#  - https://unix.stackexchange.com/a/273863
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTFILESIZE=50000
export SAVEHIST="${HISTFILESIZE}"
export HISTIGNORE="clear:bg:fg:cd:cd -:cd ..:cd ~:exit:date:w:* --help:h:ls:la:l:ll:eza"
export HISTORY_IGNORE="(clear|bg|fg|cd|cd -|cd ..|cd ~|exit|date|w|* --help|h|ls|la|l|ll|eza)"

# NOTE: shfmt is unable to parse zshaddhistory, which applies to the whole file
# TODO: find some more elegant way setup history
if [[ -f "${ZSH_FUNCTIONS}/history.zsh" ]]; then
  source "${ZSH_FUNCTIONS}/history.zsh"
fi

setopt hist_ignore_all_dups
setopt hist_ignore_space

########################################################
##### KEYBINDINGS
########################################################

# Use Ctrl-Z to switch back to Vim
#  - https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
# shellcheck disable=SC2309,SC2034
fancy-ctrl-z() {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# export MANPATH="/usr/local/man:$MANPATH"

# Colored man output
# See: https://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline

# Make less better
# X = leave content on-screen
# F = quit automatically if less than one screenfull
# R = raw terminal characters (fixes git diff)
#     see http://jugglingbits.wordpress.com/2010/03/24/a-better-less-playing-nice-with-git/
export LESS="-F -X -R"

# Set configuration files for less
#  - TODO: XDG should be fully supported when version 600 lands
export LESSKEY=${XDG_CONFIG_HOME}/less/lesskey
export LESSHISTFILE=${XDG_STATE_HOME}/less/lesshst

# Configure lesspipe.sh (https://github.com/wofr06/lesspipe)
[[ "${commands[lesspipe.sh]}" ]] && export LESSOPEN="|lesspipe.sh %s"
[[ "${commands[bat]}" ]] && export LESSCOLORIZER=bat

# Tinted Shell (https://github.com/tinted-theming/tinted-shell)
export TINTED_SHELL_ENABLE_VARS=1
export TINTED_SHELL_ENABLE_BASE16_VARS=1

# TODO: zinit/tinty
# Tinted shell (https://github.com/tinted-theming/tinted-shell)
[[ -s "${BASE16_SHELL_PATH}/base16-shell.plugin.zsh" ]] &&
  source "${BASE16_SHELL_PATH}/base16-shell.plugin.zsh"

# Tinted tmux (https://github.com/tinted-theming/tinted-tmux)
#export TINTED_TMUX_OPTION_ACTIVE=1
export TINTED_TMUX_OPTION_STATUSBAR=1

# Tinted fzf (https://github.com/tinted-theming/tinted-fzf)
BASE16_FZF_HOME="${BASE16_FZF_HOME:-${XDG_CONFIG_HOME}/tinted-theming/tinted-fzf}"
# shellcheck disable=SC1090
[[ ! -d "$BASE16_FZF_HOME" ]] ||
  [[ "$FZF_DEFAULT_OPTS" == *"--color"* ]] ||
  source "${BASE16_FZF_HOME}/sh/base16-${BASE16_THEME}.sh"

# skim: reuse FZF_DEFAULT_OPTS for `--color` options set by base16-fzf above
export SKIM_DEFAULT_OPTIONS="--multi $FZF_DEFAULT_OPTS"

# Bat customization (https://github.com/sharkdp/bat#customization)
#  - Do not add `BAT_THEME` to `.zshenv`/`.zprofile` or bat config file as it
#    might be altered by the Base16 hook above.
#  - Use `base16-256` for bat which, according to the docs, "is designed for
#    `base16-shell`"
#  - Use fully stylized bat by default
export BAT_THEME=base16-256
export BAT_STYLE=full

# Make CapsLock an extra Esc
# setxkbmap -option caps:escape

# Nvidia CUDA - CUPTI (https://www.tensorflow.org/install/gpu#linux_setup)
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/include

########################################################
##### COMPLETIONS
########################################################

# Initialize completions
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
#  - https://unix.stackexchange.com/a/391670
#  - https://wiki.archlinux.org/title/XDG_Base_Directory

# FIXME: (de)duplicate with $ZSH_CACHE_DIR
autoload -U +X compinit &&
  compinit -i -d "${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"
autoload -U +X bashcompinit && bashcompinit

# zinit: replay cached completions (recommended)
zinit cdreplay -q

zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/zcompcache"

# virsh helper functions
if [[ "${commands[virsh]}" ]]; then
  virsh-rm-pool() {
    virsh pool-autostart "${1}" --disable
    virsh pool-destroy "${1}"
    virsh pool-undefine "${1}"
  }
fi

# TODO: figure out a better solution than _zshrc_cmd
unset _zshrc_cmd
