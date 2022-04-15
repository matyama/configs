#!/usr/bin/env bash

# This script is a modification of the official
# [`profile_helper.sh`](https://github.com/chriskempson/base16-shell/blob/master/profile_helper.sh)
#
# Modifications include:
#  - `~/.base16_theme` is placed to `XDG_STATE_HOME/base16-shell/base16_theme`
#    instead if `XDG_STATE_HOME` is defined and fallbacks to `HOME` if not
#  - Analogously `~/.vimrc_background` is placed to the same XDG dir
#  - For backwards compatibility if files in `HOME` already exists, these are
#    used and *not* replaced by / moved to `XDG_STATE_HOME`

BASE16_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}/base16-shell"

if [ -f ~/.base16_theme ]; then
  THEME_LINK=~/.base16_theme
else
  THEME_LINK="${BASE16_STATE_HOME}/base16_theme"
  mkdir -p "${BASE16_STATE_HOME}"
fi

if [ -f ~/.vimrc_background ]; then
  VIMRC_BACKGROUND=~/.vimrc_background
else
  VIMRC_BACKGROUND="${BASE16_STATE_HOME}/vimrc_background"
  mkdir -p "${BASE16_STATE_HOME}"
fi

if [ -s "$BASH" ]; then
    file_name=${BASH_SOURCE[0]}
elif [ -s "$ZSH_NAME" ]; then
    file_name=${(%):-%x}
fi
script_dir=$(cd "$(dirname "$file_name")" && pwd)

. "$script_dir/realpath/realpath.sh"

if [ -f $THEME_LINK ]; then
  script_name=$(basename "$(realpath $THEME_LINK)" .sh)
  echo "export BASE16_THEME=${script_name#*-}"
  echo ". ${THEME_LINK}"
fi

cat <<'FUNC'
_base16()
{
  local script=$1
  local theme=$2
  local base_state_home="${XDG_STATE_HOME:-$HOME/.local/state}/base16-shell"
  if [ -f ~/.base16_theme ]; then
    local theme_link=~/.base16_theme
  else
    local theme_link="${base_state_home}/base16_theme"
  fi
  if [ -f ~/.vimrc_background ]; then
    local vimrc_background=~/.vimrc_background
  else
    local vimrc_background="${base_state_home}/vimrc_background"
  fi
  [ -f $script ] && . $script
  ln -fs $script "${theme_link}"
  export BASE16_THEME=${theme}
  echo -e "if \0041exists('g:colors_name') || g:colors_name != 'base16-$theme'\n  colorscheme base16-$theme\nendif" >| "${vimrc_background}"
  if [ -n ${BASE16_SHELL_HOOKS:+s} ] && [ -d "${BASE16_SHELL_HOOKS}" ]; then
    for hook in $BASE16_SHELL_HOOKS/*; do
      [ -f "$hook" ] && [ -x "$hook" ] && "$hook"
    done
  fi
}
FUNC

for script in "$script_dir"/scripts/base16*.sh; do
  script_name=${script##*/}
  script_name=${script_name%.sh}
  theme=${script_name#*-}
  func_name="base16_${theme}"
  echo "alias $func_name=\"_base16 \\\"$script\\\" $theme\""
done;
