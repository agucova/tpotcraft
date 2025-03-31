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
    
    servers.bm2 = {
      enable = true;
      autoStart = true;
      
      # Better Minecraft 2 uses Minecraft 1.20.1 with Fabric
      package = pkgs.fabricServers.fabric-1_20_1.override {
        loaderVersion = "0.15.6";
      };
      
      # Server settings
      jvmOpts = "-Xmx4G -Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1";
      
      serverProperties = {
        server-port = 25565;
        difficulty = "normal";
        gamemode = "survival";
        motd = "TPotCraft - Better Minecraft 2";
        white-list = true;
        spawn-protection = 0;
        max-players = 10;
      };
      
      # Essential mods for Better Minecraft 2
      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
          # Core mods
          Fabric-API = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar";
            hash = "sha256-LN3s65ZkdCUGKC0mJyPQxBxdzQzT9Yt34iiSR/d7Q+c=";
          };
          Fabric-Language-Kotlin = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/vMQSiIN6/fabric-language-kotlin-1.10.17%2Bkotlin.1.9.22.jar";
            hash = "sha256-/L/yGZouYL5dUzDJ5/FkfzTvRKH87dSuZN3B2bN/VoE=";
          };
          
          # Performance
          Lithium = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/ZSNsJrPI/lithium-fabric-mc1.20.1-0.11.2.jar";
            hash = "sha256-RWC7E8BdLTw0lQ3GGFY5s7OdC3gxfX3VwT1HS1K0T20=";
          };
          Starlight = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/H8CaAYZC/versions/1.1.2%2B1.20/starlight-1.1.2%2B1.20.jar";
            hash = "sha256-DXfz6UfE6AOJHyvTvKuqYudVXtIGhkjPptFgRVQQZOM=";
          };
          FerriteCore = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/uXXizFIs/versions/RbR7ADfF/ferritecore-6.0.0-fabric.jar";
            hash = "sha256-QJSt+QVU0JtNGk/ld0llwWcFfIqR94hMGlW98q8s9uc=";
          };
          LazyDFU = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.3/lazydfu-0.1.3.jar";
            hash = "sha256-M0MQRjr/0YxUpsblAKJU9RGnGTXeB0ojgJPxQUXLzag=";
          };
          EntityCulling = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/NNAgCjsB/versions/NwQcsoO4/entityculling-fabric-1.6.2-mc1.20.1.jar";
            hash = "sha256-V67UTRh4V/VnfTlO4a9uQx1OXDkZeA2xmYJQ/7cYn+8=";
          };
          Krypton = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/jiDwS0W1/krypton-0.2.3.jar";
            hash = "sha256-XmhI0lhkz/uVFnf/XjLkJjQYx5HX/c/XhMrz6Y7bK9Y=";
          };
          C2ME = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/VSNURh3q/versions/t4juSkze/c2me-fabric-mc1.20.1-0.2.0%2Balpha.10.91.jar";
            hash = "sha256-BMJ9sYCn9zv5W6bDLXfX1pHzwICLPZ9+8r/vS5m9rQI=";
          };
        });
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
}