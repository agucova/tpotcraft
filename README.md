# TPotCraft Server

A Docker-based Minecraft server for Better Minecraft 3 using Fabric, built with Nix.

## Features

- Built with Nix and Docker for easy deployment
- Minecraft 1.21 with Fabric 0.15.9
- Better Minecraft 3 modpack support
- Optimized JVM settings for performance

## Requirements

- Nix with flakes enabled
- Docker
- Unfree packages allowed (for Minecraft)

## Quick Start

Just run the provided setup script:

```bash
./run-server.sh
```

This will:
1. Install Nix and Docker if needed
2. Build the Docker image using Nix
3. Create a data directory with default settings
4. Download core mods (Fabric API and Fabric Language Kotlin)
5. Start the server

## Manual Setup

If you prefer to do things manually:

1. Build the Docker image:
   ```
   NIXPKGS_ALLOW_UNFREE=1 nix build .#docker-image --experimental-features "nix-command flakes" --impure
   ```

2. Load the image into Docker:
   ```
   docker load < result
   ```

3. Create data directory and start the server:
   ```
   mkdir -p minecraft-data
   docker compose up -d
   ```

## Managing the Server

- Start: `docker compose up -d`
- Stop: `docker compose down`
- Restart: `docker compose restart minecraft`
- Logs: `docker logs -f tpotcraft`
- Console: `docker attach tpotcraft` (detach with Ctrl+p, Ctrl+q)

## Server Properties

The server is configured with the following properties:

- Port: 25565
- Difficulty: Normal
- Gamemode: Survival
- Whitelist: Enabled
- Max Players: 10

You can modify these settings in the `minecraft-data/server.properties` file.

## Adding Better Minecraft 3 Mods

This setup includes only the core Fabric mods. To get the full Better Minecraft 3 experience:

1. Download the Better Minecraft 3 modpack from [Modrinth](https://modrinth.com/modpack/better-mc-fabric-bmc3)
2. Extract the mods and config files
3. Add them to the `minecraft-data/mods` and `minecraft-data/config` directories

## Data Location

All server data is stored in the `minecraft-data` directory, which is mounted as a volume in the Docker container:

- World data: `minecraft-data/world/`
- Mods: `minecraft-data/mods/`
- Config: `minecraft-data/config/`
- Logs: `minecraft-data/logs/`