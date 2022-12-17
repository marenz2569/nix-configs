{ lib, python39Packages, fetchFromGitHub, ... }:

with python39Packages;
buildPythonPackage rec {
  pname = "minepy";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "minepy";
    repo = "minepy";
    rev = version;
    sha256 = "sha256-fWJ5EJKqH0WdwgzqOfCT0YBwoN36Lu9GkLOsnGCCtDc=";
  };

  propagatedBuildInputs = [ numpy ];
}
