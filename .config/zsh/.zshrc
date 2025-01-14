# Path to your oh-my-zsh installation.
#  - https://github.com/ohmyzsh/ohmyzsh/issues/9543
export ZSH="${XDG_DATA_HOME}/oh-my-zsh"

# Default user
DEFAULT_USER=matyama

# Set name of the theme to load
ZSH_THEME=powerlevel10k/powerlevel10k

# Set p10k configuration file
#  - Note: *Rainbow* prompt style does now display correctly in vscode terminal,
#    therefore `p10k-vscode.zsh` is used if current shell runs there.
#  - See: https://stackoverflow.com/a/59231654/15112035
if [[ -n "${TERM_PROGRAM}"  ]] && [[ "${TERM_PROGRAM}" == "vscode" ]]; then
  POWERLEVEL9K_CONFIG_FILE="${XDG_CONFIG_HOME}/zsh/p10k-vscode.zsh"
else
  POWERLEVEL9K_CONFIG_FILE="${XDG_CONFIG_HOME}/zsh/p10k.zsh"
fi

# Disable p10k configuration wizard
#  - If it's really needed, set this ad-hoc to false
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Plugins
#  - https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins
#  - https://github.com/wfxr/forgit
#  - https://github.com/tinted-theming/tinted-shell
#  - https://github.com/zsh-users/zsh-syntax-highlighting
#  - https://github.com/zsh-users/zsh-history-substring-search
#  - https://github.com/zsh-users/zsh-autosuggestions
#  - https://github.com/matthieusb/zsh-sdkman
#
# Plugin directories
#  - Standard plugins can be found in $ZSH/plugins/
#  - Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  ansible                       # adds some useful aliases for ansible
  aws                           # completion support for awscli & few utilities
  copybuffer                    # copy shell buffer to clipboard with ctrl-o
  direnv                        # creates the direnv hook
  docker                        # adds auto-completion and aliases for docker
  docker-compose                # adds completion & some aliases
  fzf                           # enables fuzzy auto-completion & key bindings
  git                           # adds many aliases & few useful functions
  forgit                        # interactive git+fzf & overrides git aliases
  gh                            # adds completion for the GitHub CLI
  helm                          # adds completion for helm
  history                       # adds a couple of convenient aliases
  kubectl                       # adds completion & some aliases
  minikube                      # adds completion for minikube
  nmap                          # adds some useful aliases for Nmap
  pip                           # adds completion & some aliases
  pipenv                        # adds completion, aliases & shell activation
  poetry                        # adds completion & keeps it up to date
  rust                          # adds completion for rustc, rustup and cargo
  sdk                           # adds auto-completion for sdk
  stack                         # adds auto-completion for stack
  terraform                     # adds completion, aliases & a prompt function
  tinted-shell                  # provides support for Tinted Shell themes
  tmux                          # adds some useful aliases for tmux
  zsh-sdkman                    # adds aliases and completion scripts for sdk
  zsh-syntax-highlighting       # provides fish-like syntax highlighting
  zsh-history-substring-search  # provides fish-like history search feature
  zsh-autosuggestions           # provides fish-like autosuggestions
  zsh-interactive-cd            # provides fish-like interactive cd completion
  zsh-virsh                     # provides custom virsh extensions
)

# fzf
#  - https://github.com/junegunn/fzf#layout
#  - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf#settings
export FZF_BASE="$XDG_DATA_HOME/fzf"
export FZF_DEFAULT_COMMAND="fd --type file --follow --hidden"
export FZF_CTRL_T_COMMAND="fd --type file --follow --hidden"
export FZF_DEFAULT_OPTS="--height 25% --layout=reverse --border"

# skim
#  - https://github.com/lotabout/skim
#  - NOTE: SKIM_DEFAULT_OPTIONS reuse FZF_DEFAULT_OPTS with `--color` set below
export SKIM_BASE="$XDG_DATA_HOME/skim"
export SKIM_DEFAULT_COMMAND="${FZF_DEFAULT_COMMAND}"
export SKIM_CTRL_T_COMMAND="${FZF_CTRL_T_COMMAND}"

# switch to given fuzzy finder (fzf | sk, default: fzf)
function fzf_prog() {
  export FZF="${1:-fzf}"
}
export fzf_prog

# set default fuzzy finder
fzf_prog fzf

# forgit
#  - https://github.com/wfxr/forgit#git
path+="${FORGIT_INSTALL_DIR}/bin"

