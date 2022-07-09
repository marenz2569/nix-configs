{ ... }: {
  # udev rules for the x-ray sensors
  services.udev.extraRules = ''
    # Dexis Platinum
    # Pre renumeration
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5328", ATTR{idProduct}=="2009", MODE="0666"
    # Post enumeration
    # In theory...although I guess I'm loading the same (wrong?) FW for both
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5328", ATTR{idProduct}=="2010", MODE="0666"
    # Gendex GX700 (large)
    # Pre renumeration
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5328", ATTR{idProduct}=="202f", MODE="0666"
    # Post renumeration
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5328", ATTR{idProduct}=="2030", MODE="0666"
    # Gendex GX700 (small)
    # Pre renumeration
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5328", ATTR{idProduct}=="201f", MODE="0666"
    # Post renumeration
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="5328", ATTR{idProduct}=="2020", MODE="0666"
  '';
}
