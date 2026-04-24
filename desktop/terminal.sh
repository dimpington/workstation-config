#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== Customizing terminal =="

# Kitty
mkdir -p "$HOME/.config/kitty"
cp "$SCRIPT_DIR/terminal/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Starship
mkdir -p "$HOME/.config"
cp "$SCRIPT_DIR/terminal/starship/starship.toml" "$HOME/.config/starship.toml"

# Zsh config
if [[ -f "$SCRIPT_DIR/terminal/zsh/.zshrc" ]]; then
  cp "$SCRIPT_DIR/terminal/zsh/.zshrc" "$HOME/.zshrc"
fi

# Set zsh as default shell
if command -v zsh >/dev/null 2>&1; then
  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
    echo "Default shell changed to zsh. Log out and back in for it to apply."
  fi
else
  echo "zsh is not installed. Skipping default shell change."
fi

echo "== Terminal customization complete =="
