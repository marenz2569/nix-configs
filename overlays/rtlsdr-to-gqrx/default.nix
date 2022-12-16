{ stdenv, lib, fetchurl }:
stdenv.mkDerivation {
  name = "rtlsdr-to-gqrx";

  src = fetchurl {
    url = "https://gist.githubusercontent.com/DrPaulBrewer/917f990cc0a51f7febb5/raw/55d98d565eeb2f5b71f51764fd53e1004a16ff78/rtlsdr-to-gqrx.c";
    sha256 = "sha256-s4kHF+tMh1t5V7z8P9CpNq/+orwvqducATXt4iCeUW8=";
  };

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = "$CC $src -o rtlsdr-to-gqrx";

  installPhase = ''
    mkdir -p $out/bin
    cp rtlsdr-to-gqrx $out/bin
  '';
}
