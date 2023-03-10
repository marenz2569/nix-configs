{ pkgs, ... }: {
  services.udev.extraRules = ''
    ACTION=="bind", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="1366", ENV{ID_MODEL_ID}=="1015", RUN+="${pkgs.libvirt}/bin/virsh attach-device win10-2 /etc/hostdev-segger-jlink.xml"
    ACTION=="remove", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="1366", ENV{ID_MODEL_ID}=="1015", RUN+="${pkgs.libvirt}/bin/virsh detach-device win10-2 /etc/hostdev-segger-jlink.xml"
  '';

  # for connecting jlink to a windows vm
  environment.etc."hostdev-segger-jlink.xml".text = ''
    <hostdev mode='subsystem' type='usb'>
      <source>
        <vendor id='0x1366'/>
        <product id='0x1015'/>
      </source>
    </hostdev>
  '';

  environment.systemPackages = with pkgs; [ cargo-flash avrdude segger-jlink ];
  services.udev.packages = with pkgs; [ probe-rs-udev segger-jlink ];

  nixpkgs.config.segger-jlink.acceptLicense = true;
}
