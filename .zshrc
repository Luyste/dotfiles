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
alias lg='lazygit'
alias p='pnpm'
alias c='claude'
alias less='less -r'
alias ll='ls -l'
alias gs='git status '
alias gss='git status -s'
alias gp='git pull'
alias gho='git push -u origin '
alias up='git push '
alias upo='git push -u origin '
alias ga='git add '
alias gaa='git add -A'
alias gb='git branch '
alias gc='git commit '
alias gcm='git commit -m '
alias gd='git diff'
alias gco='git checkout '
alias gcob='git checkout -b'
alias gk='gitk --all&'
alias gx='gitx --all'
alias got='git '
alias get='git '
alias g='git '
alias gm='git merge '
alias gr='git reset '
alias gdf='git clean -f'
alias gst='git stash'
alias gsta= 'git stash apply'
alias dcup= 'docker compose up'
alias dcd= 'docker compose down'

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
export PATH="$HOME/.local/bin:$PATH"

# repo-finder: ctrl+g to fuzzy-find git repos and cd into them
repo-finder-widget() {
  local selected
  selected=$(repo-finder)
  if [[ -n "$selected" ]]; then
    BUFFER="cd ${(q)selected}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N repo-finder-widget
bindkey '^G' repo-finder-widget
