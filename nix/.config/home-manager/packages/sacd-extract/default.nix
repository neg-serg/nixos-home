{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libxml2,
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
    libxml2
  ];

  installPhase = ''
    install -D sacd_extract -t $out/bin/
  '';

  meta = with lib; {
    description = "extract tracks of sacd iso image";
    homepage = "https://github.com/sound-linux-more/sacd-extract";
    changelog = "https://github.com/sound-linux-more/sacd-extract/blob/${src.rev}/changelog";
    mainprogram = "sacd-extract";
    platforms = platforms.all;
  };
}
