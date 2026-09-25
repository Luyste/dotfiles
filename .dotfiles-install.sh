#!/usr/bin/env bash
#
# Bootstraps a new Mac with Luyste/dotfiles (bare repo) and the
# Neovim + Neovide setup.
#
# Run on a new machine with:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Luyste/dotfiles/main/.dotfiles-install.sh)
#
# Safe to run more than once: installed tools are skipped, and files
# that would be overwritten by the checkout are backed up first.

set -euo pipefail

DOTFILES_REPO="https://github.com/Luyste/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"

# ---------------------------------------------------------------------------
# Tool lists: edit these when you add or remove languages
# ---------------------------------------------------------------------------

BREW_FORMULAE=(
  git
  neovim
  node
  go
  fzf
  fd
  ripgrep
  lazygit             # used by the `lg` alias
  gh                  # used by .claude-helpers
  marksman            # Markdown LSP
  taplo               # TOML LSP + formatter
  lua-language-server
  stylua              # Lua formatter
)

BREW_CASKS=(
  neovide
  font-jetbrains-mono-nerd-font
)

NPM_PACKAGES=(
  typescript
  typescript-language-server
  vscode-langservers-extracted          # HTML, CSS, JSON, ESLint
  dockerfile-language-server-nodejs
  yaml-language-server
  @typespec/compiler                    # TypeSpec LSP + formatter
  prettier
  @fsouza/prettierd
)

GO_PACKAGES=(
  golang.org/x/tools/gopls@latest
  golang.org/x/tools/cmd/goimports@latest
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

info() { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
ok()   { printf "\033[1;32m  ✓\033[0m %s\n" "$1"; }
warn() { printf "\033[1;33m  !\033[0m %s\n" "$1"; }

dot() { git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"; }

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is written for macOS." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# 1. Homebrew
# ---------------------------------------------------------------------------

info "Checking Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  info "Installing Homebrew (asks for your password)"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
ok "Homebrew ready"

# ---------------------------------------------------------------------------
# 2. Brew packages
# ---------------------------------------------------------------------------

info "Installing command-line tools"
for pkg in "${BREW_FORMULAE[@]}"; do
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    ok "$pkg"
  else
    brew install "$pkg"
    ok "$pkg installed"
  fi
done

info "Installing apps and fonts"
for cask in "${BREW_CASKS[@]}"; do
  if brew list --cask "$cask" >/dev/null 2>&1; then
    ok "$cask"
  else
    brew install --cask "$cask"
    ok "$cask installed"
  fi
done

# ---------------------------------------------------------------------------
# 3. Oh My Zsh (your .zshrc depends on it)
# ---------------------------------------------------------------------------

info "Checking Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "Oh My Zsh"
else
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
  ok "Oh My Zsh installed"
fi

# ---------------------------------------------------------------------------
# 4. Dotfiles (bare repo checked out into $HOME)
# ---------------------------------------------------------------------------

info "Setting up dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
  ok "$DOTFILES_DIR already exists, pulling latest"
  dot pull --ff-only || warn "Could not pull (local changes?), leaving as is"
else
  git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"

  if ! dot checkout 2>/dev/null; then
    # Back up files the checkout would overwrite (e.g. a default .zshrc)
    warn "Backing up existing files to $BACKUP_DIR"
    dot checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | while read -r file; do
      mkdir -p "$BACKUP_DIR/$(dirname "$file")"
      mv "$HOME/$file" "$BACKUP_DIR/$file"
      warn "  $file"
    done
    dot checkout
  fi

  # Don't list every file in $HOME as untracked in `df status`
  dot config status.showUntrackedFiles no
  ok "Dotfiles checked out into $HOME"
fi

# ---------------------------------------------------------------------------
# 5. npm packages (language servers + formatters)
# ---------------------------------------------------------------------------

info "Installing npm packages"
npm install -g "${NPM_PACKAGES[@]}"
ok "npm packages installed"

# ---------------------------------------------------------------------------
# 6. Go tools
# ---------------------------------------------------------------------------

info "Installing Go tools"
for pkg in "${GO_PACKAGES[@]}"; do
  go install "$pkg"
  ok "${pkg%@*}"
done

GOBIN="$(go env GOPATH)/bin"
if ! grep -q "go env GOPATH\|go/bin" "$HOME/.zshrc" 2>/dev/null; then
  warn "Your .zshrc doesn't add $GOBIN to PATH, so gopls/goimports won't be found."
  warn "Add this to .zshrc (and commit it):"
  warn '  export PATH="$PATH:$(go env GOPATH)/bin"'
fi

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

info "Done! ($(nvim --version | head -n1))"
echo
echo "Next steps:"
echo "  1. Open a new terminal (so .zshrc and PATH changes apply)"
echo "  2. Run: neovide"
echo "  3. Confirm the plugin install prompt, then restart Neovide"
echo "  4. Check everything with :checkhealth vim.lsp"
