# shellcheck shell=bash

export DEFAULT_USER=matyama

# Skip the not really helping Ubuntu global compinit (https://bit.ly/41dLFV8)
export skip_global_compinit=1

########################################################
##### PROFILING START
########################################################

ZSHRC_PROFILE_STARTUP=false

if [[ "${ZSHRC_PROFILE_STARTUP}" == true ]]; then
  zmodload zsh/zprof
  PS4=$'%D{%M%S%.} %N:%i> '
  exec 3>&2 2>"${XDG_CACHE_HOME:-$HOME/.cache}/zsh/startlog.$$"
  setopt xtrace prompt_subst
fi

########################################################
##### INSTANT PROMPT
########################################################

PS1="%F{#d65d0e}[%n@%m]%f %F{#458588}%5~%f %F{#3c3836}|%f "

########################################################
##### UPDATE FPATH
########################################################

# TODO: add completions conditionally only if binary is installed
# Export directory for user-defined completions
export ZSH="${XDG_DATA_HOME:-$HOME/.local}/zsh"
export ZSH_COMPLETIONS="${ZSH}/completions"
export ZSH_FUNCTIONS="${ZSH}/functions"

# Modify fpath
typeset -gaU fpath=("${ZSH_COMPLETIONS}" "${ZSH_FUNCTIONS}" "${fpath[@]}")

