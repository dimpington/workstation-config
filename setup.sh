#!/usr/bin/env bash
set -euo pipefail

PACKAGES_FILE="packages-base.txt"
FLATPAKS_FILE="flatpaks.txt"

echo "== Updating system =="
sudo dnf update -y

echo "== Installing DNF packages from $PACKAGES_FILE =="
mapfile -t dnf_packages < <(grep -vE '^\s*$|^\s*#' "$PACKAGES_FILE")

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
  mapfile -t flatpak_apps < <(grep -vE '^\s*$|^\s*#' "$FLATPAKS_FILE")

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
    bat
    kitty
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

echo "== Installed Flatpak apps =="
flatpak list || true

echo "== Setup complete =="
