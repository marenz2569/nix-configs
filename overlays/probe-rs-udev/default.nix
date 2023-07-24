{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "probe-rs-udev";

  src = fetchurl {
    url = "https://probe.rs/files/69-probe-rs.rules";
    hash = "sha256-PBvAdQMaKdX7bMzkrnb5I5RadrZw/bHiIUaxAKcLfZU=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/etc/udev/rules.d
    cp $src $out/etc/udev/rules.d/69-probe-rs.rules
  '';
}
