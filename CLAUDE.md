# TPotCraft Server Repository Guidelines

## Build & Test Commands
- `nix build` - Build the NixOS system configuration
- `nix flake check` - Verify flake outputs
- `nix develop` - Enter development shell
- `systemctl start minecraft-servers-bm2` - Start Minecraft server
- `systemctl status minecraft-servers-bm2` - Check server status
- `tmux -S /run/minecraft/bm2.sock attach` - Connect to server console (detach with Ctrl+b, d)

## Server Management
- Minecraft server data is stored in `/srv/minecraft/`
- Server console available at `/run/minecraft/bm2.sock`
- Edit configurations in `configuration.nix` and `modpack.nix`
- After changes, rebuild with `nixos-rebuild switch --flake .`

## Code Style Guidelines
- Follow the Nix language style with 2-space indentation
- Use Nix expressions for generating configurations
- Store secrets in environment files, not in Nix code
- Use explicit version pinning for stability
- Name servers, mods, and packages descriptively
- Reference package sources from `nix-minecraft` where possible
- For modpacks, use `pkgs.fetchPackwizModpack` or explicitly define server packs
- Document all significant configurations
- Comment complex JVM options