#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== Setting up VS Code =="

if ! command -v code >/dev/null 2>&1; then
  echo "VS Code is not installed. Skipping VS Code customization."
  exit 0
fi

while read -r extension; do
  [[ -z "$extension" || "$extension" =~ ^# ]] && continue
  code --install-extension "$extension" --force
done < "$SCRIPT_DIR/vscode-extensions.txt"

mkdir -p "$HOME/.config/Code/User"
cp "$SCRIPT_DIR/vscode/settings.json" "$HOME/.config/Code/User/settings.json"

echo "== VS Code setup complete =="
