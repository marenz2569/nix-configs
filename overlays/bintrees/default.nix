{ lib, python39Packages, fetchFromGitHub, ... }:

with python39Packages;
buildPythonPackage rec {
  pname = "bintrees";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "mozman";
    repo = "bintrees";
    rev = "v${version}";
    sha256 = "sha256-/4GQ/wgr3LQBNlHJlkRJy/Mb6/P6s0pcxKScZzUhPBg=";
  };

  propagatedBuildInputs = [ cython ];
}
