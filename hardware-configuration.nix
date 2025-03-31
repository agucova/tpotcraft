# Example hardware-configuration.nix
# Replace this with your actual hardware configuration
# Generate with: nixos-generate-config --show-hardware-config > hardware-configuration.nix
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ];

  # Example filesystem configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # This is a placeholder file - replace with your real hardware configuration
  boot.loader.grub.device = lib.mkDefault "/dev/sda";
}