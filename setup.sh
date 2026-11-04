#!/usr/bin/env bash
set -euo pipefail

# Desktop environment selection
DESKTOP="gnome"

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
  gnome|hyprland|both)
    echo "== Selected desktop: $DESKTOP =="
    ;;
  *)
    echo "ERROR: Invalid desktop: $DESKTOP"
    echo "Valid options: gnome, hyprland, both"
    exit 1
    ;;
esac

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install selected desktop environment
if [[ "$DESKTOP" == "hyprland" || "$DESKTOP" == "both" ]]; then
    echo "== Installing Hyprland environment =="
    bash "$SCRIPT_DIR/desktop/hyprland.sh"
fi

if [[ -f "$SCRIPT_DIR/customize-desktop.sh" ]]; then
  echo "== Running desktop customization =="

  bash "$SCRIPT_DIR/customize-desktop.sh" --desktop "$DESKTOP"
else
  echo "ERROR: customize-desktop.sh not found"
  exit 1
fi

echo "== Setup complete =="
