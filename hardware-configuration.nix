# This is a minimal hardware-configuration.nix for testing purposes
{ lib, ... }:

{
  imports = [ ];

  # Basic filesystem configuration
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # Basic bootloader settings
  boot.loader.grub.device = lib.mkDefault "/dev/sda";
}