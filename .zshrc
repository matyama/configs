# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Default user
DEFAULT_USER=matyama

# Set name of the theme to load
ZSH_THEME=powerlevel10k/powerlevel10k

# Set p10k configuration file
POWERLEVEL9K_CONFIG_FILE="${XDG_CONFIG_HOME}/zsh/p10k.zsh"

# Disable p10k configuration wizard
#  - If it's really needed, set this ad-hoc to false
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(aws direnv docker docker-compose fzf git helm history kubectl minikube pip poetry pipenv rust sbt scala sdk stack)

source $ZSH/oh-my-zsh.sh

# User configuration

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

# Use Ctrl-Z to switch back to Vim
# https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
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

# make less better
# X = leave content on-screen
# F = quit automatically if less than one screenfull
# R = raw terminal characters (fixes git diff)
#     see http://jugglingbits.wordpress.com/2010/03/24/a-better-less-playing-nice-with-git/
export LESS="-F -X -R"

# To customize prompt, run `p10k configure` or edit `POWERLEVEL9K_CONFIG_FILE`
[[ ! -f "${POWERLEVEL9K_CONFIG_FILE}" ]] || \
  source "${POWERLEVEL9K_CONFIG_FILE}"

# Base16 Shell (https://github.com/chriskempson/base16-shell)
BASE16_SHELL_HOME="${BASE16_SHELL_HOME:-${XDG_CONFIG_HOME}/base16-shell}"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL_HOME/profile_helper.sh" ] && \
    eval "$("$BASE16_SHELL_HOME/profile_helper.sh")"

# NOTE: Do not add this to `.zshenv`/`.zprofile` as it is altered by the Base16
# `profile_helper.sh` (hooked above) when the theme is changed and then it 
# might missmatch colors in `~/.base16_theme` if the shell config is reloaded.
BASE16_THEME="${BASE16_THEME:-gruvbox-dark-hard}"

# Base16 fzf (https://github.com/fnune/base16-fzf)
BASE16_FZF_HOME="${BASE16_FZF_HOME:-${XDG_CONFIG_HOME}/base16-fzf}"
[[ ! -d "$BASE16_FZF_HOME" ]] || \
  [[ "$FZF_DEFAULT_OPTS" == *"--color"* ]] || \
  source "$BASE16_FZF_HOME/bash/base16-$BASE16_THEME.config"

# Bat customization (https://github.com/sharkdp/bat#customization)
#  - Do not add `BAT_THEME` to `.zshenv`/`.zprofile` or bat config file as it
#    might be altered by the Base16 hook above.
#  - Use `BASE16_THEME` for bat or default to `base16`
#  - Use fully stylized bat by default

export BAT_THEME="${BASE16_THEME:-base16}"
[[ -f "$BAT_CONFIG_DIR/themes/$BASE16_THEME.tmTheme" ]] || \
  export BAT_THEME=base16

export BAT_STYLE=full

# Make CapsLock an extra Esc
# setxkbmap -option caps:escape

# Initialize completions
autoload -U +X compinit && compinit -i
autoload -U +X bashcompinit && bashcompinit

# direnv (https://direnv.net)
[ ! $(command -v direnv) ] || eval "$(direnv hook zsh)"

# Nvidia CUDA - CUPTI (https://www.tensorflow.org/install/gpu#linux_setup)
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/include

# fzf
# https://github.com/junegunn/fzf#layout
export FZF_DEFAULT_COMMAND="fd --type file --follow --hidden"
export FZF_CTRL_T_COMMAND="fd --type file --follow --hidden"
export FZF_DEFAULT_OPTS="--height 20% --layout=reverse --border"

# pipx
if [ $(command -v pipx) ]; then
  eval "$(register-python-argcomplete pipx)"
fi

# thefuck (shell command corrector)
[ ! $(command -v fuck) ] || eval $(thefuck --alias)

# Haskell toolchain installer ghcup (https://www.haskell.org/ghcup/)
[ -f "/home/matyama/.ghcup/env" ] && source "/home/matyama/.ghcup/env"

# Haskell stack (https://docs.haskellstack.org/en/stable/README/)
[ ! $(command -v stack) ] || eval "$(stack --bash-completion-script stack)"

# minikube autocompletion
[ ! $(command -v minikube) ] || source <(minikube completion zsh)

# kubectl autocompletion
if [ $(command -v kubectl) ]; then
  source <(kubectl completion zsh)
  alias k=kubectl
  complete -F __start_kubectl k
fi

# helm autocompletion
[ ! $(command -v helm) ] || source <(helm completion zsh)

# travis autocompletion
[ ! -s $HOME/.travis/travis.sh ] || source $HOME/.travis/travis.sh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/matyama/.sdkman"
[[ -s "/home/matyama/.sdkman/bin/sdkman-init.sh" ]] && source "/home/matyama/.sdkman/bin/sdkman-init.sh"

