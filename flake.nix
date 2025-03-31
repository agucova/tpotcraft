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
            
            # Performance mods
            (pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
              Fabric-API = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/9YVrKY0Z/fabric-api-0.115.0%2B1.21.1.jar";
                hash = "sha256-LN3s65ZkdCUGKC0mJyPQxBxdzQzT9Yt34iiSR/d7Q+c=";
              };
              Fabric-Language-Kotlin = pkgs.fetchurl {
                url = "https://cdn.modrinth.com/data/Ha28R6CL/versions/vMQSiIN6/fabric-language-kotlin-1.10.17%2Bkotlin.1.9.22.jar";
                hash = "sha256-/L/yGZouYL5dUzDJ5/FkfzTvRKH87dSuZN3B2bN/VoE=";
              };
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
                hash = "sha256-usxErU+340H034jAdLppLZd8SrYiFeNCSUibZ2kVUYk=";
              };
            }))
          ];
        };
        
        config = {
          Cmd = [
            "/bin/bash" 
            "-c" 
            "mkdir -p /data/mods && cp -r /nix/store/*-mods/* /data/mods/ && cd /data && java -Xmx4G -Xms4G -XX:+UseG1GC -jar /nix/store/*-fabric-server-launch.jar nogui"
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