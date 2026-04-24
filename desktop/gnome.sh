#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER="$(ls "$SCRIPT_DIR"/assets/wallpaper.* 2>/dev/null | head -n1 || true)"

echo "== Customizing GNOME desktop =="

# Set dark mode
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Set wallpaper
if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
  gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
else
  echo "Wallpaper not found in: $SCRIPT_DIR/assets/"
fi

# Set dock favorites
gsettings set org.gnome.shell favorite-apps "[
  'org.gnome.Nautilus.desktop',
  'org.gnome.Console.desktop',
  'code.desktop',
  'firefox.desktop'
]"

echo "== GNOME customization complete =="
