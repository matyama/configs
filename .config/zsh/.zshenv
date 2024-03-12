# This file sets environment variables that should be globally set on the system
#
# See:
#  - https://unix.stackexchange.com/a/71258
#  - https://www.zerotohero.dev/zshell-startup-files/
#
# Note:
#  - Since other zsh config files (e.g. `.zprofile` or `.zshrc`) will be loaded
#    after `.zshenv`, environment variable exported here might be overwritten
#  - Namely, this involves `$PATH`, so watch for potential issues
#  - It is not important to set things like `FZF_DEFAULT_COMMAND` here since
#    that is only relevant when using an interactive shell, so we may as well
#    just set that directly in `.zshrc`
#  - Furthermore, `.zprofile` might be better place for commands and variables
#    that should be set *once* or which **don't need to be updated frequently**

# Ensure that assumed XDG variables exist
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# XDG specification does not define this variable but it is mentioned/assumed by
# some apps/libs (e.g. `ghcup`) so it might be useful to export it anyway.
#  - https://www.haskell.org/ghcup/guide/#xdg-support
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"

# This variable is not set by default but is defined in the XDG specification.
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# System and architecture
#  - https://zsh.sourceforge.io/Doc/Release/Parameters.html
#  - TODO: consider adding `DIST_ARCH` derived from `ARCH` for `amd64 ~ x86_64`
export ARCH="${CPUTYPE:-x86_64}"
#export DIST_ARCH=amd64

# Compilation flags
# export ARCHFLAGS="-arch $ARCH"

# Editor setup
export VISUAL=nvim
export EDITOR=${VISUAL}
export VIMRC=${XDG_CONFIG_HOME}/nvim/init.vim

# Personal user info
export NAME="Martin Matyášek"
export EMAIL=martin.matyasek@gmail.com

# RPM: hack to get rid of `~/.rpmdb` on Ubuntu (https://askubuntu.com/a/476941)
#  - Currently this is hard-coded: `rpm -v --showrc | grep "/.rpmdb"`
#  - Note that it should be safe to delete the dir, hence the `XDG_CACHE_HOME`
alias rpm="rpm --dbpath=${XDG_CACHE_HOME}/rpmdb"

# CUDA
export CUDA_CACHE_PATH=${XDG_CACHE_HOME}/nv

# Binenv
export BINENV_BINDIR=${XDG_DATA_HOME}/binenv
export BINENV_LINKDIR=${XDG_BIN_HOME}

# Rust
#  - See: https://doc.rust-lang.org/cargo/reference/environment-variables.html
#  - Note: Out-of-the-box XDG support is still an open issue for both `rustup`
#    and `cargo`, monitor.
#  - https://github.com/rust-lang/rustup/issues/247
#  - https://github.com/rust-lang/cargo/issues/1734
export RUSTUP_HOME=${XDG_DATA_HOME}/rustup
export CARGO_HOME=${XDG_DATA_HOME}/cargo
export CARGO_BIN=${CARGO_HOME}/bin
export CARGO_TARGET_DIR=${XDG_CACHE_HOME}/cargo-target
export CARGO_RELEASE_DIR=${CARGO_TARGET_DIR}/release
export CARGO_ARTIFACTS_DIR=${CARGO_RELEASE_DIR}/artifacts
export CARGO_INCREMENTAL=1
export RUSTFLAGS="-C target-cpu=native"
export RUST_BACKTRACE=1

# Haskell stack
#  - Any value of `GHCUP_USE_XDG_DIRS` will enable XDG support, see:
#    https://www.haskell.org/ghcup/guide/#xdg-support
#  - Note: `XDG_BIN_HOME` will be used for storing binaries and as mentioned in
#    the docs, there might be clash with other tools using it (stack/cabal/ghc)
export GHCUP_USE_XDG_DIRS=1
export CABAL_DIR=${XDG_CACHE_HOME}/cabal
export CABAL_CONFIG=${XDG_CONFIG_HOME}/cabal/config
export STACK_ROOT=${XDG_DATA_HOME}/stack

# Go lang
export GOPATH=${XDG_DATA_HOME}/go
export GOBIN=${GOPATH}/bin

# ClickHouse Client
#  - https://github.com/ClickHouse/ClickHouse/issues/10024 
export CLICKHOUSE_HISTORY_FILE="${XDG_DATA_HOME}/clickhouse/client-history"

# Ansible
export ANSIBLE_HOME="${XDG_CONFIG_HOME}/ansible"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME}/ansible.cfg"
export ANSIBLE_GALAXY_CACHE_DIR="${XDG_CACHE_HOME}/ansible/galaxy_cache"

