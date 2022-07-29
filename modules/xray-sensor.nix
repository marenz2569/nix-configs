{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ gxs700 ];

  services.udev.packages = with pkgs; [ gxs700 ];
}
