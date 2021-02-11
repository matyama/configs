#!/bin/sh

# TODO: Esc setup below is disabled for now, follow this instead:
# https://dev.to/yuyabu/how-to-use-caps-lock-key-as-esc-on-ubuntu-18-1g7l

# Make CapsLock an extra Esc
# setxkbmap -option caps:escape

# TODO

# gnupg keyring agent
# ensure it's started so SSH will work
# https://www.gnupg.org/faq/whats-new-in-2.1.html#autostart
#dbus-update-activation-environment --systemd DISPLAY
#gpgconf --launch gpg-agent
#export "SSH_AUTH_SOCK=/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"

