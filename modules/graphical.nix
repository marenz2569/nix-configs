{ pkgs, ... }:
let
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text = let
      schema = pkgs.gsettings-desktop-schemas;
      datadir = "${schema}/share/gsettings-schemas/${schema.name}";
    in ''
      export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
      gnome_schema=org.gnome.desktop.interface
      gsettings set $gnome_schema gtk-theme 'Dracula'
    '';
  };
in {
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    gtkUsePortal = true;
  };

  programs.xwayland.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
      autoSuspend = false;
    };
    layout = "de";
    xkbVariant = "dvorak";
    libinput = {
      enable = true;
      touchpad = { tapping = false; };
    };
    wacom.enable = true;
  };

  environment.systemPackages = with pkgs; [
    sway-layout
    sway
    dbus-sway-environment
    configure-gtk
    wayland
    swaylock
    dmenu
    j4-dmenu-desktop
    i3status
    grim # screenshot functionality
    slurp # screenshot functionality
    glib # gsettings

    gnome3.adwaita-icon-theme  # default gnome cursors
    # wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm

    # xorg.xkill
    st
    lxterminal
    yubioath-desktop
    yubikey-personalization-gui
    yubikey-personalization
    yubico-piv-tool
    vivaldi
    firefox-esr
    pavucontrol
    qpdfview
    thunderbird
    nextcloud-client
    gnucash
    gnuplot
    sxiv
    surf
    gimp
    screen-message
    gajim
    signal-desktop
    tdesktop
    kicad
    texmaker
    glxinfo
    apache-directory-studio
    wpa_supplicant_gui
    discord
    element-desktop
    gajim
    hdfview
    jetbrains.idea-community
    lxterminal
    mumble
    qucs
    rdesktop
    scrot
    spotify
    tigervnc
    wireshark-qt
    zoom-us
    zotero
  ];
}
