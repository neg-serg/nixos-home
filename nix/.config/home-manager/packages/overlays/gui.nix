_final: prev: {
  kitty = prev.kitty.overrideAttrs (old: let
    lib = prev.lib;
    disablePatch = "disable-test_ssh_bootstrap_with_different_launchers.patch";
    filteredPatches =
      lib.filter (patch: !(lib.hasSuffix disablePatch (toString patch))) (old.patches or []);
  in {
    version = "${old.version or "0.44.0"}-mamkin-2025-02-07";
    src = prev.fetchFromGitHub {
      owner = "mamkin-skuf";
      repo = "kitty";
      rev = "c3ed945a93f6ca2b56dfd25d7558f951be49e15a";
      hash = "sha256-kf6MkFhZgOKFYDJY93EXw+0ZMXIG1dSIGAjN5j8DsWk=";
    };
    patches = filteredPatches ++ [ ../patches/kitty-disable-zsh-launcher.patch ];
  });
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
      hash = "sha256-9kwgLVvnqXJnL/8jdY2jly/bS2XtgF9WBsDeoXNHX8M=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/bin"
      if gzip -t "$src" >/dev/null 2>&1; then
        # Some releases ship a gzipped single binary under a misleading name.
        gzip -dc "$src" > "$out/bin/nyxt"
        chmod 0755 "$out/bin/nyxt"
      else
        install -Dm0755 "$src" "$out/bin/nyxt"
      fi
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
