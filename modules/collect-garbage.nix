{ ... }: {
  nix.gc = {
    dates = "weekly";
    automatic = true;
    options = "-d";
  };
}
