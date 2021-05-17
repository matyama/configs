# configs

This repository contains various configuration files and scripts.

## Ubuntu Installation

### Partitioning
See e.g. [Ubuntu Wiki](https://help.ubuntu.com/community/DiskSpace).

By default Ubuntu with LVM and encryption creates following partitions:
```
LVM VG vgubuntu, LV root as ext 4
LVM VG vgubuntu, LV swap_1 as swap
partition #1 of /dev/nvme0n1 as ESP
```
The swap partition is by default only ~1G. In order to resize the root logical 
volume and increase swap do the following:
1. Install Ubuntu with LVM and encryption
1. Restart to 'Try Ubuntu', i.e. 'Live CD' so that root is not actively used
1. Run the `increase_swap.sh` script that moves 40G space from root to swap
1. Reboot to installed Ubuntu and continue the setup

## Config Installation
There is an installation make target that links config files to dedicated locations.
**WARN**: Note that original files will be overwritten!
```bash
make config
```

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

### PAM environment
After linking `.pam_environment` for the first time, one should manually update 
`/etc/pam.d/login` according to [these instructions](https://askubuntu.com/a/636544).

### Poetry
Finish Poetry setup by manually [configuring auth tokens](https://bit.ly/3fdpMNR).

### Semantic language support for Neovim
Nvim config automatically installs [coc.nvim](https://github.com/neoclide/coc.nvim) plugin.
In order to setup language support for various languages, refer to corresponding sub-section.

#### Rust Analyzer
```vim
:CocInstall coc-rust-analyzer
```
* https://github.com/fannheyward/coc-rust-analyzer
* https://rust-analyzer.github.io/manual.html#vimneovim

#### Python:
```vim
:CocInstall coc-pyright
```
* https://github.com/fannheyward/coc-pyright#install
* https://github.com/microsoft/pyright/blob/main/docs/configuration.md

## Saving configurations
Edits to any linked configurations is automatically propagated here 
(via the symlink). Then simply commit and push the changes. 

### Guake Terminal
To save updated Guake preferences, run
```bash
make save-guake-conf
```
