{ stdenv, lib, dbus, autoPatchelfHook, xorg, libGL, libxkbcommon, libglibutil
, cairo, libdrm, pango, gdk-pixbuf, gtk3, krb5, libsForQt5 }:
let
  pname = "idafree";
  version = "80";

  binary = "${pname}${version}_linux.run";

  installer = stdenv.mkDerivation rec {
    inherit version;

    pname = "idafree-installer";

    src = builtins.fetchurl {
      url = "https://out7.hex-rays.com/files/${binary}";
      sha256 = "sha256:045alqhgryzdzp708rcb4zs9ywj1f5gxgi2xlsfrbhn1v3lsbdfl";
    };

    phases = [ "installPhase" ];

    installPhase = ''
      mkdir -p $out/bin/
      cp $src $out/bin/${binary}
      chmod +wx $out/bin/${binary}
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/bin/${binary}"
    '';
  };
in stdenv.mkDerivation rec {
  inherit pname;
  inherit version;

  src = installer;

  nativeBuildInputs = [ autoPatchelfHook libsForQt5.qt5.wrapQtAppsHook ];

  buildInputs = [
    stdenv.cc.cc.lib
    dbus
    xorg.libxcb
    xorg.libX11
    xorg.libSM
    xorg.libICE
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    libGL
    libxkbcommon
    libglibutil
    cairo
    libdrm
    pango
    gdk-pixbuf
    gtk3
    krb5
    libsForQt5.qt5.qtbase
  ];

  installPhase = ''
    mkdir -p $out/bin
    $src/bin/${binary} --prefix $out --mode unattended
  '';

  postFixup = ''
    ln -s $out/ida64 $out/bin/idafree
  '';

  meta = with lib; {
    description =
      "IDA Freeware - The free binary code analysis tool to kickstart your reverse engineering experience.";
    homepage = "https://hex-rays.com/ida-free/";
    license = licenses.unfree;
    maintainers = with maintainers; [ marenz ];
    platforms = [ "x86_64-linux" ];
  };
}
