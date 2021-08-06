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
There is an installation make target that links config files to dedicated
locations.

**WARN**: Note that original files will be overwritten!
```bash
make config
```

## Manual configurations

### Alacritty terminal
1. Link script `alacritty_toggle.sh` to an executable path (e.g. with
   `make links`)
1. Manually configure toggle keybinging in 'Settings > Keyboard
   Shortcuts' - for example like this:
   ```
   [custom0]
   binding='F12'
   command='/home/matyama/.local/bin/alacritty_toggle.sh'
   name='Toggle Alacritty terminal'
   ```
1. Add Alacritty to 'Tweaks > Startup Applications'

### Making CapsLock an extra Esc
1. Make sure [GNOME Tweaks](https://wiki.gnome.org/Apps/Tweaks) is installed
1. Follow [these instructions](https://bit.ly/33QDcdB)

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
1. Apply changes to `~/.zshrc`?: No (we're using `.p10k.zsh` from this repo)

Additionally one can download
[Meslo Nerd Fonts](https://bit.ly/3uZhBeH) and configure terminals as
instructed. The font download is part of `make fonts`.

### PAM environment
After linking `.pam_environment` for the first time, one should manually update 
`/etc/pam.d/login` according to
[these instructions](https://askubuntu.com/a/636544).

### Poetry
Finish Poetry setup by manually
[configuring auth tokens](https://bit.ly/3fdpMNR).

### Semantic language support for Neovim
Nvim config automatically installs
[coc.nvim](https://github.com/neoclide/coc.nvim) plugin. In order to setup
language support for various languages, refer to corresponding sub-section.

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

#### Haskell
[Haskell Language Server (HLS)](https://github.com/haskell/haskell-language-server)
is configured in `~/.config/coc/coc-settings.json`.

The installation of HLS is done as part of `ghcup` installation in
```bash
make haskell
```

#### JSON
[Json language extension for coc.nvim](https://github.com/neoclide/coc-json)
```vim
:CocInstall coc-json
```

### Visual Studio Code
Settings are automatically synchronized via [build-in mechanism](https://code.visualstudio.com/docs/editor/settings-sync)
so one can just login to GitHub.

## Saving configurations
Edits to any linked configurations is automatically propagated here 
(via the symlink). Then simply commit and push the changes. 

### Guake Terminal
Unlike other configs, preferences for Guake Terminal are not linked directly.
In order to save updated Guake preferences, run
```bash
make guake.conf
```
This make target will apply preferences from  `guake.conf` from this repo to
local Guake installation. While 
```bash
make save-guake-conf
```
will save current Guake settings to `guake.conf`. Under the hood make runs:
```bash
guake --save-preferences guake.conf
guake --restore-preferences guake.conf
```
Source: [backup options](https://askubuntu.com/a/1164329)

## Ubuntu Setup Notes 

## KVM virtualization
Resources:
 * Simple [installtion tutorial](https://phoenixnap.com/kb/ubuntu-install-kvm)
 * Older but comprehensive [guide](https://bit.ly/339BtPT)
 * [Ubuntu wiki](https://ubuntu.com/server/docs/virtualization-virt-tools)

### System valiadtion for KVM
Whether it's even possible to setup KVM on certain system or not can be checked 
with
```bash
kvm-ok
```
If the CPU supports virtualization one can install all required packages and 
then run following validation check
```bash
virt-host-validate
```
Typically one can see
* *WARN* for *IOMMU* which is handled automatically by the `Makefile` target.
	However, this step (and the `kvm` target in general) needs a reboot.
* Another *QUEMU* warning which according to
	[StackOverflow](https://ubuntu.com/server/docs/virtualization-virt-tools)
	should be fine

## Minikube on KVM
Start Minikube on KVM by running
```bash
minikube start --cpus 2 --memory 2048 --vm-driver kvm2
```
or for larger machnines
```
minikube start --cpus 4 --memory 8192 --vm-driver kvm2
```

Note that the `test-k8s` make target sometimes fails due to timeout after
waiting on minikube. It may also leave some resources when it does not
succeed.

## Troubleshooting

### Nvidia Drivers
Missing `nvidia-smi` after some updates (which was working after
installation):
```
❯ nvidi-smi
zsh: command not found: nvidi-smi
```

Fixed by running following and then rebooting.
```bash
sudo ubuntu-drivers autoinstall
```
Advised [here](https://askubuntu.com/a/1237598) and empirically might
work even without restart.

Other [option](https://askubuntu.com/a/602) which might work (although 
one should be careful with this one) is to run dist upgrade:
```bash
sudo apt dist-upgrade
```

#### Nvidia packages are kept back
The issue with "missing" drivers is that the driver packages are "kept
back" (shown in the snippet below). This is due to an incompatibility
between driver libs and the kernel which `apt` cannot resolve on its own.
```
❯ sudo apt upgrade 
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Calculating upgrade... Done
The following packages have been kept back:
  libnvidia-cfg1-460 libnvidia-compute-460 [...]
  libnvidia-gl-460 libnvidia-gl-460:i386 libnvidia-ifr1-460 [...]
  nvidia-utils-460 xserver-xorg-video-nvidia-460
0 upgraded, 0 newly installed, 0 to remove and 21 not upgraded.
```
As a consequence `nvidia-smi` is unable to communicate to the driver and
fails (see [this post](https://bit.ly/3lI2PYd)).

The solution is as described above (possibly combination of both
approaches). Also, reboot might be necessary for the fix to take effect.

### Minikube fails to start
If minikube continously fails to boot, and as a last resort, one can
clean up the whole minikube by running:
```bash
minikube delete
```
or even more excessive cleanup which also deletes the `~/.minikube` dir
```bash
minikube delete --purge
```

### Vim-plug plugin installation
Some vim-plug plugins require the `init.vim` file (the config file) to be
sourced again for the plugin installation to work.
```vim
:source $VIMRC
:PlugInstall
```
