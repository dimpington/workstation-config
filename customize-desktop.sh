#!/usr/bin/env bash
set -euo pipefail

echo "== Running desktop customization =="

./desktop/gnome.sh
./desktop/vscode.sh
./desktop/terminal.sh

echo "== Desktop customization complete =="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Zsh config
cp "$SCRIPT_DIR/dotfiles/.zshrc" "$HOME/.zshrc"

if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
  chsh -s /usr/bin/zsh "$USER"
fi
