{ nixpkgs-unstable, ... }:
_final: prev:
let
  pkgs-unstable = import nixpkgs-unstable { system = prev.system; };
  flutterPackages = prev.lib.recurseIntoAttrs
    (prev.callPackage "${nixpkgs-unstable}/pkgs/development/compilers/flutter"
      { });
in {
  anchore-cli = prev.python3Packages.callPackage ./anchore-cli { };
  gxs700 = prev.python3Packages.callPackage ./gxs700 { };
  st = prev.st.override { conf = builtins.readFile ./st/st.h; };
  vampir = prev.callPackage ./vampir { };
  nixLatest = pkgs-unstable.nix;
  probe-rs-udev = prev.callPackage ./probe-rs-udev { };
  ida-free = prev.callPackage ./ida-free { };
  # flutter = flutterPackages.stable.overrideAttrs(oldAttrs: {
  #   startScript = ''
  #     #!${prev.bash}/bin/bash
  #     export CHROME_EXECUTABLE=${prev.google-chrome}/bin/google-chrome-stable
  #   '' + oldAttrs.startScript;
  # });
  sigdigger = if prev.libsndfile.version == "1.1.0" then
    prev.sigdigger.override {
      libsndfile = prev.libsndfile.overrideAttrs (oldAttrs: rec {
        version = "1.2.0";
        src = prev.fetchFromGitHub {
          owner = oldAttrs.pname;
          repo = oldAttrs.pname;
          rev = version;
          sha256 = "sha256-zd0HDUzVYLyFjhIudBJQaKJUtYMjZeQRLALSkyD9tXU=";
        };
      });
    }
  else
    prev.sigdigger;
  vesc-tool = prev.libsForQt5.callPackage ./vesc-tool { };
  sieve = prev.callPackage ./sieve { };
  rtlsdr-to-gqrx = prev.callPackage ./rtlsdr-to-gqrx { };
  python39 = prev.python39.override {
    packageOverrides = final: prev: {
      bintrees = final.callPackage ./bintrees { };
      minepy = final.callPackage ./minepy { };
      pylstar = final.callPackage ./pylstar { };
      netzob = final.callPackage ./netzob { };
    };
  };
}
