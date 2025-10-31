_final: prev: {
  # Force hyprland-qtutils to a known-good version (0.1.5)
  hyprland-qtutils = prev.hyprland-qtutils.overrideAttrs (old: let
    version = "0.1.5";
  in {
    inherit version;
    src = prev.fetchFromGitHub {
      owner = "hyprwm";
      repo = "hyprland-qtutils";
      tag = "v${version}";
      hash = "sha256-bTYedtQFqqVBAh42scgX7+S3O6XKLnT6FTC6rpmyCCc=";
    };
    # Work around CMake error: Qt6::WaylandClientPrivate target not found
    prePatch =
      (old.prePatch or "")
      + ''
        for f in $(grep -RIl "Qt6::WaylandClientPrivate" utils || true); do
          sed -i 's/Qt6::WaylandClientPrivate/Qt6::WaylandClient/g' "$f"
        done
      '';
  });

  # Avoid pulling hyprland-qtutils into Hyprland runtime closure
  # Some downstream overlays add qtutils to PATH wrapping; disable that.
  hyprland = prev.hyprland.override {wrapRuntimeDeps = false;};

  # Nyxt 4 pre-release binary (Electron/Blink backend). Upstream provides a single self-contained
  # ELF binary for Linux. Package it as a convenience while no QtWebEngine build is available.
  nyxt4-bin = prev.stdenvNoCC.mkDerivation rec {
    pname = "nyxt4-bin";
    version = "4.0.0-pre-release-13";

    src = prev.fetchurl {
      url = "https://github.com/atlas-engineer/nyxt/releases/download/${version}/Linux-Nyxt-x86_64.tar.gz";
      # Note: despite the name, this is a single ELF binary (static-pie).
      hash = "sha256-0z68029xwg9af55ivykvq5v3l3aldl5y8x3i8i3x20zw4qdk02i4";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm0755 "$src" "$out/bin/nyxt"
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Nyxt 4 pre-release (Electron/Blink) binary";
      homepage = "https://nyxt.atlas.engineer";
      license = licenses.bsd3;
      platforms = [ "x86_64-linux" ];
      mainProgram = "nyxt";
      maintainers = with maintainers; [ ];
    };
  };
}
