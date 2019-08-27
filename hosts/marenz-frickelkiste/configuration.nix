{ lib, config, pkgs, ... }:

let
  customPkgs = (import ../../secrets/configs/pkgs/default.nix) { };
in
{
	imports = [
    ../../lib/common.nix
    ../../secrets/configs/hosts/marenz-frickelkiste/common.nix
    ./i3/common.nix
		./hardware-configuration.nix
	];

  qemu-user.aarch64 = true;

  boot.extraModulePackages = with pkgs; [ linuxPackages_latest.rtl8192eu ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

	environment.systemPackages = with pkgs; 
	let
		st = (pkgs.st.override { conf = builtins.readFile ./st.h; });
		ncmpcpp = (pkgs.ncmpcpp.override { outputsSupport = true; });
	in [
    customPkgs.vampir

		curl wget htop feh xorg.xkill gnupg st unzip mpv openssl file binutils-unwrapped tmux tmuxp
    lxterminal
		git sshpass
		yubikey-personalization yubioath-desktop yubikey-personalization-gui yubico-piv-tool
		vivaldi ncmpcpp firefox-esr pavucontrol ncpamixer qpdfview thunderbird nextcloud-client gnucash gnuplot sxiv surf gimp youtube-dl
    screen-message

		usbutils pciutils dmidecode iftop
    linuxPackages.perf perf-tools

    pass
    pinentry

		gcc cmake gnumake
		avrdude #avrgcc avrbinutils avrlibc

		androidStudioPackages.stable
    android-file-transfer
		kotlin

    gajim
    signal-desktop
    pidgin
    tdesktop

    kicad

		texmaker texlive.combined.scheme-full

		python27Full python37Full
		python27Packages.pip python37Packages.pip
		python27Packages.virtualenv python37Packages.virtualenv

		python37Packages.powerline powerline-fonts
		glxinfo
    apache-directory-studio
		mutt
    gutenprint gutenprintBin
    wpa_supplicant_gui
    virtmanager
    nix-index
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

  networking.hostName = "marenz-frickelkiste";

	boot.loader.grub = {
		enable = true;
		version = 2;
		device = "/dev/sda";
		configurationLimit = 10;
	};

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
					name  "marenz-crafix"
					server  "10.0.10.152"
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
      BrowsePoll hermes2.zih.tu-dresden.de:631
      BrowsePoll hermes3.zih.tu-dresden.de:631
      BrowsePoll padme.fsr.et.tu-dresden.de:631
    '';
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
	hardware.pulseaudio = {
		enable = true;
		systemWide = true;
		zeroconf.discovery.enable = true;
		tcp = {
			enable = true;
			anonymousClients = {
				allowedIpRanges = [
					"127.0.0.1"
				];
			};
		};
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    #configFile = pkgs.writeText "default.pa" ''
      #load-module module-bluetooth-policy
      #load-module module-bluetooth-discover
      ## module fails to load with 
      ##   module-bluez5-device.c: Failed to get device path from module arguments
      ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
      # load-module module-bluez5-device
      # load-module module-bluez5-discover
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
