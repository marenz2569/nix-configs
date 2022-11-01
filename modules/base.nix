{ config, pkgs, lib, self, ... }: {
  # NIX configuration
  nix.package = pkgs.nixLatest;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.settings.extra-sandbox-paths = [ "${config.programs.ccache.cacheDir}" ];
  nix.binaryCaches =
    [ "https://dump-dvb.cachix.org" "https://nix-serve.hq.c3d2.de" ];
  nix.binaryCachePublicKeys = [
    "dump-dvb.cachix.org-1:+Dq7gqpQG4YlLA2X3xJsG1v3BrlUGGpVtUKWk0dTyUU="
    "nix-serve.hq.c3d2.de:KZRGGnwOYzys6pxgM8jlur36RmkJQ/y8y62e52fj1ps="
  ];

  # override default nix shell nixpkgs# behaviour to use current flake lock
  nix.registry =
    let flakes = lib.filterAttrs (name: value: value ? outputs) self.inputs;
    in builtins.mapAttrs (name: v: { flake = v; }) flakes;

  nix.nixPath =
    lib.mapAttrsToList (name: value: "${name}=${value.outPath}") self.inputs;

  nixpkgs.config.allowUnfree = true;

  programs.ccache.enable = true;

  # SSH configuration
  users.users.root.openssh.authorizedKeys.keyFiles =
    [ ../keys/ssh/marenz1 ../keys/ssh/marenz2 ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    ports = [ 22 ];
  };

  # SOPS configuration
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  time.timeZone = "Europe/Berlin";

  # CONSOLE configuration
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "virtualenv" "sudo" ];
    };
    # https://vim.fandom.com/wiki/256_colors_setup_for_console_Vim
    shellInit = ''
      export TERM=screen-256color
    '';
  };

  users.users.root.shell = pkgs.zsh;

  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  environment.shellAliases = {
    l = "ls -laFh";
    ll = "ls -lFh";
    cl = "clear";
    v = "vim";
    g = "git";
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    fallbackDns = [ "1.1.1.1" ];
  };

  services.lldpd.enable = true;
}
