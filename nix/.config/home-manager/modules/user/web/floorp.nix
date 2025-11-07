{
  config,
  pkgs,
  lib,
  faProvider ? null,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.floorp.enable) (let
  common = import ./mozilla-common-lib.nix {inherit lib pkgs config faProvider;};
  # Floorp upstream source package is deprecated in nixpkgs >= 12.x; always use floorp-bin.
  floorpPkg = pkgs.floorp-bin;

in
  lib.mkMerge [
    (common.mkBrowser {
      name = "floorp";
      package = floorpPkg;
      # Floorp uses flat profile tree; keep explicit id
      profileId = "bqtlgdxw.default";
      # Keep navbar on top for Floorp.
      # Rationale:
      # - Floorp ships heavy UI theming (Lepton‑style tweaks); bottom pinning adds brittle CSS
      #   overrides and regresses with upstream changes (urlbar popup, engine badges, panels).
      # - Extension panels and some popups mis‑position when the navbar is fixed to bottom;
      #   stock top navbar avoids those edge cases.
      # - We keep minimal, safe tweaks (findbar polish, compact tabs) and skip bottom pinning.
      # Opt‑in (unsupported): set bottomNavbar = true and maintain custom CSS locally.
      bottomNavbar = false;
      # Return to stock UI (no injected userChrome tweaks)
      vanillaChrome = true;
    })
    {
      home.sessionVariables = {
        MOZ_DBUS_REMOTE = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };
    }
  ])
