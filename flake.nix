{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/marenz2569/nix-configs-secrets.git";
      flake = false;
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sdr-nix = {
      url = "github:polygon/sdr.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    csi-collector = {
      url = "git+ssh://git@git.comnets.net/s2599166/csi-collector-server.git";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.naersk.follows = "naersk";
      inputs.utils.follows = "flake-utils";
    };

    zentralwerk.url = "git+https://gitea.c3d2.de/zentralwerk/network";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, secrets, nixos-hardware
    , nix-matlab, sdr-nix, microvm, csi-collector, zentralwerk, ... }@attrs:
    let
      inherit (nixpkgs) lib;

      systems = [ "x86_64-linux" "aarch64-linux" ];

      overlays = import ./overlays {
        inherit nixpkgs-unstable;
        inherit sdr-nix;
      };

      packages = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in (overlays { } pkgs) // {
          marenz-frickelkiste-nixos-rebuild =
            pkgs.writeScriptBin "marenz-frickelkiste-nixos-rebuild" ''
              #!${pkgs.runtimeShell} -ex
              ${pkgs.nixos-rebuild}/bin/nixos-rebuild --flake ${self}#marenz-frickelkiste -L $@
            '';
          wg-bar-ma-nixos-rebuild =
            pkgs.writeScriptBin "wg-bar-ma-nixos-rebuild" ''
              #!${pkgs.runtimeShell} -ex
              ${pkgs.nixos-rebuild}/bin/nixos-rebuild --flake ${self}#wg-bar-ma --target-host wg-bar-ma --use-substitutes "$@"
            '';
          controller-physec-nixos-rebuild =
            pkgs.writeScriptBin "controller-physec-nixos-rebuild" ''
              #!${pkgs.runtimeShell} -ex
              ${pkgs.nixos-rebuild}/bin/nixos-rebuild --flake ${self}#controller-physec --target-host controller-physec --use-substitutes "$@"
            '';
          cal-marenz-nixos-rebuild =
            pkgs.writeScriptBin "controller-physec-nixos-rebuild" ''
              #!${pkgs.runtimeShell} -ex
              ${pkgs.nixos-rebuild}/bin/nixos-rebuild --flake ${self}#cal-marenz --target-host cal-marenz --use-substitutes "$@"
            '';
        };
    in {
      packages = let
        nixosConfigurationsForSystem = system:
          lib.filterAttrs (name: value: value.config.nixpkgs.system == system)
          self.nixosConfigurations;
        packagesForSystem = system:
          (packages system) // (lib.mapAttrs' (name: value:
            lib.nameValuePair (name + "-vm") (value.config.system.build.vm))
            (nixosConfigurationsForSystem system));
      in lib.recursiveUpdate (builtins.listToAttrs (builtins.map
        (system: lib.nameValuePair system (packagesForSystem system))
        systems)) {
          "x86_64-linux" = {
        #    gitlab-runner-docker-microvm =
        #      self.nixosConfigurations.gitlab-runner-docker.config.microvm.declaredRunner;
          };
        };

      nixosModules.zentralwerk = {
        _module.args = { inherit zentralwerk; };
        imports = [ ./modules/zw-network.nix ./modules/zw-cluster-options.nix ];
      };

      nixosConfigurations.marenz-frickelkiste = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self;
          inherit secrets;
        };
        modules = [
          ./hosts/marenz-frickelkiste
          ./modules/base.nix
          ./modules/host.nix
          ./modules/graphical.nix
          ./modules/microcontroller.nix
          ./modules/pipewire.nix
          ./modules/sdr.nix
          ./modules/virtualization.nix
          ./modules/wireless.nix
          ./modules/xray-sensor.nix
          sops-nix.nixosModules.sops
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
          ./modules/t14gen1amd.nix
          { nixpkgs.overlays = [ overlays nix-matlab.overlay ]; }
        ];
      };

      nixosConfigurations.wg-bar-ma = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self;
          inherit secrets;
        };
        modules = [
          ./hosts/wg-bar-ma
          ./modules/base.nix
          ./modules/collect-garbage.nix
          ./modules/host.nix
          sops-nix.nixosModules.sops
          { nixpkgs.overlays = [ overlays ]; }
        ];
      };

      nixosConfigurations.controller-physec = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self;
          inherit secrets;
        };
        modules = [
          ./hosts/controller-physec
          ./modules/base.nix
          ./modules/collect-garbage.nix
          ./modules/host.nix
          sops-nix.nixosModules.sops
          { nixpkgs.overlays = [ overlays csi-collector.overlays.default ]; }
        ];
      };

      nixosConfigurations.gitlab-runner-docker = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self;
          inherit secrets;
        };
        modules = [
          ./hosts/gitlab-runner-docker
          ./modules/base.nix
          sops-nix.nixosModules.sops
          self.nixosModules.zentralwerk
          {
            nixpkgs.overlays = [
              # use stable kernel instead. microvm uses linuxPackages_latest per default
              (self: super: { linuxPackages_latest = self.linuxPackages; })
              overlays
            ];
          }
        ];
      };

      nixosConfigurations.cal-marenz = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit self;
          inherit secrets;
        };
        modules = [
          ./hosts/cal-marenz
          ./modules/base.nix
          ./modules/collect-garbage.nix
          sops-nix.nixosModules.sops
          { nixpkgs.overlays = [ overlays ]; }
        ];
      };
    };
}
