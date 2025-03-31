{
  description = "Better Minecraft 2 server with Fabric";

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
    # NixOS system configuration
    nixosConfigurations.tpotcraft = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        nix-minecraft.nixosModules.minecraft-servers
        {
          nixpkgs.overlays = [ nix-minecraft.overlay ];
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
    
    # Docker image
    packages.${system} = {
      dockerImage = pkgs.dockerTools.buildImage {
        name = "tpotcraft";
        tag = "latest";
        
        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [
            # Basic tools
            pkgs.bashInteractive
            pkgs.coreutils
            pkgs.tmux
            pkgs.curl
            pkgs.wget
            pkgs.vim
            pkgs.htop
            
            # JDK for Minecraft
            pkgs.jdk17
            
            # The Minecraft server package
            (pkgs.fabricServers.fabric-1_20_1.override {
              loaderVersion = "0.15.6";
            })
          ];
        };
        
        config = {
          Cmd = [
            "/bin/bash" 
            "-c" 
            "mkdir -p /data/mods /data/config && cd /data && java -Xmx4G -Xms2G -XX:+UseG1GC -jar /nix/store/*-fabric-server-launch.jar nogui"
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
      
      # VM configuration
      vm = pkgs.writeShellScriptBin "run-tpotcraft-vm" ''
        ${pkgs.qemu}/bin/qemu-system-x86_64 \
          -m 6G \
          -smp 2 \
          -enable-kvm \
          -display sdl \
          -device virtio-net,netdev=user.0 \
          -netdev user,id=user.0,hostfwd=tcp::25565-:25565 \
          -drive file=$(${pkgs.nixos-generators}/bin/nixos-generate -f qcow -c ${./vm-configuration.nix}),if=virtio,cache=writeback,discard=unmap \
          -virtfs local,path=$HOME/tpotcraft-data,security_model=mapped-xattr,mount_tag=data
      '';
      
      default = self.packages.${system}.dockerImage;
    };
  };
}