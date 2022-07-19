{ config, pkgs, ... }:

{
  imports =
    [ ./i3/common.nix ./hardware-configuration.nix ./wireguard-dump-dvb.nix ];

  system.stateVersion = "19.03";

  boot.tmpOnTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages_5_18;
  boot.extraModulePackages = with config.boot.kernelPackages; [ ];

  sops.defaultSopsFile = ../../secrets/marenz-frickelkiste/secrets.yaml;

  environment.systemPackages = with pkgs;
    let
      st = (pkgs.st.override { conf = builtins.readFile ./st.h; });
      ncmpcpp = (pkgs.ncmpcpp.override { outputsSupport = true; });
      ncpamixer = (pkgs.ncpamixer.overrideAttrs (_oldAttrs: {
        version = "unstable-2021-10-21";

        src = fetchFromGitHub {
          owner = "fulhax";
          repo = "ncpamixer";
          rev = "4faf8c27d4de55ddc244f372cbf5b2319d0634f7";
          sha256 = "sha256-ElbxdAaXAY0pj0oo2IcxGT+K+7M5XdCgom0XbJ9BxW4=";
        };

        configurePhase =
          "	make PREFIX=$out USE_WIDE=1 RELEASE=1 build/Makefile\n";
      }));
    in [
      #    customPkgs.vampir
      libimobiledevice
      ifuse

      squashfsTools

      curl
      wget
      htop
      feh
      xorg.xkill
      gnupg
      st
      unzip
      mpv
      openssl
      file
      binutils-unwrapped
      tmux
      tmuxp
      lxterminal
      sshpass
      yubikey-personalization
      yubioath-desktop
      yubikey-personalization-gui
      yubico-piv-tool
      vivaldi
      ncmpcpp
      firefox-esr
      pavucontrol
      ncpamixer
      qpdfview
      thunderbird
      nextcloud-client
      gnucash
      gnuplot
      sxiv
      surf
      gimp
      youtube-dl
      screen-message

      usbutils
      pciutils
      dmidecode
      iftop
      linuxPackages.perf
      perf-tools

      pass
      pinentry

      gcc
      cmake
      gnumake

      #androidStudioPackages.stable
      android-file-transfer
      kotlin

      gajim
      signal-desktop
      pidgin
      tdesktop

      kicad

      texmaker
      texlive.combined.scheme-full

      python3Full
      python3Packages.pip
      python3Packages.virtualenv

      python3Packages.powerline
      powerline-fonts
      glxinfo
      apache-directory-studio
      mutt
      wpa_supplicant_gui
      nix-index

      bat
      bind
      cachix
      cargo
      cargo-flash
      clang-tools
      direnv
      discord
      element-desktop
      gajim
      gdb
      graphviz
      hdfview
      jetbrains.idea-community
      killall
      libreoffice
      lm_sensors
      lsof
      ltrace
      lxterminal
      lynx
      mumble
      nmap
      pass
      picocom
      pinentry
      qucs
      rdesktop
      rustup
      screen-message
      scrot
      spotify
      subversion
      tig
      tigervnc
      traceroute
      whois
      wireshark-qt
      yubico-piv-tool
      zoom
      zotero
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
      gutenprint
      hplip
      splix
      samsung-unified-linux-driver
    ];
  };

  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "dvorak";
    libinput = {
      enable = true;
      touchpad = { tapping = false; };
    };
    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+i3";
    windowManager.i3 = {
      enable = true;
      configFile = "/etc/i3.conf";
      extraPackages = with pkgs; [ dmenu i3status i3lock ];
    };
    wacom.enable = true;
  };

  hardware.opengl.driSupport32Bit = true;

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
  };
}
