# configs
This repository contains various configuration files and scripts.

## Installation
There is an installation make target that copies config files to dedicated locations.
```bash
make install
```
applies all configurations while e.g.
```bash
make install-nvim
```
sets just `nvim` config (see `Makefile` for all the options).

## Manual configurations

### Making CapsLock an extra Esc
1. Make sure [GNOME Tweaks](https://wiki.gnome.org/Apps/Tweaks) is installed
1. Follow [these instructions](https://dev.to/yuyabu/how-to-use-caps-lock-key-as-esc-on-ubuntu-18-1g7l)