# AWS CLI & Vault
#  - Note: Out-of-the-box XDG support is still an open issue, monitor.
#  - https://docs.aws.amazon.com/cli/latest/topic/config-vars.html
#  - https://github.com/99designs/aws-vault/blob/master/USAGE.md
#  - https://github.com/aws/aws-sdk/issues/30#issuecomment-532208981
#  - https://github.com/99designs/aws-vault/issues/707
export AWS_CONFIG_FILE="${XDG_CONFIG_HOME}/aws/config"
export AWS_CLI_HISTORY_FILE="${XDG_STATE_HOME}/aws/history"
export AWS_SHARED_CREDENTIALS_FILE="${XDG_DATA_HOME}/aws/credentials}"
export AWS_VAULT_FILE_DIR="${XDG_DATA_HOME}/awsvault/keys"

# Docker
export DOCKER_CONFIG=${XDG_CONFIG_HOME}/docker

# Minikube
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
#  - https://github.com/kubernetes/minikube/issues/4109
#  - Known issue: Creates a further `.minikube` directory in `MINIKUBE_HOME` for
#    whatever reason.
export MINIKUBE_HOME=${XDG_DATA_HOME}/minikube

# Kubernetes Krew
#  - https://krew.sigs.k8s.io/docs/user-guide/advanced-configuration/
export KREW_ROOT=${XDG_DATA_HOME}/krew
export KREW_BIN=${KREW_ROOT}/bin

# Ruby
#  - Note: Since we're using XDG directories and not the default, make sure to
#    remove `gem: --user-install` from `/etc/gemrc` or in general any rc file
#    and `gem install`
#  - See: https://wiki.archlinux.org/title/XDG_Base_Directory
export GEM_HOME=${XDG_DATA_HOME}/gem
export GEM_SPEC_CACHE=${XDG_CACHE_HOME}/gem
export GEM_BIN=${GEM_HOME}/bin

# Travis
#  - Note: Out-of-the-box XDG support is still an open issue, monitor.
#  - https://github.com/travis-ci/travis.rb/issues/219
export TRAVIS_CONFIG_PATH=${XDG_CONFIG_HOME}/travis

# SDKMAN: JVM ecosystem
#  - Note: Out-of-the-box XDG support is still an open issue, monitor.
#  - https://github.com/sdkman/sdkman-cli/issues/659
#  - https://sdkman.io/install
#
# ZSH plugin
#  - https://github.com/matthieusb/zsh-sdkman
export SDKMAN_DIR=${XDG_DATA_HOME}/sdkman
export ZSH_SDKMAN_DIR=${XDG_DATA_HOME}/zsh-sdkman

# Java
#  - Workaround to support XDG and move `~/.java` out of `HOME`
#  - https://wiki.archlinux.org/title/XDG_Base_Directory
#  - https://bugzilla.redhat.com/show_bug.cgi?id=1154277
#  - https://stackoverflow.com/a/30305597/15112035
export JDK_JAVA_OPTIONS="-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java"
export JAVA_OPTS="-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java"

# Gradle
#  - Note: Out-of-the-box XDG support is still an open issue, monitor.
#  - https://github.com/gradle/gradle/issues/17756
#  - According to the issue: "gradle still puts some stuff under
#    `~/.gradle/daemon` even with `GRADLE_USER_HOME` pointing elsewhere"
export GRADLE_USER_HOME=${XDG_DATA_HOME}/gradle

# kscript
#  - Note: Out-of-the-box XDG support is still an open issue, monitor.
#  - https://github.com/holgerbrandl/kscript/issues/323
export KSCRIPT_CACHE_DIR=${XDG_CACHE_HOME}/kscript

# Node.js
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export NODE_REPL_HISTORY=${XDG_DATA_HOME}/node_repl_history

# Base16
export BASE16_FZF_HOME=${XDG_CONFIG_HOME}/base16-fzf
export BASE16_SHELL_PATH=${HOME}/.config/base16-shell
# TODO: currently tinted-theming hardcodes `$HOME/.config`, use
# `XDG_CONFIG_HOME` once supported
#export BASE16_SHELL_PATH=${XDG_CONFIG_HOME}/base16-shell
export BASE16_THEME_DEFAULT=gruvbox-dark-hard

# Bat
export BAT_CONFIG_DIR=${XDG_CONFIG_HOME}/bat
export BAT_CONFIG_PATH=${BAT_CONFIG_DIR}/config

# fd
export FD_CONFIG_HOME=${XDG_CONFIG_HOME}/fd

