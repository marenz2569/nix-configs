{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "probe-rs-udev";

  src = fetchurl {
    url = "https://probe.rs/files/69-probe-rs.rules";
    sha256 = "1q51lhl2xm8i7mdasgv6wdxvbz3ihfzsc4mw4ks6725k5cc0nzsp";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/etc/udev/rules.d
    cp $src $out/etc/udev/rules.d/69-probe-rs.rules
  '';
}
