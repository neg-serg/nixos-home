{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "i3lock-fancy-rapid";
  version = "unstable-2022-01-28";

  src = fetchFromGitHub {
    owner = "ouzu";
    repo = "i3lock-fancy-rapid";
    rev = "9b6af6b29db3582eb71ace7a0ec6c3d14b9f8212";
    hash = "sha256-5JuRsdrzmWKapa3JHEvQlAhTmEMb3TPJIYQePu9LcDc=";
  };

  meta = with lib; {
    description = "A faster implementation of i3lock-fancy";
    homepage = "https://github.com/ouzu/i3lock-fancy-rapid";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
    mainProgram = "i3lock-fancy-rapid";
    platforms = platforms.all;
  };
}
