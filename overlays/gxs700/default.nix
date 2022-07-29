{ buildPythonApplication, fetchFromGitHub, python }:

buildPythonApplication rec {
  pname = "gxs700";
  version = "f83c8aab6dcc370dbb900417b60ee565f1314790";

  src = fetchFromGitHub {
    owner = "JohnDMcMaster";
    repo = "gxs700";
    rev = "${version}";
    sha256 = "sha256-S0ZwMZTYIxtVstQeAk1Irr5SZKGD04kR0mYtSC10HaA=";
  };

  propagatedBuildInputs = with python.pkgs; [ libusb1 numpy pillow scipy ];

  postInstall = ''
    mkdir -p $out/etc/udev/rules.d
    cp ${./99-gxs700.rules} $out/etc/udev/rules.d/99-gxs700.rules
  '';
}
