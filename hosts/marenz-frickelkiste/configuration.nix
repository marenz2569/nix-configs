{ lib, config, pkgs, ... }:

{
	imports = [
    ../../lib/common.nix
    ../../secrets/configs/hosts/marenz-frickelkiste/common.nix
    ./i3/common.nix
		./hardware-configuration.nix
	];

  qemu-user.aarch64 = true;

	boot.initrd.luks = {
		gpgSupport = true;
		devices."root-crypt".gpgCard = {
			encryptedPass = /etc/keys/cryptkey.gpg.asc;
			publicKey = /etc/keys/pubkey.asc;
		};
		devices."home-crypt".gpgCard = {
			encryptedPass = /etc/keys/cryptkey.gpg.asc;
			publicKey = /etc/keys/pubkey.asc;
		};
	};

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
		texmaker texlive.combined.scheme-full
		kotlin
		python27Full python36Full
		python27Packages.pip python36Packages.pip
		python27Packages.virtualenv python36Packages.virtualenv
		python36Packages.powerline powerline-fonts
		glxinfo
    mosquitto-go-auth
    apache-directory-studio
		mutt
    gutenprint gutenprintBin
    linuxPackages_4_19.rtl8192eu
    wpa_supplicant_gui
    virtmanager
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
    browsedConf = ''
      BrowsePoll hermes2.zih.tu-dresden.de
      BrowsePoll hermes3.zih.tu-dresden.de
      BrowsePoll padme.fsr.et.tu-dresden.de
    '';
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
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
