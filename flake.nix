{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "./secrets";
      flake = false;
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-matlab = {
      url = "gitlab:doronbehar/nix-matlab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-master, sops-nix
    , nixos-hardware, nix-matlab, ... }@attrs:
    let
      inherit (nixpkgs) lib;

      systems = [ "x86_64-linux" "aarch64-linux" ];

      overlays = import ./overlays { inherit nixpkgs-unstable; };

      kernelMasterOverlay = self: super: {
        linuxKernel = nixpkgs-master.legacyPackages.${super.system}.linuxKernel;
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
              nixos-rebuild --flake ${self}?submodules=1#marenz-frickelkiste -L $@
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
      in builtins.listToAttrs (builtins.map
        (system: lib.nameValuePair system (packagesForSystem system)) systems);

      nixosConfigurations.marenz-frickelkiste = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./hosts/marenz-frickelkiste/configuration.nix
          ./modules/base.nix
          ./modules/graphical.nix
          ./modules/microcontroller.nix
          ./modules/openconnect-tud.nix
          ./modules/openvpn-bad5.nix
          ./modules/pipewire.nix
          ./modules/sdr.nix
          ./modules/virtualization.nix
          ./modules/wireless.nix
          ./modules/xray-sensor.nix
          sops-nix.nixosModules.sops
          nixos-hardware.nixosModules.lenovo-thinkpad-t14-amd-gen1
          {
            nixpkgs.overlays =
              [ overlays nix-matlab.overlay kernelMasterOverlay ];
          }
        ];
      };
    };
}
