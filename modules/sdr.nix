{ pkgs, ... }: {
  hardware.hackrf.enable = true;
  hardware.rtl-sdr.enable = true;

  services.sdrplayApi.enable = true;
  nixpkgs.overlays = [
    (self: super: {
      soapysdr-with-plugins = super.soapysdr-with-plugins.override {
        extraPackages = with super; [
          limesuite
          soapyairspy
          soapyaudio
          soapybladerf
          soapyhackrf
          soapyremote
          soapyrtlsdr
          soapyuhd
          soapysdrplay
        ];
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    gqrx
    inspectrum
    sigdigger
    baudline
    cubicsdr
    limesuite
  ];
  services.udev.packages = with pkgs; [ limesuite ];
}
