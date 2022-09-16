{ pkgs, ... }: {
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "dvorak";
    libinput = {
      enable = true;
      touchpad = { tapping = false; };
    };
    updateDbusEnvironment = true;
    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+i3";
    windowManager.i3 = {
      enable = true;
      configFile = "/etc/i3.conf";
      extraPackages = with pkgs; [ dmenu i3status i3lock feh ];
    };
    wacom.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xorg.xkill
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
    prusa-slicer
    solvespace
    ghidra
    freecad
  ];
}
