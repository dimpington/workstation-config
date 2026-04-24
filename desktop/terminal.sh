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

echo "== Terminal customization complete =="
