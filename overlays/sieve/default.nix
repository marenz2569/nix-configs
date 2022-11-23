{ lib, fetchurl, appimageTools, ... }:
 appimageTools.wrapType2 {
  name = "sieve";
  src = fetchurl {
    url = "https://github.com/thsmi/sieve/releases/download/0.6.1/sieve-0.6.1-linux-x64.AppImage";
    sha256 = "sha256-tiA+wp7oMGmK3UPJRQ3NBrqVT+D0B6sT+npXUZ7zok8=";
  };
}
