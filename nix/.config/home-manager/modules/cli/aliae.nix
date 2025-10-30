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
  (config.lib.neg.mkWhen hasAliae {
    programs.aliae.enable = true;
    # Note: shell init is handled by Aliae per-shell init snippets.
    # This repo links full zsh config from dotfiles; add the recommended
    # `aliae init <shell>` snippet there if not injected automatically.
  })

  # Soft warning if package is missing
  (config.lib.neg.mkUnless hasAliae {
    warnings = [
      "Aliae is not available in the pinned nixpkgs; skip enabling programs.aliae."
    ];
  })
]

