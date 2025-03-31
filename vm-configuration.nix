{ lib, modulesPath, pkgs, ... }:

{
  imports = [
    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking = {
    hostName = "tpotcraft";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 25565 ]; # SSH and Minecraft
    };
  };

  # Users
  users.users.minecraft = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "minecraft";
  };

  # Enable SSH
  services.openssh.enable = true;

  # Mount the shared folder
  fileSystems."/srv/minecraft" = {
    device = "data";
    fsType = "9p";
    options = [ "trans=virtio" "version=9p2000.L" "msize=104857600" ];
  };

  # Minecraft server
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    dataDir = "/srv/minecraft";
    
    servers.bm3 = {
      enable = true;
      autoStart = true;
      
      # Better Minecraft 3 uses Minecraft 1.21 with Fabric
      package = pkgs.fabricServers.fabric-1_21.override {
        loaderVersion = "0.15.9";
      };
      
      # Server settings
      jvmOpts = "-Xmx4G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
      
      serverProperties = {
        server-port = 25565;
        difficulty = "normal";
        gamemode = "survival";
        motd = "TPotCraft - Better Minecraft 3";
        white-list = true;
        spawn-protection = 0;
        max-players = 10;
      };
    };
  };

  # Packages
  environment.systemPackages = with pkgs; [
    vim
    htop
    git
    tmux
    wget
    unzip
  ];

  system.stateVersion = "23.11";
  
  # Allow unfree packages (required for Minecraft)
  nixpkgs.config.allowUnfree = true;
}