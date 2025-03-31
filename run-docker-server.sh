#!/bin/bash

set -e

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker and Docker Compose..."
    sudo apt update
    sudo apt install -y docker.io docker-compose
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    echo "Added user to docker group. You may need to log out and back in for this to take effect."
    echo "For now, we'll use sudo to run docker commands."
fi

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "Nix not found. Installing..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
    
    # Source nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    
    # Enable flakes
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Build the Docker image
echo "Building Docker image with Nix..."
NIXPKGS_ALLOW_UNFREE=1 nix build .#dockerImage --experimental-features "nix-command flakes" --impure

# Load the image into Docker
echo "Loading Docker image..."
if command -v docker &> /dev/null && groups | grep -q '\bdocker\b'; then
    docker load < result
else
    sudo docker load < result
fi

# Create data directory if it doesn't exist
mkdir -p minecraft-data

# Start the server
echo "Starting Minecraft server..."
if command -v docker-compose &> /dev/null && groups | grep -q '\bdocker\b'; then
    docker-compose up -d
else
    sudo docker-compose up -d
fi

echo ""
echo "==================================="
echo "TPotCraft server is running!"
echo "- Connect to the server at: localhost:25565"
echo "- View logs with: docker logs -f tpotcraft"
echo "- Access console with: docker attach tpotcraft (detach with Ctrl+p, Ctrl+q)"
echo "- Stop the server with: docker-compose down"
echo ""
echo "IMPORTANT: You still need to download the Better Minecraft 2 modpack files"
echo "and put them in the minecraft-data/mods and minecraft-data/config directories"
echo "==================================="