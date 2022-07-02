{ pkgs, ... }:
{
  hardware.hackrf.enable = true;
  hardware.rtl-sdr.enable = true;

  environment.systemPackages = with pkgs; [
    gqrx
    inspectrum
  ];
}