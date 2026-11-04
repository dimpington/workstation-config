
#!/usr/bin/env bash
set -euo pipefail

echo "== Fedora Hyprland installation =="

# Verify Fedora
if [[ ! -f /etc/fedora-release ]]; then
    echo "ERROR: This script requires Fedora."
    exit 1
fi

source /etc/os-release

echo "Detected: $PRETTY_NAME"

# Check Hyprland availability
echo "== Checking Hyprland package availability =="

if ! dnf repoquery --available hyprland \
    --qf '%{name} %{version} %{repoid}' 2>/dev/null; then
    echo "ERROR: Unable to query package repositories."
    exit 1
fi

if ! dnf repoquery --available hyprland \
    --qf '%{name}' 2>/dev/null | grep -qx hyprland; then
    echo "ERROR: Hyprland is not available."
    echo "A compatible Fedora 45 package source is required."
    echo "No third-party repositories have been enabled."
    exit 1
fi

# Install Hyprland
sudo dnf install -y hyprland

# Install supporting utilities
PACKAGES=(
    waybar
    kitty
    fuzzel
    mako
    grim
    slurp
    wl-clipboard
    brightnessctl
    playerctl
    pavucontrol
    xorg-x11-server-Xwayland
)

echo "== Installing desktop utilities =="

sudo dnf install -y "${PACKAGES[@]}"

# Check optional Hyprland components
OPTIONAL_PACKAGES=(
    hyprpaper
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
)

for package in "${OPTIONAL_PACKAGES[@]}"; do
    if dnf repoquery --available "$package" \
        --qf '%{name}' 2>/dev/null | grep -qx "$package"; then
        sudo dnf install -y "$package"
    else
        echo "WARNING: $package unavailable"
    fi
done

echo "== Hyprland packages installed =="
echo "Desktop configuration will be added separately."