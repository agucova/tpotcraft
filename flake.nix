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
    
    # We need a GitHub URL for the packwiz modpack - currently using temporary placeholder
    # You can update this URL with your actual GitHub repository
    packwizUrl = "https://raw.githubusercontent.com/agucova/tpotcraft/main/pack.toml";
    packwizHash = "sha256-CXXM+qrJ7nAYOE3VjzM9tJyidKPxpgFCK+Z3r1LrPjU=";
    
    # Fetch modpack using fetchPackwizModpack
    tpotModpack = pkgs.fetchPackwizModpack {
      url = packwizUrl;
      packHash = packwizHash;
    };
    
    # Read Minecraft and Fabric versions from pack.toml to fallback if fetch fails
    javaVersion = "17";
    minecraft = "1.21.1";
    fabricVersion = "0.16.10"; # Read from pack.toml
    
    # Create a minecraft server configuration
    fabricServer = {
      enable = true;
      package = pkgs.fabricServers.fabric-1_21_1.override {
        loaderVersion = builtins.trace "Using Fabric version: ${tpotModpack.manifest.versions.fabric or fabricVersion}" 
                         (tpotModpack.manifest.versions.fabric or fabricVersion);
      };
      jvmOpts = "-Xms2G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200";
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

    # Docker run script
    dockerRunScript = pkgs.writeShellScriptBin "run-server.sh" ''
      #!/usr/bin/env bash
      mkdir -p minecraft-data
      
      # Set EULA=true in the mounted volume
      echo "eula=true" > minecraft-data/eula.txt
      
      # Start the server
      echo "Starting Minecraft server..."
      docker run --rm -it \
        -p 25565:25565 \
        -v "$(pwd)/minecraft-data:/data" \
        --name tpotcraft \
        tpotcraft:latest
    '';
    
  in {
    packages.${system} = {
      # Docker image
      docker-image = pkgs.dockerTools.buildImage {
        name = "tpotcraft";
        tag = "latest";
        
        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [
            # Basic tools
            pkgs.bashInteractive
            pkgs.coreutils
            pkgs.findutils
            pkgs.tmux
            
            # JDK for Minecraft
            pkgs.jdk17
            
            # Minecraft server
            fabricServer.package
          ];
        };
        
        config = {
          Entrypoint = [
            "/bin/bash"
            "-c"
            ''
            # Create necessary directories
            mkdir -p /data
            
            # Setup modpack files
            if [ ! -d /data/mods ] || [ ! "$(ls -A /data/mods 2>/dev/null)" ]; then
              echo "Setting up TPotCraft modpack..."
              
              # Copy modpack files to server data directory
              mkdir -p /data/mods /data/config
              
              # Copy mods from the packwiz modpack
              cp -r ${tpotModpack}/mods/* /data/mods/ 2>/dev/null || true
              cp -r ${tpotModpack}/config/* /data/config/ 2>/dev/null || true
              
              # Copy any other important directories that may exist in the modpack
              for dir in defaultconfigs kubejs resourcepacks scripts; do
                if [ -d "${tpotModpack}/$dir" ]; then
                  mkdir -p "/data/$dir"
                  cp -r "${tpotModpack}/$dir"/* "/data/$dir/" 2>/dev/null || true
                fi
              done
              
              echo "TPotCraft modpack setup complete."
            fi
            
            # Create server.properties if it doesn't exist
            if [ ! -f /data/server.properties ]; then
              cat > /data/server.properties << EOF
            server-port=25565
            difficulty=normal
            gamemode=survival
            motd=TPotCraft - Better Minecraft 3
            white-list=true
            spawn-protection=0
            max-players=10
            EOF
            fi
            
            # Start the server
            cd /data
            echo "eula=true" > eula.txt
            exec java ${fabricServer.jvmOpts} -jar $(find /nix/store -name 'fabric-server-launch.jar' | head -1) nogui
            ''
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

      # Helper script to run the server
      run-script = dockerRunScript;
      
      default = self.packages.${system}.docker-image;
    };
  };
}