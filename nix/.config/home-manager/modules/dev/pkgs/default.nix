{ pkgs, lib, config, ... }:
let
  inherit (lib) optionals;
  groups = with pkgs; rec {
    formatters = [ shfmt stylua ];
    analyzers = [ flawfinder mypy ];
    codecount = [ cloc scc tokei ];
    radicle = [ radicle-node radicle-explorer ];
    runtime = [ nodejs_24 ];
    misc = [ deheader ];
  };
in {
  home.packages =
    (optionals config.features.dev.pkgs.formatters groups.formatters)
    ++ (optionals config.features.dev.pkgs.analyzers groups.analyzers)
    ++ (optionals config.features.dev.pkgs.codecount groups.codecount)
    ++ (optionals config.features.dev.pkgs.radicle groups.radicle)
    ++ (optionals config.features.dev.pkgs.runtime groups.runtime)
    ++ (optionals config.features.dev.pkgs.misc groups.misc);
}
