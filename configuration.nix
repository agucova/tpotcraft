{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Minecraft server settings
  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.bm3 = {
      enable = true;

      # Specify the custom minecraft server package
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

      # Core mods needed for Better Minecraft 3
      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Fabric-API = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar";
              hash = "sha256-LN3s65ZkdCUGKC0mJyPQxBxdzQzT9Yt34iiSR/d7Q+c=";
            };
            Fabric-Language-Kotlin = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/vMQSiIN6/fabric-language-kotlin-1.10.17%2Bkotlin.1.9.22.jar";
              hash = "sha256-/L/yGZouYL5dUzDJ5/FkfzTvRKH87dSuZN3B2bN/VoE=";
            };
          }
        );
      };
    };
  };
}