# rg
export RIPGREP_CONFIG_HOME="${XDG_CONFIG_HOME}/rg"
export RIPGREP_CONFIG_PATH=${RIPGREP_CONFIG_HOME}/ripgreprc

# nvidia-settings
#  - `nvidia-settings --config ...` is a workaround to make nvidia-settings XDG
#    compliant, see: https://github.com/NVIDIA/nvidia-settings/issues/30
#  - Despite the fact it's not recommended to override command behavior in
#    `.envrc` (since it's always loaded, even for non-interactive shells), here
#    we actually want to prevent all executions from creating
#    `~/.nvidia-settings-rc`
#  - Note: Make sure that the directory with custom config exists.
export NVIDIA_SETTINGS_RC=${XDG_CONFIG_HOME}/nvidia-settings/nvidia-settings-rc
alias nvidia-settings="nvidia-settings --config ${NVIDIA_SETTINGS_RC}"

# wget
#  - Despite the fact it's not recommended to override command behavior in
#    `.envrc` (since it's always loaded, even for non-interactive shells), here
#    we actually want to prevent all executions from creating `~/.wget-hsts`
#  - An alternative is to set `hsts-file` in `WGETRC` but it must use an
#    absolute path, i.e. cannot dynamically change with `XDG_CACHE_HOME`
#  - See: https://wiki.archlinux.org/title/XDG_Base_Directory
#  - Uncomment `WGETRC` if it's present and should be used
#export WGETRC=${XDG_CONFIG_HOME}/wgetrc
alias wget="wget --hsts-file=${XDG_CACHE_HOME}/wget-hsts"

# Maven
#  - `mvn -gs` is a workaround to make maven XDG compliant
#  - See: https://issues.apache.org/jira/browse/MNG-6603
#  - Note that this relies on custom `settings.xml` which is symlinked so any
#    further modifications should go there
#  - Despite the fact it's not recommended to override command behavior in
#    `.envrc` (since it's always loaded, even for non-interactive shells), here
#    we actually want to prevent all executions from creating `~/.m2`
alias mvn="mvn -gs ${XDG_CONFIG_HOME}/maven/settings.xml"

# Python
#  - Sets path to custom startup file for interactive Python:
#    https://docs.python.org/3.8/using/cmdline.html#envvar-PYTHONSTARTUP
export PYTHONSTARTUP=${XDG_CONFIG_HOME}/python/startup.py

# IPython
#  - Should support XDG directories since version 8.x. Despite the fact that
#    `$HOME` is still the default, `XDG_CONFIG_HOME` should be picked up.
#  - https://github.com/matyama/configs/issues/17#issuecomment-1094140403
#
# Jupyter
#  - Note: Out-of-the-box XDG support is still an open issue, monitor.
#  - https://github.com/jupyter/jupyter_core/issues/185
export JUPYTER_CONFIG_DIR=${XDG_CONFIG_HOME}/jupyter

# Kaggle
export KAGGLE_CONFIG_DIR=${XDG_CONFIG_HOME}/kaggle

# scikit-learn datasets
#  - https://scikit-learn.org/stable/modules/generated/sklearn.datasets.get_data_home.html
#  - Note: There's a bug in the default dir name in the docs (check the code).
export SCIKIT_LEARN_DATA=${XDG_CACHE_HOME}/scikit_learn_data

# TensorFlow datasets
#  - https://www.tensorflow.org/datasets/api_docs/python/tfds/load
export TFDS_DATA_DIR=${XDG_CACHE_HOME}/tensorflow_datasets

# Keras
#  - https://github.com/tensorflow/tensorflow/issues/38831
#  - Since `KERAS_HOME` contains config `keras.json` which is re-created when
#    missing and cached datasets, `XDG_CACHE_HOME` is probably the best option
export KERAS_HOME=${XDG_CACHE_HOME}/keras

# Dungeon Crawl Stone Soup
#  - Note: the trailing slash is required
#  - See: https://wiki.archlinux.org/title/XDG_Base_Directory
export CRAWL_DIR="${XDG_DATA_HOME}/crawl/"

# Path extension
typeset -aU path
path+=${XDG_BIN_HOME}
path+=${CARGO_BIN}
path+=${CARGO_RELEASE_DIR}
path+=${GOBIN}
path+=${GEM_BIN}
path+=${KREW_BIN}
path+="/usr/local/bin"
path+="${CABAL_DIR}/bin"
path+="${COURSIER_BIN_DIR}"
path+="${XDG_DATA_HOME}/npm/bin"
