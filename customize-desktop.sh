#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "== Customizing Poseidonet GNOME workstation =="

# GNOME desktop customization
bash "$SCRIPT_DIR/desktop/gnome.sh"

# Shared workstation customization
bash "$SCRIPT_DIR/desktop/vscode.sh"
bash "$SCRIPT_DIR/desktop/terminal.sh"

echo "== Desktop customization complete =="