{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, stdenv
, darwin
, wayland
, xorg
}:

rustPlatform.buildRustPackage rec {
  pname = "clipboard-sync";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "dnut";
    repo = "clipboard-sync";
    rev = version;
    hash = "sha256-gme5pwQrwQbk8MroF/mGYqlY6hcjM5cHKHL7Y3nlW9k=";
  };

  cargoHash = "sha256-/LGRgml+iNwoMrMCmDesCpXA1qgWKauuqM540SZMS3Y=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
    darwin.apple_sdk.frameworks.CoreGraphics
  ] ++ lib.optionals stdenv.isLinux [
    wayland
    xorg.libxcb
  ];

  meta = with lib; {
    description = "Synchronizes the clipboard across multiple X11 and wayland instances running on the same machine";
    homepage = " https://github.com/dnut/clipboard-sync";
    license = licenses.unfree; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ ];
    mainProgram = "clipboard-sync";
  };
}
