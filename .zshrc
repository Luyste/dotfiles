# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Aliases
alias df="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

# opencode
export PATH=/Users/jopluysterburg/.opencode/bin:$PATH

# scripts

dotup() {
  # Stage tracked + new files (change to -u if you only want tracked updates)
  df add -u

  # If nothing to commit, stop cleanly
  if df diff --cached --quiet; then
    echo "dotup: nothing to commit"
    return 0
  fi

  local msg="Update $(date +'%Y-%m-%d %H:%M') $(uname -s)/$(uname -m) $(hostname -s)"
  df commit -m "$msg" && df push
}
