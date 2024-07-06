{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "i3-balance-workspace";
  version = "1.8.6";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "atreyasha";
    repo = "i3-balance-workspace";
    rev = "v${version}";
    hash = "sha256-ejqaL+qbtUCbDtj8EbnKbTTmgW8Q4McynOwYnluxz+w=";
  };

  nativeBuildInputs = [
    python3.pkgs.poetry
    python3.pkgs.poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    i3ipc
  ];

  pythonImportsCheck = ["i3_balance_workspace"];

  meta = with lib; {
    description = "Balance windows and workspaces in i3wm";
    homepage = "https://github.com/atreyasha/i3-balance-workspace";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "i3-balance-workspace";
  };
}
