{ lib
, stdenv
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "sacd-extract";
  version = "0.3.9.3";

  src = fetchFromGitHub {
    owner = "Sound-Linux-More";
    repo = "sacd-extract";
    rev = version;
    hash = "sha256-Iz5Ku8bmEUV/DQkMjuo3gCzXT/yEwPlw4zr5Dl+SRuY=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    description = "Extract tracks of SACD ISO image";
    homepage = "https://github.com/Sound-Linux-More/sacd-extract";
    changelog = "https://github.com/Sound-Linux-More/sacd-extract/blob/${src.rev}/CHANGELOG";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "sacd-extract";
    platforms = platforms.all;
  };
}
