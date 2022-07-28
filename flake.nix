{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "./secrets";
      flake = false;
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, sops-nix, secrets, nixos-hardware, ... }@attrs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      packages.marenz-frickelkiste-nixos-rebuild =
        pkgs.writeScriptBin "marenz-frickelkiste-nixos-rebuild" ''
          nixos-rebuild --flake ${self}?submodules=1#marenz-frickelkiste -L $@
        '';
    in {
      package.x86_64-linux.default =
        self.nixosConfiguration.marenz-frickelkiste.config.system.build.vm;
      packages.x86_64-linux = packages;

      nixosConfigurations.marenz-frickelkiste = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          ./hosts/marenz-frickelkiste/configuration.nix
          ./modules/base.nix
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
        ];
      };
    };
}
