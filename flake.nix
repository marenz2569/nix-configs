{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-22_05.follows = "nixpkgs";
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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, nixos-hardware
    , nix-matlab, sdr-nix, microvm, ... }@attrs:
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
            gitlab-runner-docker-microvm =
              self.nixosConfigurations.gitlab-runner-docker.config.microvm.declaredRunner;
          };
        };

      nixosConfigurations.marenz-frickelkiste = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./hosts/marenz-frickelkiste/configuration.nix
          ./modules/base.nix
          ./modules/graphical.nix
          ./modules/microcontroller.nix
          ./modules/openvpn-bad5.nix
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
        specialArgs = attrs;
        modules = [
          ./hosts/wg-bar-ma
          ./modules/base.nix
          sops-nix.nixosModules.sops
          { nixpkgs.overlays = [ overlays ]; }
        ];
      };

      nixosConfigurations.controller-physec = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./hosts/controller-physec
          ./modules/base.nix
          sops-nix.nixosModules.sops
          { nixpkgs.overlays = [ overlays ]; }
        ];
      };

      nixosConfigurations.gitlab-runner-docker = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./hosts/gitlab-runner-docker
          ./modules/base.nix
          sops-nix.nixosModules.sops
          microvm.nixosModules.microvm
        ];
      };
    };
}
