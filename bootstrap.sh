#!/usr/bin/env bash
set -e

REPO_DIR="$HOME/workstation-config"
DOTFILES_DIR="$HOME/dotfiles"

backup_and_link() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    local backup_dir="$HOME/config-backup"
    mkdir -p "$backup_dir"
    mv "$target" "$backup_dir/$(basename "$target").backup.$(date +%Y%m%d-%H%M%S)"
    echo "Backed up $target to $backup_dir"
  fi

  ln -sfn "$source" "$target"
  echo "Linked $target -> $source"
}

echo "== Starting workstation bootstrap =="

cd "$REPO_DIR"

echo "== Running setup script =="
./setup.sh

echo "== Linking dotfiles =="
backup_and_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
backup_and_link "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
backup_and_link "$DOTFILES_DIR/.ssh/config" "$HOME/.ssh/config"

chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/config"

echo "== Bootstrap complete =="
echo "Log out and back in if needed, then restore personal data and SSH keys from backup."