# Auto-load custom functions
autoload -Uz ${ZSH_FUNCTIONS}/*

########################################################
##### SETUP PLUGIN MANAGER (ZINIT)
########################################################

export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$XDG_CACHE_HOME/zinit}"

# Set up zinit variables
#  - https://github.com/zdharma-continuum/zinit#customizing-paths
#  - https://github.com/zdharma-continuum/zinit#using-zpfx-variable
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
typeset -gAH ZINIT

# Where zinit should create all working directories
ZINIT[HOME_DIR]="${XDG_DATA_HOME:-$HOME/.local/share}/zinit"

# Standard "prefix" for installing compiled software
ZPFX="${ZINIT[HOME_DIR]}/polaris"

# Where zinit code resides
ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/zinit.git"

# Setup working directory for plugins, completions, and snippets
ZINIT[PLUGINS_DIR]="${ZINIT[HOME_DIR]}/plugins"
ZINIT[COMPLETIONS_DIR]="${ZINIT[HOME_DIR]}/completions"
ZINIT[SNIPPETS_DIR]="${ZINIT[HOME_DIR]}/snippets"

# Path to .zcompdump file, with the file included
ZINIT[ZCOMPDUMP_PATH]="${ZSH_CACHE_DIR}/zcompdump-${ZSH_VERSION}"

# If set to 1, then zinit will skip checking if a turbo-loaded object exists on
# the disk. This option can give a performance gain.
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1

# Download zinit, if it's not there yet
if [ ! -d "${ZINIT[BIN_DIR]}" ]; then
  mkdir -p \
    "${ZINIT[HOME_DIR]}" \
    "${ZSH_CACHE_DIR}"/completions \
    "${ZSH_COMPLETIONS}" \
    "${ZSH_FUNCTIONS}"

  git clone https://github.com/zdharma-continuum/zinit "${ZINIT[BIN_DIR]}"

  zcompile "${ZINIT[BIN_DIR]}"/zinit.zsh
fi

# Source/load zinit
source "${ZINIT[BIN_DIR]}/zinit.zsh"

# Build and load zsh module for automatically compiling sourced files
# https://github.com/zdharma-continuum/zinit-module#with-zinit
if [[ ! -d "${ZINIT[HOME_DIR]}/module" ]]; then
  # first build to initialize the module repository
  zinit module build || true
  # run patched module build
  # https://github.com/zdharma-continuum/zinit-module/issues/4
  [[ "$(command -v zinit-module-build)" ]] && zinit-module-build
fi

module_path+=("${ZINIT[HOME_DIR]}/module/Src")
zmodload zdharma_continuum/zinit

# Add binaries managed by zinit to the PATH
path+=("${ZPFX}/bin")

########################################################
##### ZINIT EXTENSIONS (ANNEXES)
########################################################

# Annexes
#  - https://github.com/zdharma-continuum/zinit-annex-binary-symlink
zinit light-mode lucid for \
  zdharma-continuum/zinit-annex-binary-symlink

########################################################
##### PROMPT / THEME
########################################################

# Reevaluate the prompt string each time zsh wants to display a prompt
setopt prompt_subst

# Prompt: Starship
zinit wait'!' lucid \
  has'starship' \
  from'gh-r' lbin'!' src'starship.zsh' reset \
  atclone'./starship init zsh > starship.zsh' \
  atpull'%atclone' \
  atinit'!
  export STARSHIP_CONFIG=${XDG_CONFIG_HOME}/starship/starship.toml

  # Add a newline between commands
  # https://github.com/starship/starship/issues/560
  precmd() { precmd() { echo "" } }
  alias clear="precmd() { precmd() { echo } } && clear"' \
  for starship/starship

########################################################
##### ZINIT PLUGINS, SNIPPETS, AND COMPLETIONS
########################################################

# XXX: move some of OMZL::git.zsh to git aliases instead
# TODO: maybe set some OMZL::directories.zsh options / aliases
# TODO: deprecate clipboard or update c/p aliases
#
# Priority plugins/libs
#  1. Load history early to prevent empty history stack for other plugins
#  2. Load OMZ library snippets, some of which are pre-requisites for plugins
#  3. Load tmux first to prevent jumps when it is loaded after zshrc
#     (adds some useful aliases for tmux)
#
# History management
#  - https://stackoverflow.com/a/38549502
#  - https://stackoverflow.com/a/19454838
#  - https://unix.stackexchange.com/a/273863
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
#
# NOTE: OMZL::completions does
#  - `zstyle ':completion:*' cache-path $ZSH_CACHE_DIR``
#  - `autoload -U +X bashcompinit && bashcompinit`
zinit lucid for \
  is-snippet atload'
    export HISTCONTROL=ignoreboth
    export HISTSIZE=5000
    export HISTFILE="${XDG_STATE_HOME}/zsh/history"
    export HISTFILESIZE=50000
    export SAVEHIST="${HISTFILESIZE}"
    export HISTIGNORE="clear:bg:fg:cd:cd -:cd ..:cd ~:exit:date:w:* --help:h:ls:la:l:ll:eza"
    export HISTORY_IGNORE="(clear|bg|fg|cd|cd -|cd ..|cd ~|exit|date|w|* --help|h|ls|la|l|ll|eza)"

    zshaddhistory() {
      emulate -L zsh
      ## uncomment if HISTORY_IGNORE should use EXTENDED_GLOB syntax
      # setopt extendedglob
      [[ $1 != ${~HISTORY_IGNORE} ]]
    }

    # Set options in addition to OMZL::history
    setopt hist_ignore_all_dups

    # Set aliases (custom and from OMZP::history)
    alias h="history"
    alias hl="history | less"
    alias hs="history | grep"
    alias hg="history | egrep"
    alias hsi="history | grep -i"' \
  OMZL::history.zsh \
  is-snippet OMZL::{'clipboard','completion','git','grep','key-bindings'}.zsh \
  has'tmux' atinit'
    export ZSH_TMUX_FIXTERM=false
    export ZSH_TMUX_AUTOSTART=false
    export ZSH_TMUX_AUTOCONNECT=false' \
  OMZP::tmux

# FIXME: aws completions (`aws_completer` not installed)
# TODO: deprecate OMZP::minikube (resp., generate as completions)
# XXX: OMZ::git -> gitfast (zinit svn snippet for OMZP::gitfast)
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
#  - kubectl                       adds completion & some aliases
#  - minikube                      adds completion for minikube
#  - nmap                          adds some useful aliases for Nmap
#  - nvm                           adds completion for & lazily sources nvm
#  - pip                           adds completion & some aliases
#  - rust                          adds completion for rustc, rustup and cargo
#  - terraform                     adds completion, aliases & a prompt function
#  - zsh-interactive-cd            provides fish-like interactive cd completion
#
# Resuorces:
#  - https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
#  - https://github.com/zdharma-continuum/zinit#migration
#  - https://zdharma-continuum.github.io/zinit/wiki/Example-Oh-My-Zsh-setup
zinit wait'0a' lucid for \
  has'ansible' OMZP::ansible \
  has'aws' atinit'SHOW_AWS_PROMPT=false' OMZP::aws \
  OMZP::copybuffer \
  has'direnv' OMZP::direnv \
  has'docker' OMZP::docker \
  has'docker' as'completion' \
  atinit"
    # Enable option stacking in docker auto-completion
    #  - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker#settings
    zstyle ':completion:*:*:docker:*' option-stacking yes
    zstyle ':completion:*:*:docker-*:*' option-stacking yes
    # Alias for pruning all dangling volumes
    alias dvpd='docker volume rm \$(docker volume ls -qf dangling=true)'" \
  OMZP::docker/completions/_docker \
  has'docker-compose' OMZP::docker-compose \
  has'docker-compose' as'completion' OMZP::docker-compose/_docker-compose \
  has'fzf' OMZP::fzf \
  has'gh' OMZP::gh \
  OMZP::git \
  has'helm' OMZP::helm \
  has'kubectl' OMZP::kubectl \
  has'minikube' OMZP::minikube \
  has'nmap' OMZP::nmap \
  if'[[ -d "${NVM_DIR}" ]]' \
  atinit"
    # Enable lazy startup & rc file autoload
    #  - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/nvm
    zstyle ':omz:plugins:nvm' lazy yes
    zstyle ':omz:plugins:nvm' lazy-cmd \
      eslint prettier typescript typescript-language-server
    zstyle ':omz:plugins:nvm' autoload yes" \
  OMZP::nvm \
  has'pip' OMZP::pip \
  has'pip' as'completion' OMZP::pip/_pip \
  has'rustc' as'completion' OMZP::rust/_rustc \
  has'rustup' has'cargo' OMZP::rust \
  has'terraform' OMZP::terraform \
  has'terraform' as'completion' OMZP::terraform/_terraform \
  OMZP::zsh-interactive-cd

# Resources
#  - aws-vault: provides autocompletion
#  - forgit: interactive git+fzf & overrides git aliases
#    https://github.com/wfxr/forgit
#  - skim: loads skim key-bindings
#    https://github.com/skim-rs/skim
#  - stack: generates and sources completion for stack (assumes bashcompinit)
#  - zoxide: smarter cd command
#    https://github.com/ajeetdsouza/zoxide
#
# XXX: forgit: alternatively use `atload"!PATH+=:${FORGIT_INSTALL_DIR}/bin"`
# TODO: aws-vault master -> version tag
#  - issue: for some reason, `aws-vault --version` writes to STDERR
zinit wait'0a' lucid for \
  has'aws-vault' as'completion' id-as'aws-vault' \
  mv'aws-vault -> _aws-vault' \
  https://raw.githubusercontent.com/99designs/aws-vault/master/contrib/completions/zsh/aws-vault.zsh \
  has'fzf' atclone="ln -sft ${XDG_BIN_HOME} \$PWD/bin/*" atpull"%atclone" \
  atinit"export FORGIT_COPY_CMD='wl-copy'" \
  wfxr/forgit \
  has'sk' as'null' id-as'skim' \
  atinit'source "${SKIM_BASE}/shell/key-bindings.zsh"' \
  zdharma-continuum/null \
  has'zoxide' as'program' id-as'zoxide' src'zoxide.zsh' reset run-atpull \
  atclone'zoxide init --cmd cd zsh > zoxide.zsh' \
  atpull'%atclone' \
  atinit'alias cdf=cdi' \
  zdharma-continuum/null

# mcfly: intelligent history search
# https://github.com/cantino/mcfly
#
# NOTE: overrides Ctrl+R from the OMZP::fzf plugin above, so load it after
zinit wait'0a' lucid \
  has'mcfly' as'program' id-as'mcfly' src'mcfly.zsh' reset run-atpull \
  atclone'mcfly init zsh > mcfly.zsh' \
  atpull'%atclone' \
  atinit'
    export MCFLY_KEY_SCHEME=vim
    export MCFLY_FUZZY=2
    export MCFLY_RESULTS=20
    export MCFLY_HISTORY_LIMIT=10000' \
  for zdharma-continuum/null

# Resources
#  - zsh-autosuggestions: provides fish-like autosuggestions
#    https://github.com/zsh-users/zsh-autosuggestions
#  - zsh-completions: provides additional completion definitions
#    https://github.com/zsh-users/zsh-completions
zinit wait'0b' lucid for \
  as'completion' atpull'zinit cclear' blockf \
  zsh-users/zsh-completions \
  atinit"
    # Disable suggestion for large buffers
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
    # Accept autosuggestion with <Ctrl><Space>
    bindkey '^ ' autosuggest-accept
    # Accept and execute current suggestion with Ctrl+x
    bindkey '^x' autosuggest-execute" \
  atload="!_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions

# FIXME: zcompdump only in ZSH_CACHE_DIR (currently appears also in ZDOTDIR)
#
# zsh-syntax-highlighting: provides fish-like syntax highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting
#
# NOTE: COMPINIT_OPTS are for compinit call, -C speeds up loading
#
# NOTE: Make sure that all completions are set up before. This plugin's atinit
# runs compinit, and it should be the only compinit call to get the best perf.
zinit wait'0c' lucid for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit_fast; zicdreplay" \
  zsh-users/zsh-syntax-highlighting

# zsh-history-substring-search: provides fish-like history search feature
# https://github.com/zsh-users/zsh-history-substring-search

# NOTE: https://github.com/zsh-users/zsh-history-substring-search/issues/110
function _history_substring_search_config() {
  # Move up/down with arrows
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}

# NOTE: must be load after zsh-syntax-highlighting
zinit wait'0d' lucid for \
  atload"
    HISTORY_SUBSTRING_SEARCH_FUZZY=true
    _history_substring_search_config" \
  zsh-users/zsh-history-substring-search

########################################################
##### COLORS / THEMING / VISUALS
########################################################

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

# TODO: organize (split up and move to apps, leave here just generic ones)
########################################################
##### CUSTOM ALIASES AND FUNCTIONS
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

# Ansible
# NOTE: must use local variable, otherwise shfmt breaks it into "<lhs> - <rhs>"
_zshrc_cmd="ansible-lint"
if [[ "${commands[$_zshrc_cmd]}" ]]; then
  alias alint="ansible-lint"
fi

# eza (https://eza.rocks)
if [[ "${commands[eza]}" ]]; then
  alias l="eza -lahg@ --git"
  alias ll="eza -lahg@ --git --git-ignore --tree --level=3"
fi

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

# Make CapsLock an extra Esc
# setxkbmap -option caps:escape

########################################################
##### PROFILING END
########################################################

if [[ "$ZSHRC_PROFILE_STARTUP" == true ]]; then
  unsetopt xtrace
  exec 2>&3 3>&-
  zprof >"${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zshprofile-$(date +'%s')"
fi
