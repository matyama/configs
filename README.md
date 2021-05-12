# configs
This repository contains various configuration files and scripts.

## Installation
There is an installation make target that copies config files to dedicated locations.
```bash
make config
```
applies all configurations while e.g.
```bash
make nvim-cfg
```
sets just `nvim` config (see `Makefile` for all the options).

## Manual configurations

### Making CapsLock an extra Esc
1. Make sure [GNOME Tweaks](https://wiki.gnome.org/Apps/Tweaks) is installed
1. Follow [these instructions](https://dev.to/yuyabu/how-to-use-caps-lock-key-as-esc-on-ubuntu-18-1g7l)

### Powerlevel10k
Typical configuration for `p10k configure`
1. Prompt Style: Lean
1. Character Set: Unicode
1. Prompt Colors: 256 colors
1. Show current time?: 24-hour format
1. Prompt Height: Two lines
1. Prompt Connection: Disconnected
1. Prompt Frame: No frame
1. Prompt Spacing: Sparse
1. Prompt Flow: Concise
1. Enable Tranisent Prompt?: No
1. Instant Prompt Mode: Off
1. Apply changes to `~/.zshrc`?: No if not using `.p10k.zsh` from this repo, otherwise Yes 

Additionally one can download [Meslo Nerd Fonts](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k) and 
configure terminals as instructed. The font download is part of `make fonts`.

## Saving configurations

### Guake Terminal
To save updated Guake preferences, run
```bash
guake --save-preferences guake.conf
```
