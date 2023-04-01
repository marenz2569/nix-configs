{ buildPythonApplication, fetchFromGitHub, python }:

buildPythonApplication rec {
  pname = "anchore-cli";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "anchore";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FHYvpeFUoowbjdO23Wj4zwq5HZHsacZ07r9rtF5GuzQ=";
  };

  patches = [ ./requirements.patch ];

  installCheckPhase = false;
  dontUseSetuptoolsCheck = true;

  propagatedBuildInputs = with python.pkgs; [
    click
    prettytable
    python-dateutil
    pyyaml
    requests
    six
    urllib3
  ];
}
