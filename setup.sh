#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGES_FILE="$SCRIPT_DIR/packages-base.txt"
FLATPAKS_FILE="$SCRIPT_DIR/flatpaks.txt"

echo "== Updating system =="
sudo dnf update -y

echo "== Installing DNF packages from $PACKAGES_FILE =="
mapfile -t dnf_packages < <(grep -vE '^[[:space:]]*($|#)' "$PACKAGES_FILE")

if [ "${#dnf_packages[@]}" -gt 0 ]; then
  sudo dnf install -y "${dnf_packages[@]}"
  echo "== DNF package installation finished =="
else
  echo "== No DNF packages listed, skipping =="
fi

echo "== Ensuring libvirtd is enabled =="
sudo systemctl enable --now libvirtd

if ! command -v flatpak >/dev/null 2>&1; then
  echo "== Installing Flatpak =="
  sudo dnf install -y flatpak
else
  echo "== Flatpak already installed =="
fi

echo "== Ensuring Flathub is configured =="
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if [ -s "$FLATPAKS_FILE" ]; then
  echo "== Installing Flatpak apps from $FLATPAKS_FILE =="
  mapfile -t flatpak_apps < <(grep -vE '^[[:space:]]*($|#)' "$FLATPAKS_FILE")

  if [ "${#flatpak_apps[@]}" -gt 0 ]; then
    flatpak install -y flathub "${flatpak_apps[@]}"
    echo "== Flatpak installation finished =="
  else
    echo "== No valid Flatpak entries found, skipping =="
  fi
else
  echo "== No Flatpak apps listed, skipping =="
fi

if ! command -v starship >/dev/null 2>&1; then
  echo "== Installing Starship =="
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo "== Starship already installed, skipping =="
fi

echo "== Installed Flatpak apps =="
flatpak list || true

echo "== Verifying installed commands =="

check_commands() {
  local missing=0
  local commands=(
    git
    curl
    wget
    htop
    btop
    fastfetch
    nvim
    tmux
    kitty
    bat
    podman
    virt-manager
    virsh
    qemu-system-x86_64
    flatpak
    code
  )

  for cmd in "${commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo "[OK] $cmd -> $(command -v "$cmd")"
    else
      echo "[MISSING] $cmd"
      missing=1
    fi
  done

  return "$missing"
}

check_commands || {
  echo "== One or more expected commands are missing =="
  exit 1
}

if [[ -f "$SCRIPT_DIR/customize-desktop.sh" ]]; then
  echo "== Running desktop customization =="

  bash "$SCRIPT_DIR/customize-desktop.sh"
else
  echo "ERROR: customize-desktop.sh not found"
  exit 1
fi

echo "== Setup complete =="
