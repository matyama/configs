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

