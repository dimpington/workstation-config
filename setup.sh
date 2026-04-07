#!/usr/bin/env bash
set -e

echo "== Updating system =="
sudo dnf update -y

echo "== Installing DNF packages from packages-base.txt =="
sudo dnf install -y $(grep -vE '^\s*$|^\s*#' packages-base.txt)

echo "== Ensuring libvirtd is enabled =="
sudo systemctl enable --now libvirtd

echo "== Ensuring Flathub is configured =="
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if [ -s flatpaks.txt ]; then
  echo "== Installing Flatpak apps from flatpaks.txt =="
  flatpak install -y flathub $(cat flatpaks.txt)
else
  echo "== No Flatpak apps listed, skipping =="
fi

if ! command -v starship >/dev/null 2>&1; then
  echo "== Installing Starship =="
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo "== Starship already installed, skipping =="
fi

if ! grep -q 'eval "$(starship init zsh)"' ~/.zshrc 2>/dev/null; then
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc
  echo "== Added Starship init to ~/.zshrc =="
else
  echo "== Starship init already present in ~/.zshrc, skipping =="
fi

echo "== Setup complete =="
