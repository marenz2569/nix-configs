{ stdenv, lib, bash, makeWrapper, fontconfig, freetype, dbus, zlib }:
let rpath = lib.makeLibraryPath [ fontconfig freetype dbus zlib ];
in stdenv.mkDerivation rec {
  pname = "vampir";
  version = "10.1.0";

  # fetchurlBoot uses nix to fetch the package with the netrc-file option in nix.conf
  src = stdenv.fetchurlBoot {
    url =
      "https://intern.vampir.eu/Release_${version}/vampir-${version}-linux-x86_64-setup.sh";
    sha256 = "sha256-an99fpKLKEqRb4AvXLGIOjy1R9ERqUsV2iw2GljcQQo=";
  };

  # make shure we don't leak the binary
  preferLocalBuild = true;
  allowSubstitutes = false;

  unpackPhase = ''
    mkdir $out
    mkdir $out/etc

    /bin/sh $src --create-tar
    tar -xvf Vampir-${version}-Linux.tar.gz -C $out
  '';

  phases = [ "unpackPhase" "postFixup" ];

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/bin/vampir" || true
    patchelf --set-rpath ${rpath} "$out/bin/vampir" || true
    wrapProgram $out/bin/vampir --set QT_XKB_CONFIG_ROOT "/usr/share/X11/xkb" --run "ulimit -n 1124"
  '';

  meta = with lib; {
    description = "Vampir - Performance Optimization";
    homepage = "https://vampir.eu";
    license = licenses.unfree;
    maintainers = with maintainers; [ marenz ];
    platforms = platforms.linux;
  };
}
