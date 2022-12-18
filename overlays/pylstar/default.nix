{ lib, buildPythonPackage, fetchFromGitHub, ... }:

buildPythonPackage rec {
  pname = "pylstar";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "gbossert";
    repo = pname;
    rev = "Releases/${pname}-${version}";
    sha256 = "sha256-aIuJ9OBMtO1h01MPgWLHaMEJ/4Alw02FgMXqBnmhgDk=";
  };
}
