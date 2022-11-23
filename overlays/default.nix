{ nixpkgs-unstable, sdr-nix, ... }:
_final: prev:
let
  pkgs-unstable = import nixpkgs-unstable { system = prev.system; };
  flutterPackages = prev.lib.recurseIntoAttrs (prev.callPackage "${nixpkgs-unstable}/pkgs/development/compilers/flutter" { });
in {
  gxs700 = prev.python3Packages.callPackage ./gxs700 { };
  ncpamixer = prev.ncpamixer.overrideAttrs (_oldAttrs: {
    version = "unstable-2021-10-21";

    src = prev.fetchFromGitHub {
      owner = "fulhax";
      repo = "ncpamixer";
      rev = "4faf8c27d4de55ddc244f372cbf5b2319d0634f7";
      sha256 = "sha256-ElbxdAaXAY0pj0oo2IcxGT+K+7M5XdCgom0XbJ9BxW4=";
    };

    configurePhase = "	make PREFIX=$out USE_WIDE=1 RELEASE=1 build/Makefile\n";
  });
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
}
