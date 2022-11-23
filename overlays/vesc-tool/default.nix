{ stdenv, lib, qtbase, qmake, qtserialport, qtgamepad, qtquickcontrols2, wrapQtAppsHook, fetchFromGitHub }: 

let
	rev = "03fba5c4ea3ec975ed4324459d2ed072844c9b42";
in stdenv.mkDerivation {
  pname = "vesc_tool";
  version = "2022-11-22-${rev}";

	src = fetchFromGitHub {
		owner = "vedderb";
		repo = "vesc_tool";
    rev = rev;
    sha256 = "sha256-Pj1Y6KVFlsLRHr/uX2CRlV6xHkL3PCqbGpiyLOvOG58=";
	};

  patches = [ ./fix-build.patch ];

  nativeBuildInputs = [ qmake wrapQtAppsHook ]; 
  buildInputs = [ qtserialport qtgamepad qtquickcontrols2 ];
}
