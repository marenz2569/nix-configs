{ config, pkgs, secrets, ... }:

{
  system.stateVersion = "19.03";

  hardware.enableAllFirmware = true;

  boot.tmpOnTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ ];

  sops.defaultSopsFile = "${secrets}/marenz-frickelkiste/secrets.yaml";

  # netrc file for fetching private packages
  sops.secrets."marenz-frickelkiste/netrc" = {
    format = "binary";
    sopsFile = "${secrets}/marenz-frickelkiste/netrc";
  };

  nix.extraOptions = ''
    netrc-file = ${config.sops.secrets."marenz-frickelkiste/netrc".path}
  '';
  nix.settings.extra-sandbox-paths =
    [ "${config.sops.secrets."marenz-frickelkiste/netrc".path}" ];

  environment.systemPackages = with pkgs;
    let
      vampir = (pkgs.vampir.overrideAttrs (oldAttrs: {
        unpackPhase = oldAttrs.unpackPhase + ''
          ln -s "${config.users.users.marenz.home}/.local/share/vampir" $out/etc/vampir
        '';
      }));
    in [
      vampir

      # https://gitlab.com/doronbehar/nix-matlab
      matlab
      matlab-shell
      matlab-mlint
      matlab-mex

      libimobiledevice
      ifuse

      squashfsTools

      curl
      wget
      htop
      gnupg
      unzip
      mpv
      openssl
      file
      binutils-unwrapped
      tmux
      tmuxp
      sshpass
      ncpamixer

      usbutils
      pciutils
      dmidecode
      iftop
      linuxPackages.perf
      perf-tools

      pass
      youtube-dl

      gcc
      cmake
      gnumake

      jetbrains.idea-community
      flutter
      flutter.dart

      android-studio
      android-tools
      android-file-transfer
      kotlin

      texlive.combined.scheme-full

      python3Full
      python3Packages.pip
      python3Packages.virtualenv

      python3Packages.powerline
      powerline-fonts
      nix-index

      bat
      bind
      cachix
      cargo-flash
      clang-tools
      direnv
      gdb
      graphviz
      killall
      libreoffice
      lm_sensors
      lsof
      ltrace
      lynx
      nmap
      pass
      picocom
      rustup
      subversion
      tig
      traceroute
      whois
      nixfmt
      jq

      chromium
    ];

  environment.etc."xdg/mimeapps.list".text = ''
    [Default Applications]
      text/html=vivaldi-stable.desktop;
      text/xml=vivaldi-stable.desktop;
      x-scheme-handler/ftp=vivaldi-stable.desktop;
      x-scheme-handler/http=vivaldi-stable.desktop;
      x-scheme-handler/https=vivaldi-stable.desktop;
  '';

  #  SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", MODE="0660", GROUP="dialout"
  #  SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", MODE="0660", GROUP="dialout"

  networking.hostName = "marenz-frickelkiste";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 2;
  boot.loader.efi.canTouchEfiVariables = true;

  services.printing = {
    enable = true;
    extraConf = ''
      ImplicitClass No
    '';
    browsing = true;
    browsedConf = ''
      BrowsePoll padme.fsr.et.tu-dresden.de:631
    '';
    drivers = with pkgs; [
      brlaser
      gutenprint
      hplip
      splix
      samsung-unified-linux-driver
      foomatic-db-ppds-withNonfreeDb
      fxlinuxprint
    ];
  };

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.opengl.extraPackages = with pkgs; [ amdvlk ];
  # For 32 bit applications 
  # Only available on unstable
  hardware.opengl.extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];

  services.xserver.videoDrivers = [ "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  systemd.services = {
    user-backlight-brightness-permissions = {
      enable = true;
      wantedBy = [ "default.target" ];
      description = "Change permissions of backlight brightness hardware class";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart =
          "/run/current-system/sw/bin/chmod 666 /sys/class/backlight/amdgpu_bl0/brightness";
      };
    };
  };

  services.usbmuxd.enable = true;

  users.groups.wireshark.name = "wireshark";

  users.users.marenz = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/marenz";
    createHome = true;
    extraGroups =
      [ "wheel" "audio" "libvirtd" "wireshark" "docker" "dialout" "plugdev" ];
    shell = pkgs.zsh;
  };

  services.unifi = {
    enable = true;
    unifiPackage = pkgs.unifiStable;
    openFirewall = true;
  };

  programs.ausweisapp = {
    enable = true;
    openFirewall = true;
  };
}
