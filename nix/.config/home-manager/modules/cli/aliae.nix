{
  lib,
  config,
  pkgs,
  xdg,
  ...
}:
let
  hasAliae = pkgs ? aliae;
in
lib.mkMerge [
  # Enable Aliae when available in current nixpkgs
  (lib.mkIf hasAliae (lib.mkMerge [
    { programs.aliae.enable = true; }
    # Provide a minimal, cross-shell alias set via XDG config.
    # Format: YAML (aliases mapping). Safe defaults mirror Nushell aliases.
    (xdg.mkXdgText "aliae/config.yaml" ''
      # Aliae aliases (cross-shell)
      # Edit and reload your shell to apply changes.
      aliases:
        l:   "eza --icons=auto --hyperlink"
        ll:  "eza --icons=auto --hyperlink -l"
        lsd: "eza --icons=auto --hyperlink -alD --sort=created --color=always"
        cat: "bat -pp"
        g:   "git"
        gs:  "git status -sb"
        mp:  "mpv"
    '')
  ]))

  # Soft warning if package is missing
  (lib.mkIf (! hasAliae) {
    warnings = [
      "Aliae is not available in the pinned nixpkgs; skip enabling programs.aliae."
    ];
  })
]
