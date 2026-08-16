#!/usr/bin/env bash

echo ">>> Running initial upgrade..."
sudo pacman -Syu

echo ">>> Setting up environment..."
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-$HOME/.cache}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export XDG_BIN_HOME=${XDG_BIN_HOME:-$HOME/.local/bin}
export XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
export XDG_DEV_HOME="$HOME/.local/dev"
export XDG_TMP_HOME="$HOME/.cache/tmp"

# XXX: CARGO_BIN might not be needed with rustup installed via pacman
# https://wiki.archlinux.org/title/Rust#Arch_Linux_package
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export CARGO_BIN="${CARGO_HOME}/bin"
export CARGO_TARGET_DIR="${XDG_CACHE_HOME}/cargo-target"

mkdir -p \
  "${XDG_DEV_HOME}" \
  "${XDG_TMP_HOME}" \
  "${XDG_CONFIG_HOME}/newsboat" \
  "${XDG_CONFIG_HOME}/wget" \
  "${XDG_CACHE_HOME}/newsboat/articles" \
  "${XDG_CACHE_HOME}/newsboat/podcasts" \
  "${XDG_CACHE_HOME}/python" \
  "${XDG_DATA_HOME}/fish/vendor_completions.d" \
  "${XDG_DATA_HOME}/newsboat" \
  "${XDG_DATA_HOME}/python" \
  "${XDG_STATE_HOME}/wget"

echo ">>> Installing bootstrap tools..."
# XXX: curl ...although, how else would we get this script
# Installed packages
#  - base-devel: autoconf  automake  binutils, gcc, make, grep, gzip, etc.
sudo pacman -S base-devel git neovim just

# TODO: move this to make
# TODO: make a checklist of binaries that should be installed after all of this
echo ">>> Installing packages..."
# XXX: check if some packages are dependencies of some other (don't install)
#  - cmake
#  - sysstat
#
# TODO: separate all GUI/non-GUI packages
# TODO: install fish shell
# TODO: make -C ... bash
# TODO: binfmt (pacman -Ss binfmt), bitwarden-cli (pacman -Ss bitwarden),
#       nvm (pacman -Ss nvm)
# TODO: calibre from AUR
#
# TODO: replace pacman installs with a meta packages (see base-devel above)
#
# XXX: are these really needed?
#  - blueman ...bluetui exists
#  - htop ...btop exists
#  - skim ...fzf exists
#    - TODO: if kept, then set up fish keybindings
#  - wl-clipboard ..."Optional For    : fish  neovim"
#
# TODO: check if relevant & install
#  - cpu-checker: tools to help evaluate certain CPU (or BIOS) features
#    (e.g., kvm-ok)
#
# Installed as dependencies for another package (`pacman -Sii <pkg>`)
#  - ca-certificates
#
# Resources
#  - https://wiki.archlinux.org/title/Network_tools
#
# Installed tools
#  - bash-language-server: language server for Bash
#  - bat: A cat(1) clone with wings
#  - bat-extras: Bash scripts that integrate bat with various tools
#  - bluetui: TUI for managing bluetooth on Linux
#    Requires: bluez, libdbus-1-dev (build)
#  - btop: command line resource monitor that shows usage and stats
#  - caligula: A user-friendly, lightweight TUI for disk imaging
#  - cava: Console-based Audio Visualizer with support for multiple backends
#  - cmake: software build system for C/C++
#  - dust: A more intuitive version of du in rust
#  - eza: A modern, maintained replacement for 'ls'
#  - fastfetch: A command-line system information tool
#  - fd: Simple, fast and user-friendly alternative to find
#  - fuse2: Filesystem in Userspace
#    (https://github.com/AppImage/AppImageKit/wiki/FUSE)
#  - fwupd: Simple daemon to allow session software to update firmware
#    (https://wiki.archlinux.org/title/Fwupd)
#  - gimp: GNU Image Manipulation Program
#  - git-delta: A syntax-highlighting pager for git, diff, and grep output
#  - go: Core compiler tools for the Go programming language
#  - gping: Ping, but with a graph
#  - hexyl: A command-line hex viewer
#  - hyperfine: A command-line benchmarking tool
#  - inkscape: vector graphics editor
#  - jq: Command-line JSON processor
#  - lesspipe: an input filter for the pager less
#    (https://github.com/wofr06/lesspipe)
#  - linux-tools-meta: Linux kernel tools meta package (e.g., perf)
#  - man-db: A utility for reading man pages
#  - mcfly: Fly through your shell history
#  - mdbook: Build a book from Markdown files
#    (https://github.com/rust-lang/mdBook)
#  - mpd: Music Player Daemon
#  - mpv: command line video player
#  - nmap: Utility for network discovery and security auditing
#    (note: includes ncat)
#  - newsboat: RSS/Atom feed reader for text terminals
#    - Needs pre-existing config directory to pick it up instead of HOME, see:
#      https://github.com/newsboat/newsboat/issues/2658#issuecomment-1886815612
#  - onefetch: Command-line Git information tool
#  - openssl: secure sockets layer toolkit (note: includes debian's libssl-dev)
#  - pacman-contrib: scripts and tools for pacman
#    (e.g., https://wiki.archlinux.org/title/Pacman#Pactree)
#  - plymouth: Graphical boot splash screen
#    (https://wiki.archlinux.org/title/Plymouth)
#  - procs: A modern replacement for ps written in Rust
#  - rclone: rsync for cloud storage
#  - ripgrep: Recursively searches directories for a regex pattern
#  - rmpc: A modern, configurable, terminal based MPD client
#  - rucola: Terminal-based markdown note manager
#  - rustup: The Rust toolchain installer
#  - samply: Command-line sampling profiler for macOS, Linux, and Windows
#  - sd: Intuitive find & replace CLI (sed alternative)
#  - shellcheck: static analysis tool for shell scripts
#  - shfmt: Formatter for shell programs
#    - used by prettybat from bat-extras
#  - skim: Fuzzy Finder in rust!
#  - stylua: A Lua code formatter
#  - sysstat: System performance tools for Linux
#    (https://github.com/sysstat/sysstat)
#  - tealdeer: A very fast implementation of tldr in Rust
#  - traceroute: Tracks the route taken by packets over an IP network
#  - ttf-meslo-nerd: Patched font Meslo LG from nerd fonts library
#  - uv: Python package installer & resolver
#  - watchexec: Executes commands in response to file modifications
#    - Replaces cargo-watch (archived)
#    - TODO: try also https://dystroy.org/bacon
#  - wget: Network utility to retrieve files from the web
#  - wl-clipboard: Command-line copy/paste utilities for Wayland
#  - whois: Intelligent WHOIS client
#  - xh: Friendly and fast tool for sending HTTP requests
#  - yamlfmt: An extensible command line tool or library to format yaml files
#  - zoxide: A smarter cd command
sudo pacman -S \
  alacritty \
  aws-cli-v2 \
  bash-completion \
  bash-language-server \
  bat \
  bat-extras \
  blueman \
  bluetui \
  btop \
  caligula \
  cava \
  cmake \
  docker \
  docker-compose \
  dust \
  eza \
  fastfetch \
  fd \
  fuse2 \
  fwupd \
  gimp \
  git-delta \
  github-cli \
  go \
  gping \
  hexyl \
  htop \
  hyperfine \
  iftop \
  inkscape \
  iotop \
  iwd \
  just-lsp \
  lesspipe \
  linux-tools-meta \
  luajit \
  lua-language-server \
  man-db \
  mcfly \
  mdbook \
  moreutils \
  mpd \
  mpv \
  networkmanager \
  nmap \
  newsboat \
  onefetch \
  openssl \
  pacman-contrib \
  plymouth \
  procs \
  rclone \
  ripgrep \
  rmpc \
  rucola \
  rustup \
  samply \
  sd \
  shellcheck \
  shfmt \
  stylua \
  sysstat \
  tealdeer \
  tmux \
  traceroute \
  tree \
  ttf-meslo-nerd \
  uv \
  watchexec \
  wget \
  wl-clipboard \
  whois \
  xh \
  yamlfmt \
  zoxide

