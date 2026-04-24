# Workstation Config

This repository contains the rebuild logic for my Fedora workstation.

It is designed to work together with my separate `dotfiles` repository:

- Dotfiles repo: personal configuration files
- Workstation-config repo: system setup, bootstrap logic, package installation and desktop customization

---

## Purpose

The goal is to rebuild a fresh Fedora workstation quickly, reproducibly, and predictably.

The system is designed so that:
- The host system remains minimal
- Configuration is version controlled
- The machine can be rebuilt from scratch in minutes
- The desktop environment is fully reproducible

---

## Architecture

The setup is split into layers:

- bootstrap.sh           → system bootstrap
- setup.sh               → package installation
- customize-desktop.sh   → UI and UX customization

---

## Prerequisites

Before running the bootstrap script:

1. Generate a new SSH key:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
```
Press Enter to accept defaults (no passphrase).

2. Start the SSH agent:

```
eval "$(ssh-agent -s)"
```

3. Add SSH key to the agent:

```
ssh-add ~/.ssh/id_ed25519
```

4. Add the public key to GitHub:

Settings → SSH and GPG keys → New SSH key

5. Verify SSH access:

```bash
ssh -T git@github.com
```

6. (Optional) Add SSH key bash: 

```
echo 'eval "$(ssh-agent -s)"' >> ~/.bashrc
echo 'ssh-add ~/.ssh/id_ed25519' >> ~/.bashrc
```

## After Fedora installation (and prerequiesites)

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

Installs core packages:

- git
- curl
- wget
- zsh
- podman

### Development environment

Installs Visual Studio Code from Microsoft repository

Installs VS Code extensions:

- Remote SSH
- Dev Containers
- Docker
- YAML
- Terraform
- Ansible
- Tasteful fallout-inspired theme

### Configuration

Clones the dotfiles repository

Links configuration files:

- ~/.zshrc
- ~/.gitconfig
- ~/.config/starship.toml (if present)

### Desktop Customization

The system includes a dedicated customization layer:

- customize-desktop.sh
	- GNOME settings
	- VS Code configuration
	- Terminal theming

### GNOME Customization

Automated via:

- desktop/gnome.sh

Configures:

- Dark mode
- Wallpaper
- Dock favorites

Wallpaper is stored in:

**desktop/assets/wallpaper.**

### VS Code Customization

Automated via:

- desktop/vscode.sh

Includes:

- Extension installation
- Theme configuration (Fallout Pip-Boy)
- Editor settings

Configuration files:

- desktop/vscode/settings.json
- desktop/vscode-extensions.txt

### Terminal Customization

Automated via:
- desktop/terminal.sh

Includes:

- Kitty terminal theme (Pip-Boy style)
- Starship prompt configuration
- Git-aware prompt styling

Features:

- Visual git status indicators
- SSH session detection
- Container context awareness

## Prompt configuration

The shell prompt is powered by Starship.

Configuration file:

**~/.config/starship.tom**

This file is stored in the dotfiles repository and linked during bootstrap.

Managed via:

**desktop/terminal/starship/starship.toml**

## After bootstrap

After bootstrap completes:

1. Restart shell or log out and back in
2. Restore personal files (if needed)
3. Verify customization applied

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
- Fully automated desktop experience
