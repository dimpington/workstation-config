#!/usr/bin/env bash
set -e

DOTFILES_REPO="git@github.com:dimpington/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/config-backup"
WORKSTATION_DIR="$HOME/workstation-config"

# -------------------------
# SSH Key Check
# -------------------------
if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
  echo "SSH key not found."
  echo "Generate one with:"
  echo "  ssh-keygen -t ed25519 -C \edaunfelt@protonmail.com\""
  echo "Then add it to GitHub before running bootstrap."
  exit 1
fi

backup_and_link() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/$(basename "$target").backup.$(date +%Y%m%d-%H%M%S)"
    echo "Backed up $target to $BACKUP_DIR"
  fi

  ln -sfn "$source" "$target"
  echo "Linked $target -> $source"
}

install_vscode() {
  echo "== Installing VS Code repository =="
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

  sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

  echo "== Installing VS Code =="
  sudo dnf install -y code
}

install_core_packages() {
  echo "== Installing core packages =="
  sudo dnf install -y \
    git \
    curl \
    wget \
    zsh \
    podman
}

install_vscode_extensions() {
  echo "== Installing VS Code extensions =="

  local extensions=(
    ms-azuretools.vscode-containers
    ms-azuretools.vscode-docker
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
    ms-vscode-remote.remote-containers
    ms-vscode.remote-explorer
    redhat.vscode-yaml
  )

  for ext in "${extensions[@]}"; do
    code --install-extension "$ext" || true
  done
}

echo "== Starting workstation bootstrap =="

install_core_packages
install_vscode

if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "== Cloning dotfiles repository =="
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "== Dotfiles repo already exists at $DOTFILES_DIR =="
fi

echo "== Running setup script =="
cd "$WORKSTATION_DIR"
./setup.sh

echo "== Linking dotfiles =="
backup_and_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

mkdir -p "$HOME/.config"

if [ -f "$DOTFILES_DIR/.config/starship.toml" ]; then
  backup_and_link "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
fi

install_vscode_extensions

echo "== Bootstrap complete =="
