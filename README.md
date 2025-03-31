# TPotCraft Server

A NixOS-based Minecraft server running the Better Minecraft 2 modpack using Fabric.

## Features

- Declarative configuration using NixOS and Flakes
- Better Minecraft 2 essentials (1.20.1) 
- Server configuration with optimized JVM options
- Performance-optimized mods included
- Docker and VM support for running locally

## Running Locally on Ubuntu

You have two options for running the server locally on your Ubuntu machine:

### Option 1: Docker (Recommended)

1. Make sure you have Docker and Docker Compose installed:
   ```
   sudo apt update
   sudo apt install docker.io docker-compose
   ```

2. Install Nix (if not already installed):
   ```
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

3. Enable Flakes:
   ```
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

4. Build the Docker image:
   ```
   nix build .#dockerImage
   ```

5. Load the image into Docker:
   ```
   docker load < result
   ```

6. Create a data directory and start the server:
   ```
   mkdir -p minecraft-data
   docker-compose up -d
   ```

7. The server will be available at localhost:25565

### Option 2: VM with QEMU

1. Install Nix and enable Flakes (see above)

2. Install QEMU:
   ```
   sudo apt install qemu-kvm qemu-system-x86
   ```

3. Create a data directory:
   ```
   mkdir -p ~/tpotcraft-data
   ```

4. Build and run the VM:
   ```
   nix build .#vm
   ./result/bin/run-tpotcraft-vm
   ```

5. The VM will boot with the Minecraft server accessible at localhost:25565

## Mod Management

Essential mods for Better Minecraft 2 are included directly in the configuration. To add more mods:

1. Find the mod on Modrinth or CurseForge
2. Use the nix-modrinth-prefetch tool to get the fetchurl expression:
   ```
   nix run github:Infinidoge/nix-minecraft#nix-modrinth-prefetch -- <version-id>
   ```
   Where `<version-id>` is the ID found on the mod's version page
3. Add the fetchurl expression to the mods section in either:
   - `configuration.nix` for NixOS systems
   - `vm-configuration.nix` for VM deployment
   - `flake.nix` in the dockerImage section for Docker deployment

## Server Management

### For Docker:
- Logs: `docker logs -f tpotcraft`
- Console: `docker attach tpotcraft` (detach with Ctrl+p, Ctrl+q)
- Stop: `docker-compose down`

### For VM:
- Login with username `minecraft` and password `minecraft`
- The server will autostart
- Console: `sudo tmux -S /run/minecraft/bm2.sock attach` (detach with Ctrl+b, d)
- Service management: `sudo systemctl {start|stop|restart} minecraft-servers-bm2`

## Server Properties

The server is configured with the following properties:

- Port: 25565
- Difficulty: Normal
- Gamemode: Survival
- Whitelist: Enabled
- Max Players: 10

You can modify these settings in the configuration files.