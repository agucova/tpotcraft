{
  description = "TPotCraft - Better Minecraft 3 server with Fabric";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = { self, nixpkgs, nix-minecraft, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { 
      inherit system; 
      overlays = [ nix-minecraft.overlay ];
      config.allowUnfree = true;
    };
  in {
    packages.${system} = {
      # Create a Docker image for the Minecraft server
      docker-image = pkgs.dockerTools.buildLayeredImage {
        name = "tpotcraft";
        tag = "latest";
        
        contents = [
          # Basic tools
          pkgs.bashInteractive
          pkgs.coreutils
          pkgs.tmux
          pkgs.curl
          pkgs.findutils
          pkgs.wget
          pkgs.vim
          pkgs.htop
          
          # JDK for Minecraft
          pkgs.jdk17
          
          # Minecraft server
          (pkgs.fabricServers.fabric-1_21.override {
            loaderVersion = "0.15.9";
          })
        ];
        
        config = {
          Cmd = [
            "/bin/bash", 
            "-c", 
            "if [ ! -f /data/eula.txt ] || ! grep -q 'eula=true' /data/eula.txt; then echo 'eula=true' > /data/eula.txt; fi && mkdir -p /data/mods /data/config && cd /data && java -Xmx4G -Xms2G -XX:+UseG1GC -jar $(find /nix/store -name 'fabric-server-launch.jar' | head -1) nogui"
          ];
          WorkingDir = "/data";
          Volumes = {
            "/data" = {};
          };
          ExposedPorts = {
            "25565/tcp" = {};
          };
        };
      };
      
      # Create a minimal server.properties file
      server-properties = pkgs.writeTextFile {
        name = "server.properties";
        text = ''
          server-port=25565
          difficulty=normal
          gamemode=survival
          motd=TPotCraft - Better Minecraft 3
          white-list=true
          spawn-protection=0
          max-players=10
        '';
        destination = "/server.properties";
      };
      
      # Create a script to download core mods
      download-mods = pkgs.writeShellScriptBin "download-mods" ''
        #!/bin/bash
        set -e
        
        TARGET_DIR="$1"
        if [ -z "$TARGET_DIR" ]; then
          echo "Usage: download-mods TARGET_DIRECTORY"
          exit 1
        fi
        
        mkdir -p "$TARGET_DIR"
        
        echo "Downloading core mods for Better Minecraft 3..."
        curl -L -o "$TARGET_DIR/fabric-api.jar" "https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar"
        curl -L -o "$TARGET_DIR/fabric-language-kotlin.jar" "https://cdn.modrinth.com/data/Ha28R6CL/versions/vMQSiIN6/fabric-language-kotlin-1.10.17%2Bkotlin.1.9.22.jar"
        
        echo "Core mods downloaded to $TARGET_DIR"
        echo "Now download and add the Better Minecraft 3 modpack files"
      '';
      
      # Default package is the Docker image
      default = self.packages.${system}.docker-image;
    };
  };
}