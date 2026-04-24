#!/usr/bin/env bash
set -euo pipefail

echo "== Running desktop customization =="

./desktop/gnome.sh
./desktop/vscode.sh
./desktop/terminal.sh

echo "== Desktop customization complete =="
