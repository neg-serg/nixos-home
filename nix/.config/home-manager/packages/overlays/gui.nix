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
  });

  # Avoid pulling hyprland-qtutils into Hyprland runtime closure
  # Some downstream overlays add qtutils to PATH wrapping; disable that.
  hyprland = prev.hyprland.override { wrapRuntimeDeps = false; };
}
