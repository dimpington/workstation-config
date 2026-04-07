# Workstation Config

This repository contains the rebuild logic for my Fedora workstation.

It is designed to work together with my separate `dotfiles` repository:

- Dotfiles repo: personal configuration files
- Workstation-config repo: package lists, setup script, bootstrap logic

## Purpose

The goal is to rebuild a fresh Fedora workstation quickly and predictably:

1. Install Fedora
2. Update the system
3. Install Git
4. Clone this repository
5. Run the bootstrap script
6. Restore personal files and SSH keys from backup

## First boot on a fresh Fedora install

Run these commands:

```bash
sudo dnf update -y
sudo dnf install -y git
git clone https://github.com/dimpington/workstation-config.git ~/workstation-config
cd ~/workstation-config
./bootstrap.sh
```

## After bootstrap

After the bootstrap completes:

1. Log out and back in if needed
2. Restore personal files from backup
3. Restore private SSH keys securely

## Test your environment:

```bash
git --version
starship --version
podman --version
virt-manager
```

## Repository contents

- `packages-base.txt` — curated DNF package list for rebuilds  
- `packages.txt` — raw package export from the current machine  
- `flatpaks.txt` — Flatpak app list  
- `setup.sh` — installs packages and base tooling  
- `bootstrap.sh` — full bootstrap flow including dotfiles linking  

