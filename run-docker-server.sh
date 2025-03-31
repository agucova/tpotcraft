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

# Create data directory if it doesn't exist
mkdir -p minecraft-data

# Build the Docker image and start the server
echo "Building Docker image and starting Minecraft server..."
if groups | grep -q '\bdocker\b'; then
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
echo "==================================="