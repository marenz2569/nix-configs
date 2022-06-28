{ lib, config, pkgs, ... }:

let
  customPkgs = (import ../../secrets/configs/pkgs/default.nix) { };

  # mt76_pre_5_18_reboot_patch = {
  #   name = "mt76_pre_5_18_reboot_patch";
  #   patch = ./mt76.patch;
  # };
in
{
  imports = [
    ../../lib/common.nix
    ../../secrets/configs/hosts/marenz-frickelkiste/common.nix
    ./i3/common.nix
		./hardware-configuration.nix
	];

#  qemu-user.aarch64 = true;
#  qemu-user.arm = true;
#  qemu-user.riscv64 = true;

  boot.kernelPackages = pkgs.linuxPackages_5_18;
  # boot.kernelPackages = pkgs.linuxPackages_5_17;
  # currently broken on kernel >= 5.17 in nixos 21.11 (09.04.2022)
  # boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8192eu ];

#  boot.kernelPatches = [ mt76_pre_5_18_reboot_patch ];

  hardware.hackrf.enable = true;
  hardware.rtl-sdr.enable = true;

  # nix.package = pkgs.nixFlakes;
  # nix.extraOptions = ''
  #   experimental-features = nix-command flakes
  # '';

  nixpkgs.config.allowUnfree = true;
	environment.systemPackages = with pkgs; 
	let
		st = (pkgs.st.override { conf = builtins.readFile ./st.h; });
		ncmpcpp = (pkgs.ncmpcpp.override { outputsSupport = true; });
		ncpamixer = (pkgs.ncpamixer.overrideAttrs (oldAttrs: {
			version = "unstable-2021-10-21";

			src = fetchFromGitHub {
				owner = "fulhax";
				repo = "ncpamixer";
				rev = "4faf8c27d4de55ddc244f372cbf5b2319d0634f7";
				sha256 = "sha256-ElbxdAaXAY0pj0oo2IcxGT+K+7M5XdCgom0XbJ9BxW4=";
			};

			configurePhase = ''
				make PREFIX=$out USE_WIDE=1 RELEASE=1 build/Makefile
			'';
		}));  
	in [
#    customPkgs.vampir
    libimobiledevice
    ifuse

    squashfsTools

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

    #androidStudioPackages.stable
    android-file-transfer
		kotlin

    gajim
    signal-desktop
    pidgin
    tdesktop

    #kicad

		texmaker texlive.combined.scheme-full

		python3Full
		python3Packages.pip
		python3Packages.virtualenv

		python3Packages.powerline powerline-fonts
		glxinfo
    apache-directory-studio
		mutt
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

  # now defined in nixos/modules/programs/environment.nix
	# environment.variables.XDG_CONFIG_DIRS = "/etc/xdg";

  services.udev.extraRules = ''
    ACTION=="bind", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="1366", ENV{ID_MODEL_ID}=="1015", RUN+="${pkgs.libvirt}/bin/virsh attach-device win10-2 /etc/hostdev-segger-jlink.xml"
    ACTION=="remove", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="1366", ENV{ID_MODEL_ID}=="1015", RUN+="${pkgs.libvirt}/bin/virsh detach-device win10-2 /etc/hostdev-segger-jlink.xml"

    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="2838", ENV{ID_SOFTWARE_RADIO}="1", MODE="0660", GROUP="dialout"

    # Copy this file to /etc/udev/rules.d/
    # If rules fail to reload automatically, you can refresh udev rules
    # with the command "udevadm control --reload"

    # This rules are based on the udev rules from the OpenOCD project, with unsupported probes removed.
    # See http://openocd.org/ for more details.
    #
    # This file is available under the GNU General Public License v2.0 

    ACTION!="add|change", GOTO="probe_rs_rules_end"

    SUBSYSTEM=="gpio", MODE="0660", GROUP="plugdev", TAG+="uaccess"

    SUBSYSTEM!="usb|tty|hidraw", GOTO="probe_rs_rules_end"

    # Please keep this list sorted by VID:PID

    # STMicroelectronics ST-LINK V1
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3744", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # STMicroelectronics ST-LINK/V2
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # STMicroelectronics ST-LINK/V2.1
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3752", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # STMicroelectronics STLINK-V3
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3754", MODE="660", GROUP="plugdev", TAG+="uaccess"

    # SEGGER J-Link
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0101", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0102", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0103", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0104", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0105", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0107", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="0108", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1010", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1011", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1012", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1013", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1014", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1015", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1016", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1017", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1018", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1051", MODE="660", GROUP="plugdev", TAG+="uaccess"
    ATTRS{idVendor}=="1366", ATTRS{idProduct}=="1061", MODE="660", GROUP="plugdev", TAG+="uaccess"


    # CMSIS-DAP compatible adapters
    ATTRS{product}=="*CMSIS-DAP*", MODE="660", GROUP="plugdev", TAG+="uaccess"

    LABEL="probe_rs_rules_end"
  '';

  #  SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="cc15", MODE="0660", GROUP="dialout"
  #  SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{idProduct}=="6089", MODE="0660", GROUP="dialout"

  environment.etc."hostdev-segger-jlink.xml".text = ''
    <hostdev mode='subsystem' type='usb'>
      <source>
        <vendor id='0x1366'/>
        <product id='0x1015'/>
      </source>
    </hostdev>
  '';

	time.timeZone = "Europe/Berlin";

	i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  networking.hostName = "marenz-frickelkiste";

  # boot.loader.grub = {
	# 	enable = true;
	# 	version = 2;
	# 	device = "/dev/nvme0n1";
  #   configurationLimit = 2;
	# };

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh = {
	  enable = true;
    passwordAuthentication = false;
    forwardX11 = true;
	  ports = [ 1122 ];
  };

  services.printing = {
    enable = true;
    extraConf = ''
      ImplicitClass No
    '';
    browsing = true;
    browsedConf = ''
      BrowsePoll hermes2.zih.tu-dresden.de:631
      BrowsePoll padme.fsr.et.tu-dresden.de:631
      BrowsePoll pulsebert.hq.c3d2.de:631
    '';
    drivers = with pkgs; [ gutenprint hplip splix samsung-unified-linux-driver ];
  };


	services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "dvorak";
    libinput = {
      enable = true;
      touchpad = {
        tapping = false;
      };
    };
    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+i3";
    windowManager.i3 = {
      enable = true;
      configFile = "/etc/i3.conf";
      extraPackages = with pkgs; [
        dmenu i3status i3lock
      ];
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
				ExecStart = "/run/current-system/sw/bin/chmod 666 /sys/class/backlight/amdgpu_bl0/brightness";
			};
		};
	};

  services.usbmuxd.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;
  services.blueman.enable = true;
  # hardware.bluetooth.hsphfpd.enable = true;

  hardware.bluetooth.settings.General.Enable = "Source,Sink,Media,Socket";

	sound.enable = true;
	hardware.pulseaudio = {
		enable = true;
    # systemWide = true;
		zeroconf.discovery.enable = true;
    # tcp = {
		# 	enable = true;
		# 	anonymousClients = {
    #     allowedIpRanges = [
    #       "127.0.0.1"
    #     ];
		# 	};
		# };
    package = pkgs.pulseaudioFull;
	};

  virtualisation.libvirtd = {
    enable = true;
    onShutdown = "shutdown";
  };

  virtualisation.docker.enable = true;
  #programs.singularity.enable = true;

  users.groups.wireshark.name = "wireshark"; 

  users.users.marenz = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/marenz";
    createHome = true;
    extraGroups = [ "wheel" "audio" "libvirtd" "wireshark" "docker" "dialout" "plugdev" ];
    shell = pkgs.zsh;
  };

  services.dbus.enable = true;

  services.dbus.packages = let 
    pulseConf = pkgs.writeTextFile
      { name = "pulse-bluez.conf";
        destination = "/etc/dbus-1/system.d/pulse-bluez.conf";
        text = ''
          <!DOCTYPE busconfig PUBLIC
           "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
           "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
          <busconfig>
            <policy user="pulse">
              <allow send_destination="org.bluez"/>
              <allow send_destination="org.ofono"/>
            </policy>
          </busconfig>
        '';
      };
  in [ pulseConf ];

  services.unifi = {
      enable = true;
        unifiPackage = pkgs.unifiStable;
      };

  programs.ccache.enable = true;


}
