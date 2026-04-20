# Workstation Config

This repository contains the rebuild logic for my Fedora workstation.

It is designed to work together with my separate `dotfiles` repository:

- Dotfiles repo: personal configuration files
- Workstation-config repo: system setup, bootstrap logic, package installation

---

## Purpose

The goal is to rebuild a fresh Fedora workstation quickly, reproducibly, and predictably.

The system is designed so that:
- The host system remains minimal
- Configuration is version controlled
- The machine can be rebuilt from scratch in minutes

---

## Prerequisites

Before running the bootstrap script:

1. Generate a new SSH key:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```

2. Add the public key to GitHub
3. Verify SSH access:

```bash
ssh -T git@github.com
```

## First boot on a fresh Fedora install

Run these commands:

```bash
sudo dnf update -y
sudo dnf install -y git

git clone git@github.com:dimpington/workstation-config.git ~/workstation-config
cd ~/workstation-config

./bootstrap.sh
```

##  What bootstrap does

### Core system setup

- Installs core packages:
	- git
	- curl
	- wget
	- zsh
	- podman

### Development environment

- Installs Visual Studio Code from Microsoft repository
- Installs VS Code extensions:
	- Remote SSH
	- Dev Containers
	- Docker
	- YAML

### Configuration

- Clones the dotfiles repository
- Links configuration files:
	- ~/.zshrc
	- ~/.gitconfig
	- ~/.config/starship.toml (if present)

## Prompt configuration

The shell prompt is powered by Starship.

Configuration file:

**~/.config/starship.tom**

This file is stored in the dotfiles repository and linked during bootstrap.

## After bootstrap

After bootstrap completes:

1. Restart shell or log out and back in
2. Restore personal files (if needed)

## Test your environment

```bash
git --version
starship --version
podman --version
code --version
```

## Design principles
- Reproducible setup
- Minimal host system
- Configuration stored in Git
- Development environment isolated (containers)