# TODO: pin nightly to a corresponding stable revision
echo ">>> Installing Rust toolchain and components..."
rustup default stable
rustup update stable
rustup install beta nightly

rustup component add rust-src rust-analyzer
rustup +beta component add rust-src rust-analyzer
rustup +nightly component add miri

echo ">>> Installing AUR packages..."

# TODO: after installing rust or at least setting up env
# paru - AUR helper and pacman wrapper
# sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru "${XDG_DEV_HOME}/paru"
makepkg -si --dir "${XDG_DEV_HOME}/paru"

# AUR packages distributing pre-built binaries:
#  - grpcurl: Like cURL, but for gRPC
#  - hadolint: Dockerfile linter
paru -S --needed grpcurl-bin hadolint-bin

# AUR packages building from sources:
#  - tinty: Base16 and base24 color scheme manager
paru -S --needed tinty-git
#tinty sync
#tinty apply base16-gruvbox-dark-hard

paru -S --noprovides forgit
# TODO: ln instead, but need to deal with versions somehow
tar -xOzf \
  "${XDG_CACHE_HOME}/paru/clone/forgit/forgit-$(grep -oP '^pkgver=\K.*$' "${XDG_CACHE_HOME}/paru/clone/forgit/PKGBUILD").tar.gz" \
  --wildcards '**/completions/git-forgit.fish' \
  >"${XDG_DATA_HOME}/fish/vendor_completions.d/git-forgit.fish"

# TODO: https://wiki.archlinux.org/title/Keybase

echo ">>> Installing DE and related packages..."

# TODO: networkmanager, idw + configure (see notes.md)
# TODO: bitwarden (GUI)
# XXX: here or in essentials above?

echo ">>> Installing GNOME / GTK environment..."
# TODO: actually install gnome
# Installed packages
#  - gnome-themes-extra,sassc: needed for Gruvbox-GTK-Theme
#    (https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme)
sudo pacman -S noto-fonts gnome-themes-extra gnome-tweaks
sudo pacman -S --needed sassc

