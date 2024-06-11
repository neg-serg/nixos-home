{ lib
, python3
, fetchFromGitHub
}:

python3.pkgs.buildPythonApplication rec {
  pname = "alluvium";
  version = "unstable-2020-08-22";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "martenlienen";
    repo = "alluvium";
    rev = "9eef3c9be008738ee72dddc7532e33f5680a56ff";
    hash = "sha256-iDTrJVZDOSuQFiR6myLYkS+80nQYx/RKpQspPPdxxOk=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
    python3.pkgs.pygobject3
    python3.pkgs.i3ipc
  ];

  pythonImportsCheck = [ "alluvium" ];

  meta = with lib; {
    description = "Generate visual overlays from your i3 bindings";
    homepage = "https://github.com/martenlienen/alluvium";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "alluvium";
  };
}
