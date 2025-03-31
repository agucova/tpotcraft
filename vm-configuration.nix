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
            sha512 = "e5f3c3431b96b281300dd118ee523379ff6a774c0e864eab8d159af32e5425c915f8664b1";
          };
          Fabric-Language-Kotlin = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/vMQSiIN6/fabric-language-kotlin-1.10.17%2Bkotlin.1.9.22.jar";
            sha512 = "5046b5acbf40e9c9c05c6edfc2e8b7e33d4603f465a16c4754cf0a575944b7acda5fcbe8d9abd456df7a9cd67a6dbc5c9bee1f7e9875a4f631c9d3b8df7d4d95";
          };
          
          # Performance
          Lithium = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/ZSNsJrPI/lithium-fabric-mc1.20.1-0.11.2.jar";
            sha512 = "d1b5c90ba8b4879814df7fbf6e67412febbb2870e8131858c211130e9b5546e86b213b768b912fc7a2efa37831ad91caf28d6d71ba972274618ffd59937e5d0d";
          };
          Starlight = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/H8CaAYZC/versions/1.1.2%2B1.20/starlight-1.1.2%2B1.20.jar";
            sha512 = "8b60c03eec2d4c8bb9f33ff40794b53cf8aa5d01c45b1f4c5780db3a522f3e9b6e214ae71a9e8e851f24b8d0ac9021879196145fd27d1119c8ed8c728fb62d41";
          };
          FerriteCore = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/uXXizFIs/versions/RbR7ADfF/ferritecore-6.0.0-fabric.jar";
            sha512 = "9217e97c93701cd25422b06a8708cfb386a6a1b9157229c40931598bd07dfd21fb1a6adba21c5fd1627a40bff0bf05941a24213d9bd90bb2c175608eb199f588";
          };
          LazyDFU = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/hvFnDODi/versions/0.1.3/lazydfu-0.1.3.jar";
            sha512 = "dc3766352c645f6da92b13000dffa80584ee58093c925c2154eb3c125a2b2f9a3af298202e2658b039c6ee41e81ca9a2e9d4b942561f7085239dd4421e0cce0a";
          };
          EntityCulling = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/NNAgCjsB/versions/NwQcsoO4/entityculling-fabric-1.6.2-mc1.20.1.jar";
            sha512 = "19100e28574b3f7e4b1e8fbf05a148656bb08ba62d69aea5b94edf4737cf16fd55a5e73ee8dc4671f04608d6c5ab0a6158b673b61c744bf93fe392fdc26ffb03";
          };
          Krypton = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/jiDwS0W1/krypton-0.2.3.jar";
            sha512 = "92b73a70737cfc1daebca211bd1525de7684b554be392714ee29cbd558f2a27a8bdda22accbe9176d6e531d74f9bf77798c28c3e8559c970f607422b6038bc9e";
          };
          C2ME = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/VSNURh3q/versions/t4juSkze/c2me-fabric-mc1.20.1-0.2.0%2Balpha.10.91.jar";
            sha512 = "562c87a50f380c6cd7312f90b957f369625b3cf5f948e7bee286cd8075694a7206af4d0c8447879daa7a3bfe217c5092a7847247f0098cb1f5417e41c678f0c1";
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