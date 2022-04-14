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

# XDG specification does not define this variable but it is mentioned/assumed by
# some apps/libs (e.g. `ghcup`) so it might be useful to export it anyway.
#  - https://www.haskell.org/ghcup/guide/#xdg-support
export XDG_BIN_HOME="${XDG_BIN_HOME:-$HOME/.local/bin}"

# This variable is not set by default but is defined in the XDG specification.
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# System and architecture
export ARCH=$(uname -m)

# Compilation flags
# export ARCHFLAGS="-arch $ARCH"

# Editor setup
export VISUAL=nvim
export EDITOR=${VISUAL}
export VIMRC=${XDG_CONFIG_HOME}/nvim/init.vim

# Personal user info
export NAME="Martin Matyášek"
export EMAIL=martin.matyasek@gmail.com

# CUDA
export CUDA_CACHE_PATH=${XDG_CACHE_HOME}/nv

# Binenv
export BINENV_HOME=${HOME}/.binenv

# Rust
#  - Note: Out-of-the-box XDG support is still an open issue for both `rustup`
#    and `cargo`, monitor.
#  - https://github.com/rust-lang/rustup/issues/247
#  - https://github.com/rust-lang/cargo/issues/1734
export RUSTUP_HOME=${XDG_DATA_HOME}/rustup 
export CARGO_HOME=${XDG_DATA_HOME}/cargo
export CARGO_BIN=${CARGO_HOME}/bin
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
export BASE16_SHELL_HOME=${XDG_CONFIG_HOME}/base16-shell

# Bat
export BAT_CONFIG_DIR=${XDG_CONFIG_HOME}/bat
export BAT_CONFIG_PATH=${BAT_CONFIG_DIR}/config

# fd
export FD_CONFIG_HOME=${XDG_CONFIG_HOME}/fd

# rg
export RIPGREP_CONFIG_HOME="${XDG_CONFIG_HOME}/rg"
export RIPGREP_CONFIG_PATH=${RIPGREP_CONFIG_HOME}/ripgreprc

# wget
# - Despite the fact it's not recommended to override command behavior in
#   `.envrc` (since it's always loaded, even for non-interactive shells), here
#   we actually want to prevent all executions from creating `~/.wget-hsts`
# - An alternative is to set `hsts-file` in `WGETRC` but it must use an absolute
#   path, i.e. cannot dynamically change with `XDG_CACHE_HOME`
# - See: https://wiki.archlinux.org/title/XDG_Base_Directory
# - Uncomment `WGETRC` if it's present and should be used
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
#  - Since the only file is `keras.json` config, `XDG_CONFIG_HOME` is used here
export KERAS_HOME=${XDG_CONFIG_HOME}/keras

# Dungeon Crawl Stone Soup
#  - Note: the trailing slash is required
#  - See: https://wiki.archlinux.org/title/XDG_Base_Directory
export CRAWL_DIR="${XDG_DATA_HOME}/crawl/"

# Path extension
export PATH=${PATH}:${XDG_BIN_HOME}
export PATH=${PATH}:${CARGO_BIN}
export PATH=${PATH}:${GOBIN}
export PATH=${PATH}:${GEM_BIN}
export PATH=${PATH}:${KREW_BIN}
export PATH=${PATH}:/usr/local/bin
export PATH=${PATH}:${BINENV_HOME}
export PATH=${PATH}:"${XDG_DATA_HOME}/npm/bin"

