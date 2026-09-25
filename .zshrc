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

# Aliases — fuzzy-pick an issue, feed it to claude
alias ci='claude "/implement $(~/.claude-helpers/select-issue.sh --type story --stage backlog)"'
alias cr='claude "/refine $(~/.claude-helpers/select-issue.sh --type epic --stage backlog)"'
alias cv='claude "/review $(~/.claude-helpers/select-issue.sh --stage ready-for-review)"'
alias cf='claude "/fix $(~/.claude-helpers/select-issue.sh --stage needs-changes)"'
alias cid='claude /idea'
alias cm='~/.claude-helpers/claude-menu.sh'

# Aliases
alias df="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
alias lg='lazygit'
alias p='pnpm'
alias pnr='pnpm nx run'
alias c='claude'
alias comfy='(cd ~/personal/projects/ComfyUI && source venv/bin/activate && python main.py)'
alias ll='ls -l'
alias gs='git status '
alias ga='git add '
alias gcm='git commit -m '
alias gco='git checkout '
alias gcob='git checkout -b'
alias gt='git tag staging-$(date +%Y.%m.%d)'
alias n='neovide'


# Go
export PATH="$PATH:$(go env GOPATH)/bin"

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

# quick-find: ctrl+g to fuzzy-find repos, files, or directories
quick-find-widget() {
  local selected
  selected=$(quick-find)
  if [[ -n "$selected" ]]; then
    if [[ -d "$selected" ]]; then
      BUFFER="cd ${(q)selected}"
    else
      BUFFER="${EDITOR:-vim} ${(q)selected}"
    fi
    zle accept-line
  fi
  zle reset-prompt
}
zle -N quick-find-widget
bindkey '^G' quick-find-widget

# Tab-completion for claude-story aliases
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# stage-hero deploy tags (gts=staging, gtp=production)
alias gts='/Users/jopluysterburg/personal/projects/stage-hero/scripts/deploy-tag.sh staging'
alias gtp='/Users/jopluysterburg/personal/projects/stage-hero/scripts/deploy-tag.sh production'