# TODO: I'm a simple man, I like GRUB, so switch to it
echo ">>> Configuring boot loader & kernel parameters.."
# https://wiki.archlinux.org/title/Kernel_parameters#systemd-boot

# enable editing parameters from the boot menu
grep -qxF 'editor 1' /boot/loader/loader.conf ||
  (echo 'editor 1' | sudo tee --append /boot/loader/loader.conf)

# add quiet and splash parameters to enable plymouth splash screen
sudo sed \
  -i \
  '/ rw quiet splash /!s/ rw /&quiet splash /' \
  /boot/loader/entries/*.conf

echo ">>> Configuring installed tools..."

echo ">>> Setting up graphical boot splash screen..."
# https://wiki.archlinux.org/title/Plymouth#mkinitcpio

# add plymouth to the HOOKS array in mkinitcpio.conf
# https://unix.stackexchange.com/a/523313
sudo sed \
  -i \
  -e '/ plymouth encrypt /!s/ encrypt / plymouth&/' \
  -e '/ plymouth sd-encrypt /!s/ sd-encrypt / plymouth&/' \
  /etc/mkinitcpio.conf

# re-generate initramfs images based on all existing presets
# https://wiki.archlinux.org/title/Mkinitcpio#Manual_generation
sudo mkinitcpio --allpresets

echo ">>> Reloading fonts cache"
fc-cache -f

echo ">>> Setting up neovim spell-check"
touch "${XDG_CONFIG_HOME}"/nvim/spell/en.utf-8.add

echo ">>>> Configuring newsboat (note: edit 'urls' manually)"
touch "${XDG_CONFIG_HOME}/newsboat/urls"
chmod u=rw,g=r,o= "${XDG_CONFIG_HOME}/newsboat/urls"

echo ">>> Configuring perf 'buildid.dir=/var/cache/perf-buildid'"
sudo perf config --system buildid.dir=/var/cache/perf-buildid

echo ">>> Installing Python tools..."

# Installed tools:
#  - pssh: asynchronous parallel SSH library (https://parallel-ssh.org)
uv tool install --compile-bytecode pssh

echo ">>> Installing Rust tools..."

# Installed tools:
#  - bitcli: Simple CLI tool for URL shortening via Bitly
#  - cross: “Zero setup” cross compilation and “cross testing” of Rust crates
#    - TODO: Requires: docker, binfmt-support (for testing)
#    - Installing from git, because the latest release is ~2y old
#  - proximity-sort: Simple command-line utility for sorting inputs by
#    proximity to a path argument (https://github.com/jonhoo/proximity-sort)
#  - taplo: TOML linter, formatter, and LSP
#  - tokio-console: A debugger for async Rust
# cargo install --locked --git https://github.com/matyama/bitcli
#cargo install --locked cross --git https://github.com/cross-rs/cross
cargo install --locked proximity-sort
cargo install --features lsp --locked taplo-cli

cargo install --locked tokio-console
tokio-console gen-completion fish \
  >"${XDG_DATA_HOME}/fish/vendor_completions.d/tokio-console.fish"

echo ">>> Installing Haskell tools..."
export GHCUP_USE_XDG_DIRS=1
export STACK_XDG=1

sudo pacman -S --needed --noconfirm base-devel gmp
paru -S ghcup-hs-bin
# enable additional tools (fourmolu, hlint, etc.)
ghcup config add-release-channel 3rdparty

# Installed tools:
#  - fourmolu: Haskell source code formatter
#  - hlint: Haskell source code suggestions
#  - TODO apply-refact: Refactor Haskell source files
for tool in ghc cabal hls stack fourmolu hlint; do
  echo ">>> Installing latest ${tool}..."
  ghcup install "${tool}" latest
done

echo ">>> Installing custom apps..."
# XXX: slack, zoom-client
#  - dbeaver-ce: universal database tool (https://dbeaver.io)

echo ">>> Enabling systemd services..."
# TODO: https://wiki.archlinux.org/title/Docker#Rootless_Docker_daemon
sudo systemctl enable --now docker.service containerd.service

@echo ">>> Setting up 'docker' user group with current user '$USER'"
sudo groupadd -f docker
sudo gpasswd -a "${USER:-matyama}" docker
sudo usermod -aG docker "${USER:-matyama}"

# enable mpd
mkdir -p "${XDG_CONFIG_HOME}/mpd/playlists" "${XDG_STATE_HOME}/mpd"
# XXX: sudo
systemctl --user endable mpd.service
systemctl --user start --now mpd.service

sudo systemctl enable --now sysstat

# disable wpa_supplicant to make networkmanager work with iwd in gnome
systemctl disable wpa_supplicant
systemctl stop wpa_supplicant

if ! grep -q "iwd backend" /etc/NetworkManager/NetworkManager.conf; then
  sudo tee -a /etc/NetworkManager/NetworkManager.conf >>/dev/null <<EOM
# Register iwd backend
[device]
wifi.backend=iwd
wifi.iwd.autoconnect=yes
EOM
fi

# enable networkmanager
sudo systemctl enable --now NetworkManager.service
