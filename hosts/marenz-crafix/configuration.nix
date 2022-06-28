{ lib, config, pkgs, ... }:

{
	imports = [
    ../../lib/common.nix
    ../../secrets/configs/hosts/marenz-crafix/common.nix
    ./i3/common.nix
		./hardware-configuration.nix
	];

  qemu-user.aarch64 = true;

  boot.extraModulePackages = with pkgs; [ linuxPackages_4_19.rtl8192eu ];

  boot.extraModprobeConfig = ''
    options iwlmvm power_scheme=1
    options kvm_intel nested=1
  '';

	environment.systemPackages = with pkgs; 
	let
		st = (pkgs.st.override { conf = builtins.readFile ./st.h; });
		ncmpcpp = (pkgs.ncmpcpp.override { outputsSupport = true; });
	in [
		curl wget htop feh xorg.xkill gnupg st unzip mpv openssl file binutils-unwrapped tmux tmuxp
		git sshpass
		yubikey-personalization yubioath-desktop yubikey-personalization-gui
		vivaldi tdesktop ncmpcpp firefox-esr pavucontrol ncpamixer qpdfview thunderbird nextcloud-client gnucash gnuplot sxiv surf gimp youtube-dl
    signal-desktop
		usbutils pciutils dmidecode iftop
		gcc cmake gnumake
		avrdude #avrgcc avrbinutils avrlibc
		androidStudioPackages.stable
    #texmaker texlive.combined.scheme-full
		kotlin
		python27Full python36Full
		python27Packages.pip python36Packages.pip
		python27Packages.virtualenv python36Packages.virtualenv
    python36Packages.powerline
		glxinfo
    apache-directory-studio
		mutt
    gutenprint gutenprintBin
    linuxPackages_4_19.rtl8192eu
    wpa_supplicant_gui
    virtmanager
    killall
    gajim
    pass
    bat
	];

  fonts.fonts = with pkgs; [
    powerline-fonts
  ];

  environment.etc."xdg/mimeapps.list".text = ''
    [Default Applications]
      text/html=vivaldi-stable.desktop;
      text/xml=vivaldi-stable.desktop;
      x-scheme-handler/ftp=vivaldi-stable.desktop;
      x-scheme-handler/http=vivaldi-stable.desktop;
      x-scheme-handler/https=vivaldi-stable.desktop;
  '';

	environment.variables.XDG_CONFIG_DIRS = "/etc/xdg";

	time.timeZone = "Europe/Berlin";

	i18n = {
		defaultLocale = "de_DE.UTF-8";
		consoleUseXkbConfig = true;
	};

  networking.hostName = "marenz-crafix";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
	  enable = true;
    passwordAuthentication = false;
    forwardX11 = true;
	  ports = [ 1122 ];
  };

	services.mpd = {
    enable = true;
    user = "mpd";
    group = "audio";
    network = {
      listenAddress = "127.0.0.1";
      port = 6600;
    };
    musicDirectory = "/home/mpd/Music";
    extraConfig = ''
      default_permissions "read,add,control,admin"

      input {
        plugin "curl"
      }

      audio_output {
        type  "pulse"
        name  "Local Pulse"
      }

      audio_output {
        type  "pulse"
        name  "Dacbert"
        server  "dacbert.hq.c3d2.de"
      }

      audio_output {
        type  "pulse"
        name  "Pulsebert"
        server  "pulsebert.hq.c3d2.de"
      }

      filesystem_charset  "UTF-8"
    '';
  };

  services.printing = {
    enable = true;
    browsing = true;
    browsedConf = ''
      BrowsePoll hermes2.zih.tu-dresden.de
      BrowsePoll hermes3.zih.tu-dresden.de
      BrowsePoll padme.fsr.et.tu-dresden.de
    '';
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.enable = true;
    publish.userServices = true;
  };

	services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "dvorak";
    libinput = {
      enable = true;
      tapping = false;
    };
    displayManager.lightdm.enable = true;
    desktopManager = {
      default = "none";
      xterm.enable = false;
    };
    windowManager.i3 = {
      enable = true;
      configFile = "/etc/i3.conf";
      extraPackages = with pkgs; [
        dmenu i3status i3lock
      ];
    };
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
				ExecStart = "/run/current-system/sw/bin/chmod 666 /sys/class/backlight/intel_backlight/brightness";
			};
		};
	};

	sound.enable = true;
  hardware.bluetooth.enable = true;
  networking.firewall.allowedTCPPorts = [
    4713 # Pulseaudio
  ];
  networking.firewall.extraCommands = ''
    iptables -I INPUT -p udp --dport mdns -d 224.0.0.251 -j ACCEPT
    iptables -I OUTPUT -p udp --dport mdns -d 224.0.0.251 -j ACCEPT
  '';
	hardware.pulseaudio = {
		enable = true;
		systemWide = true;
		zeroconf.discovery.enable = true;
		zeroconf.publish.enable = true;
		tcp = {
			enable = true;
			anonymousClients = {
				allowedIpRanges = [
					"127.0.0.1" "10.0.10.0/24"
				];
			};
		};
    #configFile = pkgs.writeText "default.pa" ''
     # load-module module-bluetooth-policy
     # load-module module-bluetooth-discover
      ## module fails to load with 
      ##   module-bluez5-device.c: Failed to get device path from module arguments
      ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
      # load-module module-bluez5-device
      # load-module module-bluez5-discover
    #'';
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
	};

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  users.users.marenz = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/marenz";
    createHome = true;
    extraGroups = [ "wheel" "audio" "libvirtd" ];
    shell = pkgs.zsh;
  };

}
