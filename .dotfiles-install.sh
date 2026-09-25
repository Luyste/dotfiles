#!/usr/bin/env bash
#
# Bootstraps a Mac with Luyste/dotfiles (bare repo) and the
# Neovim + Neovide setup.
#
# Run on a new machine with:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Luyste/dotfiles/main/.dotfiles-install.sh)
#
# Safe to rerun at any time:
#   - tools that already exist (via Homebrew OR any other install) are skipped
#   - a failing step is reported at the end instead of aborting the script
#   - files that the dotfiles checkout would overwrite are backed up first
#
# Written for macOS's built-in bash 3.2 (no associative arrays).

set -uo pipefail

DOTFILES_REPO="https://github.com/Luyste/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"

# ---------------------------------------------------------------------------
# Tool lists: "package:command-it-provides"
# A package is skipped when its command is already on PATH, however it was
# installed. Edit these when you add or remove languages.
# ---------------------------------------------------------------------------

BREW_FORMULAE=(
  "git:git"
  "neovim:nvim"
  "node:node"
  "go:go"
  "fzf:fzf"
  "fd:fd"
  "ripgrep:rg"
  "lazygit:lazygit"
  "gh:gh"
  "marksman:marksman"
  "taplo:taplo"
  "lua-language-server:lua-language-server"
  "stylua:stylua"
)

# "cask:App name in /Applications"
BREW_CASKS=(
  "neovide:Neovide.app"
)

NPM_PACKAGES=(
  "typescript:tsc"
  "typescript-language-server:typescript-language-server"
  "vscode-langservers-extracted:vscode-css-language-server"
  "dockerfile-language-server-nodejs:docker-langserver"
  "yaml-language-server:yaml-language-server"
  "@typespec/compiler:tsp-server"
  "prettier:prettier"
  "@fsouza/prettierd:prettierd"
)

