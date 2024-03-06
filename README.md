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

### Upgrades
Ubuntu release upgrades can be done using the `do-release-upgrade`
utility from the `update-manager-core` package.

One can verify that it's installed from the output of
```bash
dpkg -s update-manager-core
```

As a prerequisite make sure the system is up to date:
```bash
sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo apt autoremove
```

And finally, run the release upgrade with
```bash
sudo do-release-upgrade
```
or to upgrade from the latest supported release to the development
release, run:
```bash
sudo do-release-upgrade -d
```

Note that new LTS versions become available with release `xx.04.1`, as
explained [here](https://askubuntu.com/a/1403657).

## Config Installation
There is an installation make target that links config files to dedicated
locations.

**WARN**: Note that original files will be overwritten!
```bash
make config
```

## Manual configurations

### Alacritty terminal
First check whether the system runs Wayland - e.g., by looking at
`XDG_SESSION_TYPE`.

#### Wayland
There is a Gnome extension
[alacritty-toggle](https://github.com/axxapy/gnome-alacritty-toggle),
which enables toggling the visibility of the terminal window.

This extension can be installed with `make alacritty-toggle` which
clones the repository and configures the toggle button to F1.

Unfortunately, the extension is picked up only after restarting current
Gnome session so one must logout, log back in and re-run the make
target.

### Making CapsLock an extra Esc
1. Make sure [GNOME Tweaks](https://wiki.gnome.org/Apps/Tweaks) is installed
1. Follow [these instructions](https://bit.ly/33QDcdB)

### Powerlevel10k
This configuration is actually stored as `.config/zsh/p10k.zsh` and
automatically symlinked to `$POWERLEVEL9K_CONFIG_FILE`.

It is important to note that `$POWERLEVEL9K_CONFIG_FILE` is set in
`.zshrc` and uses `$XDG_CONFIG_HOME`. Additionally, `.zshrc` disables
the `p10k configure` configuration wizard.

Therefore, if one deliberately wants to run it, the wizard must be
re-enabled with
```bash
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=false p10k configure
```

Also the XDG specification, respectively `$POWERLEVEL9K_CONFIG_FILE`,
should be respected if `p10k.zsh` ought to be rewritten by the wizard.

Generally, there are two setups which, according to the p10k
documentation, respect terminal's color palette (and hence Base16):
 - *Lean* prompt style with *8 colors*
 - *Rainbow* prompt style which currently does not offer an option to
   select between 8 and 256 colors (empirically 256)

Some settings used in `p10k configure` when `p10k.zsh` was originally
created include: 
 1. Prompt Style: *Rainbow* or *Lean*
 1. Character Set: Unicode
 1. Prompt Separators: Slanted (only relevant to *Rainbow*)
 1. Prompt Heads: Slanted (only relevant to *Rainbow*)
 1. Prompt Tails: Flat (only relevant to *Rainbow*)
 1. Prompt Colors: 256 colors (only relevant to *Lean*)
 1. Show current time?: 24-hour format
 1. Prompt Height: Two lines
 1. Prompt Connection: Disconnected
 1. Prompt Frame: No frame
 1. Prompt Spacing: Sparse
 1. Icons: Many icons
 1. Prompt Flow: Concise
 1. Enable Transient Prompt?: No
 1. Instant Prompt Mode: Off

Additionally one can download
[Meslo Nerd Fonts](https://bit.ly/3uZhBeH) and configure terminals as
instructed. The font download is part of `make fonts`.

### Base16 colors

#### Base16 Shell
[Base16 Shell](https://github.com/tinted-theming/base16-shell) can be
installed with `make base16-shell`. One can then manually switch themes
with `base16_<theme>` which creates/updates a link
`$HOME/.config/tinted-theming/base16_shell_theme`.

Note that the shell hook is already added to and liked the oh-my-zsh
plugin `base16-shell`, so after installation with `make` one just needs
to reload zsh and pick a theme:
```bash
omz reload
base16_gruvbox-dark-hard
```

The default theme is set in `.zshenv` to 
`BASE16_THEME_DEFAULT=gruvbox-dark-hard`.

One can also [test](https://github.com/tinted-theming/base16-shell#troubleshooting)
the themes with included `colortest` tool.

#### Alacritty terminal
Note that when changing the [Base16 theme](https://github.com/tinted-theming/base16)
one has to [manually update](https://github.com/aarowill/base16-alacritty#installation)
`alacritty.yml` with appropriate colors from that color scheme.

#### Bat
[Bat](https://github.com/sharkdp/bat) supports `base16` color theme by
default via `--theme=base16` option or `BAT_THEME` environment variable.

Current setting is `BAT_THEME=base16-256` which, according to the
[documentation](https://github.com/sharkdp/bat#customization):
> is designed for `base16-shell`

Custom themes are supported if appropriate file exists in
`BAT_CONFIG_DIR/themes` When new themes are downloaded and linked, one
must update the cache by running:
```bash
bat cache --build
```
and then check the theme is available via:
```bash
bat --list-themes
```

### Visual Studio Code
Unless the [Base16 extension](https://github.com/golf1052/base16-vscode)
is properly synced, install it and follow the instructions.

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

#### Python
```vim
:CocInstall coc-pyright
```
* https://github.com/fannheyward/coc-pyright#install
* https://github.com/microsoft/pyright/blob/main/docs/configuration.md

Custom configurations can be found in
`$XDG_CONFIG_HOME/coc/coc-settings.json`.

#### Haskell
[Haskell Language Server (HLS)](https://github.com/haskell/haskell-language-server)
is configured in `$XDG_CONFIG_HOME/coc/coc-settings.json`.

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

### Nvidia Settings
The `nvidia-settings` application does not currently support
[XDG specification](https://wiki.archlinux.org/title/XDG_Base_Directory).
The workaround is to set custom config path using the `--config` option.

`.envrc` defines an alias for this so when running `nvidia-settings`
from shell it will automatically use
`$XDG_CONFIG_HOME/nvidia-settings/nvidia-settings-rc` as the config file.

However, the desktop entry (i.e. when running the app from Gnome menu)
must be edited manually. One can do this by executing the following make
target:
```bash
make nvidia-settings-rc-xdg-path
```

## Saving configurations
Edits to any linked configurations is automatically propagated here 
(via the symlink). Then simply commit and push the changes. 

### `coc.nvim` configuration
Although the `.config/coc/coc-settings.json` configuration file is
linked automatically, the server might not load it correctly. This issue
is described in the *Thoubleshooting* section and can be fixed by
rewriting the `:CocConfig` buffer.

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

### LTS release not found
Ubuntu LTS releases become available with release `xx.04.1`, as
explained [here](https://askubuntu.com/a/1403657).

The issue manifests when the check indicates there's new LTS release:
```
❯ sudo do-release-upgrade -cd
Checking for a new Ubuntu release
New release '22.04 LTS' available.
Run 'do-release-upgrade' to upgrade to it.
```
but it fails to do the release upgrade:
```
❯ sudo do-release-upgrade
Checking for a new Ubuntu release
There is no development version of an LTS available.
To upgrade to the latest non-LTS development release
set Prompt=normal in /etc/update-manager/release-upgrades.
```

There are two options to solve this problem:
 1. Wait for the `xx.04.1` release (~ 3 months from the LTS release)
 1. Upgrade to the latest development release, as proposed in the error
    message. This can be done by `sudo do-release-upgrade -d`.

### Pending snap updates
With Ubuntu 22.04 a notification might appear reporting
["Pending Update of Snap Store"](https://askubuntu.com/a/1412580).

The issue is that neither from terminal nor from *Ubuntu Software*
application the update works. This is because `snap-store` starts
automatically on login.

So first `kill` the process (either from command line or using *System
Monitor*), and then run
```bash
sudo snap refresh
```

Note: see all pending updates by running `snap refresh --list`.

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

#### Nvidia on Wayland
Ubuntu 22.04 (LTS) will fallback to and start with X11 on a machine with
Nvidia. It's possible, however, to override this rule and run it with
Wayland just fine.

Enabling Wayland requires a manual change as described
[here](https://askubuntu.com/a/1403916). Additionally, also modify
`/etc/gdm3/custom.conf` as follows:
```
PreferredDisplayServer=wayland
WaylandEnable=true
XorgEnable=false
```

Note that on Ubunut, one can tell the session type from the
`XDG_SESSION_TYPE` environment variable.

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

### Language servers not working with `coc.nvim`
Some language servers managed by
[`coc.nvim`](https://github.com/neoclide/coc.nvim) may misbehave. For
instance the [HLS](https://github.com/haskell/haskell-language-server)
may error on hover to display documentation and generally not check the
code for errors.

There is a configuration file `.config/coc/coc-settings.json` that is
automatically symlinked but nvim/coc may not load it. This situation can
be checked by running `:CocConfig` and if the buffer is empty the linked
file is not loaded.

The fix is simply to paste the content of `coc-settings.json` to the
`:CocConfig` buffer and (re)write it.

### `cargo-audit` installation and usage
The installation of `cargo-audit` might fail if installed manually and
the system does not have `libssl-dev` installed (note that if one uses
`make rust-tools` this should not happen).

In such case, and possibly in other situations, the *advisory database*
might get into an invalid state.

Fortunately, according to
[this issue](https://github.com/RustSec/rustsec/issues/32), the fix is
simply to drop the database:
```bash
rm -rf $CARGO_HOME/advisory-db/
```

Next invocation of `cargo audit` will fetch it again and fix the issue.

### Sdkman completions
According to [`zsh-sdkman`](https://github.com/matthieusb/zsh-sdkman)'s
usage notes:
> if you do new installations on your sdkman candidate or just play
> around with new versions, uninstallations or updates, don't forget to
> refresh the completion script files with the following command:
```bash
sdk-refresh-completion-files
```

### Reinstall `pipx` for new Python
According to this
[issue comment](https://github.com/pypa/pipx/issues/278#issuecomment-659703665)
once should be able to fix `pipx` installations as follows:
```bash
pipx reinstall-all
```

Alternatively, one can reinstall `pipx` and the tools manually
(mentioned in the same issue that was referenced above):
 1. Uninstall python tools: `pipx uninstall-all`
 1. Uninstall `pipx` and remove `$XDG_BIN_HOME/pipx` and `~/.local/pipx`
 1. Re-install `pipx` and tools using `make python-tools`

An indication for issues with `pipx` might be an error log mentioning
> No module named pip

### Profiling tools need additional support from the system

#### Performance events
Some profiling tools (e.g. `samply` or `flamegraph`) require access to
the _performance events system_.

These settings can help:
```bash
sudo sysctl kernel.perf_event_paranoid=1
sudo sysctl kernel.perf_event_mlock_kb=2048
```

#### Tracing scope
Some tools (e.g. `heaptrack`) need adjustment of the `ptrace` scope:
```bash
echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
```

#### Debug symbols
Also, for _Rust_ binaries it's necessary __not__ to strip debug symbols
from the binary. This might be the case when building/running in the
`--release` profile. One possibility is to add a custom profile like the
following one:
```toml
[profile.profiling]
inherits = "release"
debug = true
```

