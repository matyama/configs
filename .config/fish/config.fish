# update PATH
set -U fish_user_paths $XDG_BIN_HOME $fish_user_paths
set -U fish_user_paths $CARGO_BIN $fish_user_paths
set -U fish_user_paths $GOPATH $fish_user_paths
set -U fish_user_paths $KREW_BIN $fish_user_paths

# fzf
#  - https://github.com/junegunn/fzf#layout
#  - https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/fzf#settings
if command -v fzf > /dev/null
  setenv FZF_DEFAULT_COMMAND "fd --type file --follow --hidden"
  setenv FZF_CTRL_T_COMMAND "fd --type file --follow --hidden"
  setenv FZF_DEFAULT_OPTS "--height 25% --layout=reverse --border"
end

if command -v wget > /dev/null
  setenv WGETRC $XDG_CONFIG_HOME/wget/wgetrc
end

if status is-interactive
# Commands to run in interactive sessions can go here

# Disable welcome message
set fish_greeting

abbr -a e nvim
abbr -a m make
abbr -a o xdg-open
abbr -a g git
abbr -a ts 'tmux new-session -s'

# Copy/Paste
abbr -a y 'wl-copy'
abbr -a c 'wl-copy'
abbr -a p 'wl-paste'
abbr -a rmclip 'wl-copy -c'

# Git
abbr gb 'git branch'
abbr gc 'git commit --verbose'
abbr gl 'git pull'
abbr gp 'git push'
abbr gst 'git status'
abbr grbi 'git rebase --interactive'
abbr grbc 'git rebase --continue'

# Python
setenv PYTHON_HISTORY $XDG_STATE_HOME/python_history
setenv PYTHONPYCACHEPREFIX $XDG_CACHE_HOME/python
setenv PYTHONUSERBASE $XDG_DATA_HOME/python

# https://eza.rocks
if command -v eza > /dev/null
  abbr -a ls 'eza'
  abbr -a la 'eza -lAh'
  alias l 'eza -lahg --git'
  alias ll 'eza -lahg --git --git-ignore --tree --level=3'
  alias lt 'eza -lahg --git --tree'
end

# Bat customization (https://github.com/sharkdp/bat#customization)
#  - Do not add `BAT_THEME` to `.zshenv`/`.zprofile` or bat config file as it
#    might be altered by the Base16 hook above.
#  - Use `base16-256` for bat which, according to the docs, "is designed for
#    `base16-shell`"
#  - Use fully stylized bat by default
if command -v bat > /dev/null
  setenv BAT_THEME base16-256
  setenv BAT_STYLE full

  setenv LESSCOLORIZER bat

  abbr -a b 'bat'
  abbr -a bp 'bat --plain'
end

if command -v just > /dev/null
  abbr -a j 'just'
end

if command -v kubectl > /dev/null
  abbr -a k 'kubectl'
end

if command -v rucola > /dev/null
  alias notes 'rucola ~/Documents/notes'
  # TODO: alias to mdbook serve notes in the backgroud (?)
end

# FIXME: currently running through bash
if command -v tinty > /dev/null
  # Tinted Shell (https://github.com/tinted-theming/tinted-shell)
  setenv TINTED_SHELL_ENABLE_VARS 1
  setenv TINTED_SHELL_ENABLE_BASE16_VARS 1

  # Tinted tmux (https://github.com/tinted-theming/tinted-tmux)
  #setenv TINTED_TMUX_OPTION_ACTIVE 1
  setenv TINTED_TMUX_OPTION_STATUSBAR 1

  tinty init
  # TODO: cache in $XDG_CACHE_HOME/fish/generated_completions/
  tinty generate-completion fish | source
end

# Colored man output
# See: https://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
setenv LESS_TERMCAP_mb \e'[01;31m'       # begin blinking
setenv LESS_TERMCAP_md \e'[01;38;5;74m'  # begin bold
setenv LESS_TERMCAP_me \e'[0m'           # end mode
setenv LESS_TERMCAP_se \e'[0m'           # end standout-mode
setenv LESS_TERMCAP_so \e'[38;5;246m'    # begin standout-mode - info box
setenv LESS_TERMCAP_ue \e'[0m'           # end underline
setenv LESS_TERMCAP_us \e'[04;38;5;146m' # begin underline

# Make less better
# X = leave content on-screen
# F = quit automatically if less than one screenfull
# R = raw terminal characters (fixes git diff)
#     see http://jugglingbits.wordpress.com/2010/03/24/a-better-less-playing-nice-with-git/
setenv LESS "-F -X -R"

# TODO(remove): XDG should be fully supported when version 600 lands
# Set configuration files for less
#setenv LESSKEY=${XDG_CONFIG_HOME}/less/lesskey
#setenv LESSHISTFILE=${XDG_STATE_HOME}/less/lesshst

# TODO: experiment with vi/hybrid-style keybindings
#  - https://fishshell.com/docs/current/interactive.html#command-line-editor
#  - https://github.com/fish-shell/fish-shell/blob/master/share/functions/fish_hybrid_key_bindings.fish
function fish_user_key_bindings --description "Extended emacs-style bindings"
  # ctrl-space accepts suggestion
  bind ctrl-space accept-autosuggestion

  # Move up/down in history with ctrl+arrows
  bind ctrl-up history-token-search-backward
  bind ctrl-down history-token-search-forward

  # copy current selection to clipboard with ctrl-o
  bind ctrl-o fish_clipboard_copy

  # fancy ctrl-z
	bind ctrl-z 'fg>/dev/null 2> /dev/null'

  # fzf keybindings
  if functions -q fzf_key_bindings
    fzf_key_bindings
	end
end

if command -v fzf > /dev/null
  # Set up fzf key bindings
  #fzf --fish | source

  function ef -d "Search file with a fuzzy finder and open it with the editor"
    $EDITOR $(fzf --preview="bat --style=numbers --color=always {}")
  end
end

if command -v starship > /dev/null
  # starship uses ~/.config/starship.toml by default
  setenv STARSHIP_CONFIG $XDG_CONFIG_HOME/starship/starship.toml
  # init starship prompt
  starship init fish | source
else
  # TODO PS1="%F{#d65d0e}[%n@%m]%f %F{#458588}%5~%f %F{#3c3836}|%f "
end

if command -v zoxide > /dev/null
  zoxide init --cmd cd fish | source
end

if command -v mcfly > /dev/null
  setenv MCFLY_KEY_SCHEME vim
  setenv MCFLY_FUZZY 2
  setenv MCFLY_RESULTS 20
  setenv MCFLY_HISTORY_LIMIT 10000

  # FIXME: does not seem to override ctrl-r
  mcfly init fish | source
end

end
