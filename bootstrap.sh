#!/usr/bin/env bash
set -e

REPO_DIR="$HOME/workstation-config"
DOTFILES_REPO_URL="https://github.com/dimpington/dotfiles.git"

echo "== Starting workstation bootstrap =="

if [ ! -d "$REPO_DIR" ]; then
  echo "== Cloning workstation-config repository =="
  git clone "$(pwd)" "$REPO_DIR"
else
  echo "== workstation-config already exists at $REPO_DIR =="
fi

if [ ! -d "$HOME/dotfiles" ]; then
  echo "== Cloning dotfiles repository =="
  git clone "$DOTFILES_REPO_URL" "$HOME/dotfiles"
else
  echo "== dotfiles already exist at $HOME/dotfiles =="
fi

echo "== Running setup script =="
cd "$REPO_DIR"
./setup.sh

echo "== Bootstrap complete =="
echo "Next steps:"
echo "1. Review dotfiles placement/symlinks"
echo "2. Log out and back in if shell changes were applied"
echo "3. Restore personal data and SSH keys from backup"
