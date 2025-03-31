{
  description = "TPotCraft - Better Minecraft 3 server with Fabric";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = inputs@{ self, nixpkgs, nix-minecraft, ... }:
  {
    # NixOS system configuration
    nixosConfigurations.tpotcraft = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        nix-minecraft.nixosModules.minecraft-servers
        {
          nixpkgs.overlays = [ nix-minecraft.overlay ];
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  };
}