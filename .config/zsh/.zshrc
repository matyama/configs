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
#  - https://github.com/zsh-users/zsh-syntax-highlighting
#  - https://github.com/zsh-users/zsh-history-substring-search
#  - https://github.com/zsh-users/zsh-autosuggestions
#
# Plugin directories
#  - Standard plugins can be found in $ZSH/plugins/
#  - Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  aws                           # completion support for awscli & few utilities 
  copybuffer                    # copy shell buffer to clipboard with ctrl-o
  direnv                        # creates the direnv hook
  docker                        # adds auto-completion and aliases for docker
  docker-compose                # adds completion & some aliases
  fd                            # adds completion for fd
  fzf                           # enables fuzzy auto-completion & key bindings
  git                           # adds many aliases & few useful functions
  gh                            # adds completion for the GitHub CLI
  helm                          # adds completion for helm
  history                       # adds a couple of convenient aliases
  kubectl                       # adds completion & some aliases
  minikube                      # adds completion for minikube
  pip                           # adds completion & some aliases
  poetry                        # adds completion & keeps it up to date
  ripgrep                       # adds completion for ripgrep
  rust                          # adds completion for rustc, rustup and cargo
  sbt                           # adds completion & some aliases
  scala                         # adds completion & aliases for scala & scalac
  sdk                           # adds auto-completion for sdk
  stack                         # adds auto-completion for stack
  thefuck                       # press ESC twice to run fuck
  zsh-syntax-highlighting       # provides fish-like syntax highlighting
  zsh-history-substring-search  # provides fish-like history search feature
  zsh-autosuggestions           # provides fish-like autosuggestions
  zsh-interactive-cd            # provides fish-like interactive cd completion
)

# fzf
#  - https://github.com/junegunn/fzf#layout
#  - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf#settings
export FZF_BASE="${commands[fzf]:P:h}"
export FZF_DEFAULT_COMMAND="fd --type file --follow --hidden"
export FZF_CTRL_T_COMMAND="fd --type file --follow --hidden"
export FZF_DEFAULT_OPTS="--height 20% --layout=reverse --border"

source $ZSH/oh-my-zsh.sh

# User configuration

# History management
#  - https://stackoverflow.com/a/38549502
#  - https://unix.stackexchange.com/a/273863
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export SAVEHIST="${HISTSIZE}"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
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

# pipx autocompletion
(( $+commands[pipx] )) && eval "$(register-python-argcomplete pipx)"

# aws-vault autocompletion
(( $+commands[aws-vault] )) && eval "$(aws-vault --completion-script-zsh)"

# travis autocompletion
[[ -s "${TRAVIS_CONFIG_PATH}/travis.sh" ]] && \
  source "${TRAVIS_CONFIG_PATH}/travis.sh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
[[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && \
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"

