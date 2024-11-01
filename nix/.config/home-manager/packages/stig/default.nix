{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "stig";
  version = "0.12.11a0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rndusr";
    repo = "stig";
    rev = "v${version}";
    hash = "sha256-12weO+wbdhqvxb4hoEYhtWHhF3HYCZCiI1zSDWFpVnQ=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "stig"
  ];

  meta = {
    description = "TUI and CLI for the BitTorrent client Transmission";
    homepage = "https://github.com/rndusr/stig";
    changelog = "https://github.com/rndusr/stig/blob/${src.rev}/CHANGELOG";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "stig";
  };
}
