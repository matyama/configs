# shellcheck disable=all

zshaddhistory() {
  emulate -L zsh
  HISTORY_IGNORE="${HISTORY_IGNORE:-}"
  ## uncomment if HISTORY_IGNORE should use EXTENDED_GLOB syntax
  # setopt extendedglob
  [[ $1 != ${~HISTORY_IGNORE} ]]
}