export FORGIT_COPY_CMD='wl-copy'

source $ZSH/oh-my-zsh.sh

# User configuration

# Default browser
if (( $+commands[google-chrome] )); then
  export BROWSER="google-chrome"
else
  export BROWSER="firefox"
fi

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

zshaddhistory() {
  emulate -L zsh
  ## uncomment if HISTORY_IGNORE should use EXTENDED_GLOB syntax
  # setopt extendedglob
  [[ $1 != ${~HISTORY_IGNORE} ]]
}

setopt hist_ignore_all_dups
setopt hist_ignore_space

# McFly history search
#  - https://github.com/cantino/mcfly
#  - NOTE: overrides Ctrl+R from the fzf plugin above
if (( $+commands[mcfly] )); then
  export MCFLY_KEY_SCHEME=vim
  export MCFLY_FUZZY=2
  export MCFLY_RESULTS=20
  export MCFLY_HISTORY_LIMIT=10000
  eval "$(mcfly init zsh)"
fi

# History search
#  - https://github.com/zsh-users/zsh-history-substring-search#configuration
HISTORY_SUBSTRING_SEARCH_FUZZY=true

# Keybindings

# Accept autosuggestion with <Ctrl><Space>
#  - https://github.com/zsh-users/zsh-autosuggestions#key-bindings
bindkey '^ ' autosuggest-accept

# Use Ctrl-Z to switch back to Vim
#  - https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
fancy-ctrl-z () {
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
(( $+commands[lesspipe.sh] )) && export LESSOPEN="|lesspipe.sh %s"
(( $+commands[bat] )) && export LESSCOLORIZER=bat

# To customize prompt, run `p10k configure` or edit `POWERLEVEL9K_CONFIG_FILE`
[[ ! -f "${POWERLEVEL9K_CONFIG_FILE}" ]] || \
  source "${POWERLEVEL9K_CONFIG_FILE}"

# Tinted Shell (https://github.com/tinted-theming/tinted-shell)
export TINTED_SHELL_ENABLE_VARS=1
export TINTED_SHELL_ENABLE_BASE16_VARS=1

# Tinted tmux (https://github.com/tinted-theming/tinted-tmux)
#export TINTED_TMUX_OPTION_ACTIVE=1
export TINTED_TMUX_OPTION_STATUSBAR=1

# Tinted fzf (https://github.com/tinted-theming/tinted-fzf)
BASE16_FZF_HOME="${BASE16_FZF_HOME:-${XDG_CONFIG_HOME}/tinted-theming/tinted-fzf}"
[[ ! -d "$BASE16_FZF_HOME" ]] || \
  [[ "$FZF_DEFAULT_OPTS" == *"--color"* ]] || \
  source "$BASE16_FZF_HOME/sh/base16-$BASE16_THEME.sh"

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

# Initialize completions
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
#  - https://unix.stackexchange.com/a/391670
#  - https://wiki.archlinux.org/title/XDG_Base_Directory

autoload -U +X compinit && \
  compinit -i -d "${XDG_CACHE_HOME}/zsh/zcompdump-${ZSH_VERSION}"
autoload -U +X bashcompinit && bashcompinit

zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/zcompcache"

# Enable option stacking in docker auto-completion
#  - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker#settings
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# coursier autocompletion
#  - https://get-coursier.io/docs/cli-installation#zsh-completions
if (( $+commands[cs] )); then
  mkdir -p "${ZSH}/completion"
  echo '#compdef _cs cs

  function _cs {
    eval "$(cs complete zsh-v1 $CURRENT $words[@])"
  }' > "${ZSH}/completion/_cs"
fi

# pipx autocompletion
(( $+commands[pipx] )) && eval "$(register-python-argcomplete pipx)"

# aws-vault autocompletion
(( $+commands[aws-vault] )) && eval "$(aws-vault --completion-script-zsh)"

# travis autocompletion
[[ -s "${TRAVIS_CONFIG_PATH}/travis.sh" ]] && \
  source "${TRAVIS_CONFIG_PATH}/travis.sh"

# pandoc autocompletion
(( $+commands[pandoc] )) && eval "$(pandoc --bash-completion)"

# zoxide
if (( $+commands[zoxide] )); then
  eval "$(zoxide init --cmd cd zsh)"
  alias cdf=cdi
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && \
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
