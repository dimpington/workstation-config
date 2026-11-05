#!/usr/bin/env bash
set -euo pipefail

echo "== Configuring terminal environment =="

# Terminal configuration files are managed by the dotfiles repository.
# bootstrap.sh links Kitty, Starship, and Zsh configuration.

# Set Zsh as the default shell
if command -v zsh >/dev/null 2>&1; then
  ZSH_PATH="$(command -v zsh)"

  if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH"
    echo "Default shell changed to Zsh. Log out and back in for it to apply."
  fi
else
  echo "Zsh is not installed. Skipping default shell change."
fi

echo "== Terminal environment configured =="
