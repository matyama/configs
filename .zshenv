# Zsh environment setup script, the sole purpose of which is to
#  1. point `ZDOTDIR` to custom configuration directory in `XDG_CONFIG_HOME`
#  2. source the "main" `.zshenv`
#
# Alternatively, this export could be set globally and  moved to
# `/etc/zsh/zshenv`, see: https://wiki.archlinux.org/title/XDG_Base_Directory
export ZDOTDIR=${XDG_CONFIG_HOME}/zsh
. $ZDOTDIR/.zshenv

