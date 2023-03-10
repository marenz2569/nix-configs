{ pkgs, ... }: {
  hardware.hackrf.enable = true;
  hardware.rtl-sdr.enable = true;

  environment.systemPackages = with pkgs; [ gqrx inspectrum sigdigger baudline cubicsdr limesuite ];
  services.udev.packages = with pkgs; [ limesuite ];
}
