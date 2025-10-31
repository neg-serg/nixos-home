{
  lib,
  perSystem,
  hy3,
  yandexBrowserInput,
  nur,
  inputs,
  hmInputs,
  extraSubstituters,
  extraTrustedKeys,
}: system: {
  inputs = hmInputs;
  inherit hy3;
  inherit (perSystem.${system}) iosevkaNeg;
  # Prefer Nyxt 4 / QtWebEngine variant when available from chaotic
  nyxt4 = let
    hasAttr = builtins.hasAttr;
    chaoticPkgs = inputs.chaotic.packages.${system} or null;
  in
    if chaoticPkgs == null then null
    else if hasAttr "nyxt4" chaoticPkgs then chaoticPkgs.nyxt4
    else if hasAttr "nyxt-qtwebengine" chaoticPkgs then chaoticPkgs."nyxt-qtwebengine"
    else if hasAttr "nyxt-qt" chaoticPkgs then chaoticPkgs."nyxt-qt"
    else null;
  # Flake cache settings for reuse in modules (single source of truth)
  caches = {
    substituters = extraSubstituters;
    trustedPublicKeys = extraTrustedKeys;
  };
  # Provide lazy providers to avoid evaluating inputs unless features enable them
  # Firefox addons via NUR
  faProvider = pkgs: (pkgs.extend nur.overlays.default).nur.repos.rycee.firefox-addons;
  # Lazy Yandex Browser provider
  yandexBrowserProvider = pkgs: yandexBrowserInput.packages.${pkgs.system};
  # GUI helpers
  qsProvider = pkgs: inputs.quickshell.packages.${pkgs.system}.default;
  iwmenuProvider = pkgs: inputs.iwmenu.packages.${pkgs.system}.default;
  bzmenuProvider = pkgs: inputs.bzmenu.packages.${pkgs.system}.default;
  rsmetrxProvider = pkgs: inputs.rsmetrx.packages.${pkgs.system}.default;
  # Provide xdg helpers directly to avoid _module.args fallback recursion
  xdg = import ../modules/lib/xdg-helpers.nix {
    inherit lib;
    inherit (perSystem.${system}) pkgs;
  };
}
