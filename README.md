# TPotCraft Server

A NixOS-based Minecraft server for Better Minecraft 3 using Fabric.

## Features

- Declarative configuration using NixOS and Flakes
- Minecraft 1.21 with Fabric 0.15.9
- Better Minecraft 3 modpack support
- Optimized JVM settings for performance

## Requirements

- NixOS or Nix with flakes enabled
- Unfree packages allowed (for Minecraft)

## Setup

1. Clone this repository
2. Generate a hardware configuration for your target system:
   ```
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```
3. Build and deploy to your system:
   ```
   sudo nixos-rebuild switch --flake .
   ```

## Managing the Server

Once deployed, the server will be available as a systemd service:

- Start: `sudo systemctl start minecraft-servers-bm3`
- Stop: `sudo systemctl stop minecraft-servers-bm3`
- Restart: `sudo systemctl restart minecraft-servers-bm3`
- Status: `sudo systemctl status minecraft-servers-bm3`
- Logs: `sudo journalctl -u minecraft-servers-bm3 -f`
- Console: `sudo tmux -S /run/minecraft/bm3.sock attach` (detach with Ctrl+b, d)

## Server Properties

The server is configured with the following properties:

- Port: 25565
- Difficulty: Normal
- Gamemode: Survival
- Whitelist: Enabled
- Max Players: 10

## Adding Mods and Customization

This configuration includes the core Fabric mods required for Better Minecraft 3. You can add additional mods by:

1. Finding the mod on Modrinth
2. Getting the download URL and hash
3. Adding it to the `symlinks.mods` section in `configuration.nix`

Example:
```nix
Lithium = pkgs.fetchurl {
  url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/ZSNsJrPI/lithium-fabric-mc1.20.1-0.11.2.jar";
  hash = "sha256-RWC7E8BdLTw0lQ3GGFY5s7OdC3gxfX3VwT1HS1K0T20=";
};
```

You can also add config files, resource packs, and other customizations using the `symlinks` or `files` options in the configuration.

## Directory Structure

Server data is stored in the following locations:

- Server files: `/srv/minecraft/bm3/`
- World data: `/srv/minecraft/bm3/world/`
- Logs: `/srv/minecraft/bm3/logs/`
- Mods: `/srv/minecraft/bm3/mods/`
- Config: `/srv/minecraft/bm3/config/`