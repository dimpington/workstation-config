# Workstation Config

This repository contains the rebuild logic for my Fedora workstation.

It is designed to work together with my separate `dotfiles` repository:

- **Dotfiles:** personal configuration files
- **Workstation-config:** system setup, bootstrap logic, package installation, and desktop customization

---

## Purpose

The goal is to rebuild a fresh Fedora workstation quickly, reproducibly, and predictably.

The system is designed so that:

- The host system remains minimal
- Configuration is version controlled
- The machine can be rebuilt from scratch with minimal manual setup
- The desktop environment is reproducible

---

## Architecture

The setup is split into layers:

- `bootstrap.sh` — system bootstrap and dotfiles linking
- `setup.sh` — package installation
- `customize-desktop.sh` — GNOME, VS Code, and terminal customization

---

## Prerequisites

The tested environment is **Fedora 45 Workstation with GNOME**, an internet connection, and a user account with `sudo` privileges. Other Fedora releases and desktop environments have not yet been validated.

GitHub SSH authentication must be configured before cloning the repositories.

1. Generate an SSH key if you do not already have one:

   ```bash
   ssh-keygen -t ed25519 -C "your@email.com"
   ```

   Accept the default key location and choose a strong passphrase.

2. Start the SSH agent and add the key:

   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   ```

3. Add the public key to GitHub under **Settings → SSH and GPG keys → New SSH key**. Display the public key with:

   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

4. Verify GitHub SSH authentication:

   ```bash
   ssh -T git@github.com
   ```

   GitHub should confirm successful authentication, while noting that it does not provide shell access.

The SSH agent setup above applies to the current session. Persistent agent configuration is optional and depends on the desktop's existing SSH agent integration.

## Installation

The `workstation-config` repository must be cloned before its bootstrap script can run. The bootstrap script then retrieves the matching `dotfiles` branch automatically.

For the **current development branch**, run:

```bash
sudo dnf update -y
sudo dnf install -y git

git clone --branch feature/fedora45-hyprland \
  git@github.com:dimpington/workstation-config.git ~/workstation-config

cd ~/workstation-config
bash ./bootstrap.sh
```

**Do not run the entire bootstrap script with `sudo`.** Run it as your normal user.

### Password prompts

The installation is not completely unattended. Expect password prompts for operations that require `sudo`, including package installation and system configuration. Some commands may also request confirmation.

### After installation

**Log out of GNOME and log back in** after the bootstrap completes. This allows session-dependent changes, especially the default Zsh login shell, to take effect. A full reboot is normally unnecessary.

Kitty reads its linked configuration when a new Kitty process starts; Kitty itself does not normally require a logout. Starship configuration is likewise managed through dotfiles.

---

## What bootstrap does

### Core system setup

Installs core packages, including:

- Git, curl, and wget
- Zsh and Starship
- Kitty terminal
- Podman and virtualization tools

### Development environment

Installs Visual Studio Code from the Microsoft repository and configures extensions, including:

- Remote SSH
- Dev Containers and container tooling
- YAML
- Terraform
- Ansible
- Fallout Pip-Boy theme

### Configuration

Clones the `dotfiles` repository and links configuration files when present:

- `~/.zshrc`
- `~/.gitconfig`
- `~/.config/starship.toml`
- `~/.config/kitty`

### Desktop customization

`customize-desktop.sh` invokes the GNOME, VS Code, and terminal configuration scripts.

#### GNOME customization

Automated by `desktop/gnome.sh`:

- Dark mode
- Wallpaper
- Dock favorites

Wallpaper assets are stored under `desktop/assets/`.

#### VS Code customization

Automated by `desktop/vscode.sh`:

- Installs extensions listed in `desktop/vscode-extensions.txt`
- Copies `desktop/vscode/settings.json` into `~/.config/Code/User/settings.json`
- Configures the Fallout Pip-Boy theme, editor preferences, and Zsh integrated terminal profile

**Important:** The current script overwrites the existing VS Code user `settings.json`. Back up your settings before running it on a workstation with an existing VS Code configuration.

The theme's configuration value must be its registered name:

```json
"workbench.colorTheme": "fallout-pipboy-theme"
```

The display name **Fallout Pip-Boy Theme** is not the correct value for this setting. This was identified during the Fedora 45 installation test.

#### Terminal customization

`desktop/terminal.sh` sets Zsh as the default login shell. Kitty, Starship, and Zsh configuration files are maintained in the separate `dotfiles` repository and linked by `bootstrap.sh`.

---

## Prompt configuration

The shell prompt is powered by Starship.

- Active configuration: `~/.config/starship.toml`
- Source in dotfiles: `dotfiles/.config/starship.toml`

The configuration is linked during bootstrap when present.

## Post-installation verification

After logging back in, check the installed tools:

```bash
git --version
starship --version
kitty --version
zsh --version
podman --version
code --version
```

Check the installed VS Code extensions and user settings:

```bash
code --list-extensions
cat ~/.config/Code/User/settings.json
```

Check that dotfiles links point to the intended configuration:

```bash
ls -l ~/.zshrc ~/.gitconfig ~/.config/starship.toml ~/.config/kitty
```

Finally, open VS Code and confirm that the Fallout Pip-Boy theme is active. Restore personal files if needed.

---

## Design principles

- Reproducible setup
- Minimal host system
- Configuration stored in Git
- Development environment isolated where practical (containers)
- Automated GNOME desktop configuration