#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default desktop
DESKTOP="gnome"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --desktop)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --desktop requires a value"
        exit 1
      fi
      DESKTOP="$2"
      shift 2
      ;;
    *)
      echo "ERROR: Unknown argument: $1"
      exit 1
      ;;
  esac
done

case "$DESKTOP" in
  gnome|hyprland|both) ;;
  *)
    echo "ERROR: Invalid desktop: $DESKTOP"
    exit 1
    ;;
esac

echo "== Customizing desktop: $DESKTOP =="

# Desktop-specific customization
case "$DESKTOP" in
  gnome)
    bash "$SCRIPT_DIR/desktop/gnome.sh"
    ;;
  hyprland)
    echo "== Hyprland customization not implemented yet =="
    ;;
  both)
    bash "$SCRIPT_DIR/desktop/gnome.sh"
    echo "== Hyprland customization not implemented yet =="
    ;;
esac

# Shared customization
bash "$SCRIPT_DIR/desktop/vscode.sh"
bash "$SCRIPT_DIR/desktop/terminal.sh"

# Zsh configuration
if [[ -f "$SCRIPT_DIR/dotfiles/.zshrc" ]]; then
  cp "$SCRIPT_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
else
  echo "WARNING: Local .zshrc not found; skipping copy"
fi

# Set Zsh as default shell
ZSH_PATH="$(command -v zsh || true)"

if [[ -n "$ZSH_PATH" && "$SHELL" != "$ZSH_PATH" ]]; then
  chsh -s "$ZSH_PATH" "$USER"
fi

echo "== Desktop customization complete =="