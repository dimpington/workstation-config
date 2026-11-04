#!/usr/bin/env bash
set -euo pipefail

# Desktop selection (default: GNOME)
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
    exit 1
    ;;
esac

DOTFILES_REPO="git@github.com:dimpington/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
# Select matching dotfiles branch for desktop profile
DOTFILES_BRANCH="main"
if [[ "$DESKTOP" == "hyprland" || "$DESKTOP" == "both" ]]; then
  DOTFILES_BRANCH="feature/fedora45-hyprland"
fi
BACKUP_DIR="$HOME/config-backup"
# Locate this repository automatically
WORKSTATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/workstation-logs"
LOG_FILE="$LOG_DIR/bootstrap-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "== Starting workstation bootstrap =="
echo "== Log file: $LOG_FILE =="

# -------------------------
# SSH Key Check
# -------------------------
if [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
  echo "SSH key not found or not configured."
  echo "Follow README SSH setup before running bootstrap."
  exit 1
fi


backup_and_link() {
  local source="$1"
  local target="$2"

  # Verify source exists
  if [[ ! -e "$source" ]]; then
    echo "ERROR: Dotfile source does not exist: $source"
    return 1
  fi

  mkdir -p "$(dirname "$target")"

  # Already linked correctly
  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    echo "Already linked: $target"
    return 0
  fi

  # Back up existing files, directories, or symlinks
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"

    local backup_path
    backup_path="$BACKUP_DIR/$(basename "$target").backup.$(date +%Y%m%d-%H%M%S)-$$"

    mv -- "$target" "$backup_path"
    echo "Backed up $target to $backup_path"
  fi

  # Create the symlink
  ln -s -- "$source" "$target"
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
    flatpak
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

install_core_packages
install_vscode

if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "== Cloning dotfiles branch: $DOTFILES_BRANCH =="
  git clone --branch "$DOTFILES_BRANCH" \
    "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "== Dotfiles repository already exists =="

  CURRENT_BRANCH="$(git -C "$DOTFILES_DIR" branch --show-current)"

  if [[ "$CURRENT_BRANCH" != "$DOTFILES_BRANCH" ]]; then
    echo "ERROR: Expected dotfiles branch $DOTFILES_BRANCH"
    echo "Found: $CURRENT_BRANCH"
    echo "Please switch branches manually after saving local changes."
    exit 1
  fi
fi


# Run workstation setup
echo "== Running setup.sh for desktop: $DESKTOP =="
cd "$WORKSTATION_DIR"
bash ./setup.sh --desktop "$DESKTOP"

# Link personal dotfiles
echo "== Linking dotfiles =="
backup_and_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
backup_and_link "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# Ensure configuration directory exists
mkdir -p "$HOME/.config"

# Link Hyprland desktop configurations
if [[ "$DESKTOP" == "hyprland" || "$DESKTOP" == "both" ]]; then
  echo "== Linking Hyprland desktop configuration =="

  for component in hypr waybar kitty fuzzel; do
    source_dir="$DOTFILES_DIR/.config/$component"
    target_dir="$HOME/.config/$component"

    if [[ ! -d "$source_dir" ]]; then
      echo "ERROR: Missing configuration directory: $source_dir"
      exit 1
    fi

    backup_and_link "$source_dir" "$target_dir"
  done
fi

# Link Starship configuration
if [ -f "$DOTFILES_DIR/.config/starship.toml" ]; then
  backup_and_link "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
fi

install_vscode_extensions

echo "== Bootstrap complete =="
echo "== See log: $LOG_FILE =="