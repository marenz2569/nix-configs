{ lib, python39Packages, fetchFromGitHub, bintrees, minepy, pylstar, ... }:

with python39Packages;
buildPythonPackage rec {
  pname = "netzob";
  version = "4ceefe5abaac1b9343dcc7e4ae28b2616bc3eb00";

  src = fetchFromGitHub {
    owner = "netzob";
    repo = "netzob";
    rev = version;
    sha256 = "sha256-ux7Dq/OLr+UZPtJVHgrK4wFY4PtGOqMgAhPssFGa0n8=";
  };

  patches = [ ./unpin-requirements.patch ];

  preBuild = "cd netzob";

  propagatedBuildInputs = [ jsonpickle pcapy-ng netaddr bitarray numpy colorama bintrees minepy pylstar getmac ];

  doCheck = false;
}
