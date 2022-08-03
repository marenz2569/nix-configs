{ lib, buildPythonApplication, fetchFromGitHub, python }:

buildPythonApplication rec {
  pname = "sway-layout";
  version = "0.0.0";

  src = ./.;

  propagatedBuildInputs = with python.pkgs; [ i3ipc ];

  meta = with lib; {
    description = "i3's append_layout feature for sway";
    homepage =
      "https://github.com/swaywm/sway/pull/6435#issuecomment-1030609610";
    license = licenses.mpl20;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