GO_PACKAGES=(
  "golang.org/x/tools/gopls@latest:gopls"
  "golang.org/x/tools/cmd/goimports@latest:goimports"
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

FAILED=()

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m  ✓\033[0m %s\n" "$1"; }
skip() { printf "\033[0;90m  - %s\033[0m\n" "$1"; }
warn() { printf "\033[1;33m  !\033[0m %s\n" "$1"; }
fail() { printf "\033[1;31m  ✗\033[0m %s\n" "$1"; FAILED+=("$1"); }

has() { command -v "$1" >/dev/null 2>&1; }

dot() { git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"; }

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is written for macOS." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 1. Homebrew (required for everything else)
# ---------------------------------------------------------------------------

info "Homebrew"
if ! has brew; then
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$candidate" ]] && eval "$("$candidate" shellenv)" && break
  done
fi

if has brew; then
  skip "already installed"
else
  info "Installing Homebrew (asks for your password)"
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      [[ -x "$candidate" ]] && eval "$("$candidate" shellenv)" && break
    done
  fi
  if ! has brew; then
    echo "Homebrew could not be installed; nothing else can run. Aborting." >&2
    exit 1
  fi
  ok "Homebrew installed"
fi

# ---------------------------------------------------------------------------
# 2. Brew formulae
# ---------------------------------------------------------------------------

info "Command-line tools"
for entry in "${BREW_FORMULAE[@]}"; do
  pkg="${entry%%:*}"
  cmd="${entry#*:}"
  if has "$cmd" || brew list --formula "$pkg" >/dev/null 2>&1; then
    skip "$pkg"
  elif brew install "$pkg"; then
    ok "$pkg installed"
  else
    fail "brew install $pkg"
  fi
done

# ---------------------------------------------------------------------------
# 3. Brew casks (apps)
# ---------------------------------------------------------------------------

info "Apps"
for entry in "${BREW_CASKS[@]}"; do
  cask="${entry%%:*}"
  app="${entry#*:}"
  if [[ -d "/Applications/$app" || -d "$HOME/Applications/$app" ]] \
     || brew list --cask "$cask" >/dev/null 2>&1; then
    skip "$cask"
  elif brew install --cask "$cask"; then
    ok "$cask installed"
  else
    fail "brew install --cask $cask"
  fi
done

# ---------------------------------------------------------------------------
# 4. Oh My Zsh (your .zshrc depends on it)
# ---------------------------------------------------------------------------

info "Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  skip "already installed"
elif RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended; then
  ok "Oh My Zsh installed"
else
  fail "Oh My Zsh install"
fi

# ---------------------------------------------------------------------------
# 5. Dotfiles (bare repo checked out into $HOME)
# ---------------------------------------------------------------------------

info "Dotfiles"
dotfiles_ok=true
fresh_clone=false

if [[ ! -d "$DOTFILES_DIR" ]]; then
  if git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"; then
    ok "Cloned into $DOTFILES_DIR"
    fresh_clone=true
  else
    fail "git clone $DOTFILES_REPO"
    dotfiles_ok=false
  fi
else
  skip "$DOTFILES_DIR already exists"
fi

if $dotfiles_ok; then
  # Works for a fresh clone AND for an earlier run that stopped halfway.
  # On a machine that's already set up this changes nothing.
  if dot checkout >/dev/null 2>&1; then
    ok "Files checked out into $HOME"
  else
    conflicts="$(dot checkout 2>&1 | grep -E '^[[:space:]]+' | awk '{print $1}')"
    if [[ -n "$conflicts" ]]; then
      warn "Backing up files the checkout would overwrite to $BACKUP_DIR"
      while read -r file; do
        [[ -z "$file" ]] && continue
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        mv "$HOME/$file" "$BACKUP_DIR/$file" && warn "  $file"
      done <<< "$conflicts"
    fi
    if dot checkout >/dev/null 2>&1; then
      ok "Files checked out into $HOME"
    else
      fail "dotfiles checkout (run: git --git-dir=$DOTFILES_DIR --work-tree=$HOME checkout)"
      dotfiles_ok=false
    fi
  fi

  # Existing setup: download new commits from GitHub and update files.
  # --ff-only refuses to overwrite local changes instead of clobbering them.
  if $dotfiles_ok && ! $fresh_clone; then
    branch="$(dot rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
    if dot fetch origin "$branch" >/dev/null 2>&1; then
      before="$(dot rev-parse HEAD)"
      if dot merge --ff-only FETCH_HEAD >/dev/null 2>&1; then
        if [[ "$before" == "$(dot rev-parse HEAD)" ]]; then
          skip "Dotfiles already up to date"
        else
          ok "Dotfiles updated to latest $branch"
        fi
      else
        fail "Dotfiles update: local changes or unpushed commits (check with: df status)"
      fi
    else
      fail "Could not fetch dotfiles from GitHub"
    fi
  fi

  # Don't list every file in $HOME as untracked in `df status`
  if [[ "$(dot config --get status.showUntrackedFiles 2>/dev/null)" != "no" ]]; then
    dot config status.showUntrackedFiles no
  fi
fi

# ---------------------------------------------------------------------------
# 6. npm packages (language servers + formatters)
# ---------------------------------------------------------------------------

info "npm packages"
if ! has npm; then
  fail "npm not found, skipped all npm packages"
else
  for entry in "${NPM_PACKAGES[@]}"; do
    pkg="${entry%%:*}"
    cmd="${entry#*:}"
    if has "$cmd" || npm ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
      skip "$pkg"
    elif npm install -g "$pkg" >/dev/null 2>&1; then
      ok "$pkg installed"
    else
      fail "npm install -g $pkg"
    fi
  done
fi

# ---------------------------------------------------------------------------
# 7. Go tools
# ---------------------------------------------------------------------------

info "Go tools"
if ! has go; then
  fail "go not found, skipped all Go tools"
else
  GOBIN="$(go env GOPATH)/bin"
  for entry in "${GO_PACKAGES[@]}"; do
    pkg="${entry%%:*}"
    cmd="${entry#*:}"
    if has "$cmd" || [[ -x "$GOBIN/$cmd" ]]; then
      skip "$cmd"
    elif go install "$pkg"; then
      ok "$cmd installed"
    else
      fail "go install $pkg"
    fi
  done

  if ! grep -qE 'go env GOPATH|go/bin' "$HOME/.zshrc" 2>/dev/null; then
    warn "Your .zshrc doesn't add $GOBIN to PATH, so gopls/goimports won't be found."
    warn "Add this to .zshrc (and commit it):"
    warn '  export PATH="$PATH:$(go env GOPATH)/bin"'
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo
if [[ ${#FAILED[@]} -eq 0 ]]; then
  info "All done! ($(nvim --version 2>/dev/null | head -n1))"
  echo
  echo "Next steps:"
  echo "  1. Open a new terminal (so .zshrc and PATH changes apply)"
  echo "  2. Run: neovide"
  echo "  3. Confirm the plugin install prompt, then restart Neovide"
  echo "  4. Check everything with :checkhealth vim.lsp"
else
  info "Finished with ${#FAILED[@]} problem(s):"
  for f in "${FAILED[@]}"; do
    printf "\033[1;31m  ✗\033[0m %s\n" "$f"
  done
  echo
  echo "Everything else is installed. Fix the items above and rerun this"
  echo "script; finished steps will be skipped."
  exit 1
fi
