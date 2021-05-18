# Path to your oh-my-zsh installation.
export ZSH="/home/matyama/.oh-my-zsh"

# Default user
DEFAULT_USER=matyama

# Set name of the theme to load
ZSH_THEME=powerlevel10k/powerlevel10k

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(aws cargo direnv docker docker-compose fzf git helm history kubectl minikube pip poetry pipenv rust sbt scala sdk stack)

source $ZSH/oh-my-zsh.sh

# User configuration

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

# export MANPATH="/usr/local/man:$MANPATH"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Make CapsLock an extra Esc
# setxkbmap -option caps:escape

# Initialize completions
autoload -U +X compinit && compinit -i
autoload -U +X bashcompinit && bashcompinit

# binenv (https://github.com/devops-works/binenv#linux-bashzsh)
[ ! $(command -v binenv) ] || source <(binenv completion zsh)

# direnv (https://direnv.net)
[ ! $(command -v direnv) ] || eval "$(direnv hook zsh)"

# Nvidia CUDA - CUPTI (https://www.tensorflow.org/install/gpu#linux_setup)
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/extras/CUPTI/lib64
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/include

# pipx
if [ $(command -v pipx) ]; then
  eval "$(register-python-argcomplete pipx)"
fi

# thefuck (shell command corrector)
[ ! $(command -v fuck) ] || eval $(thefuck --alias)

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

