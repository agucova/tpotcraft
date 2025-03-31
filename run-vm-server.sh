#!/bin/bash

set -e

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "Nix not found. Installing..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
    
    # Source nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
fi

# Enable flakes if not already enabled
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "Enabling Nix flakes..."
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Check if QEMU is installed
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "QEMU not found. Installing..."
    sudo apt update
    sudo apt install -y qemu-kvm qemu-system-x86
fi

# Create data directory if it doesn't exist
mkdir -p ~/tpotcraft-data

# Build the VM script
echo "Building VM script with Nix..."
nix build .#vm

# Make the script executable
chmod +x result/bin/run-tpotcraft-vm

echo "Starting the VM..."
echo "- The VM will boot with a graphical interface"
echo "- Login with username: minecraft, password: minecraft"
echo "- The Minecraft server will auto-start and be available at localhost:25565"
echo "- To access the server console in the VM: sudo tmux -S /run/minecraft/bm2.sock attach"

# Run the VM
./result/bin/run-tpotcraft-vm