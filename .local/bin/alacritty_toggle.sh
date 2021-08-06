#!/bin/bash

# Script taken from here:
#  - https://github.com/alacritty/alacritty/issues/862#issuecomment-633320108

PID=$(pgrep alacritty)
if [ -z "$PID" ]; then
	alacritty &
	exit 0
fi

WINDOWID=$(xdotool search --pid $PID)
IS_VISIBLE=true
[ -z $(xdotool search --onlyvisible --pid $PID) ] && IS_VISIBLE=false

[ $(xdotool getwindowfocus) != "$WINDOWID" ] && {
	if [ $IS_VISIBLE == true ]; then
		xdotool windowactivate $WINDOWID
	else
		xdotool windowmap $WINDOWID
	fi

  exit 0
}

xdotool windowunmap $WINDOWID
