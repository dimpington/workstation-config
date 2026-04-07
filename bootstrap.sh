#!/usr/bin/env bash
set -e

DOTFILES_REPO="https://github.com/dimpington/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/config-backup"
WORKSTATION_DIR="$HOME/workstation-config"

backup_and_link() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/$(basename "$target").backup.$(date +%Y%m%d-%H%M%S)"
    echo "Backed up $target to $BACKUP_DIR"
  fi

  ln -sfn "$source" "$target"
  echo "Linked $target -> $source"
}

echo "== Starting workstation bootstrap =="

if ! command -v git >/dev/null 2>&1; then
  echo "== Git not found, installing =="
  sudo dnf install -y git
fi

if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "== Cloning dotfiles repository =="
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "== Dotfiles repo already exists at $DOTFILES_DIR =="
fi

echo "== Running setup script =="
cd "$WORKSTATION_DIR"
./setup.sh

echo "== Linking dotfiles =="
backup_and_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
backup_and_link "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
backup_and_link "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"

chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/config"

echo "== Bootstrap complete =="
echo "Next steps:"
echo "1. Log out and back in if needed"
echo "2. Restore personal files and SSH keys from backup"
echo "3. Test git, starship, podman, and virt-manager"
