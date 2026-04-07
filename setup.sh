#!/usr/bin/env bash
set -e

echo "== Updating system =="
sudo dnf update -y

echo "== Installing DNF packages from packages-base.txt =="
sudo dnf install -y $(grep -vE '^\s*$|^\s*#' packages-base.txt)

echo "== Ensuring Flathub is configured =="
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if [ -s flatpaks.txt ]; then
  echo "== Installing Flatpak apps from flatpaks.txt =="
  flatpak install -y flathub $(cat flatpaks.txt)
else
  echo "== No Flatpak apps listed, skipping =="
fi

echo "== Setup complete =="
