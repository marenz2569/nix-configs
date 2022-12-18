{ nixpkgs-unstable, sdr-nix, ... }:
_final: prev:
let
  pkgs-unstable = import nixpkgs-unstable { system = prev.system; };
  flutterPackages = prev.lib.recurseIntoAttrs (prev.callPackage "${nixpkgs-unstable}/pkgs/development/compilers/flutter" { });
in {
  gxs700 = prev.python3Packages.callPackage ./gxs700 { };
  st = prev.st.override { conf = builtins.readFile ./st/st.h; };
  vampir = prev.callPackage ./vampir { };
  nixLatest = pkgs-unstable.nix;
  probe-rs-udev = prev.callPackage ./probe-rs-udev { };
  ida-free = prev.callPackage ./ida-free { };
  flutter = flutterPackages.stable.overrideAttrs(oldAttrs: {
    startScript = ''
      #!${prev.bash}/bin/bash
      export CHROME_EXECUTABLE=${prev.google-chrome}/bin/google-chrome-stable
    '' + oldAttrs.startScript;
  });
  SigDigger = sdr-nix.packages.${prev.system}.sigdigger.overrideAttrs(_oldAttrs: {
    pname = "SigDigger";
  });
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
