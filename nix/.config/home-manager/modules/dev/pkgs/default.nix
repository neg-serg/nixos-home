{
  lib,
  pkgs,
  config,
  ...
}: let
  groups = with pkgs; rec {
    formatters = [
      shfmt # shell script formatter
      black # Python formatter
      stylua # Lua code formatter
    ];
    analyzers = [
      flawfinder # examine C/C++ code for security flaws
      ruff # Python linter
      shellcheck # shell linter
      mypy # optional static typing checker for Python
    ];
    codecount = [
      cloc # count lines of code
      scc # fast, parallel code counter
      tokei # blazingly fast code counter
    ];
    radicle = [
      radicle-node # Radicle server/node
      radicle-explorer # Web frontend for Radicle
    ];
    runtime = [
      nodejs_24 # Node.js runtime (npm/yarn tooling)
    ];
    misc = [
      deheader # remove unneeded C/C++ includes
    ];

    # Haskell toolchain and related tools
    haskell =
      [
        ghc
        cabal-install
        stack
        haskell-language-server
        hlint
        ormolu
        ghcid
      ]
      # Some Haskell tools may be unavailable on a given nixpkgs pin — include conditionally.
      ++ (lib.optionals (pkgs ? fourmolu) [ pkgs.fourmolu ])
      ++ (lib.optionals (pkgs ? hindent) [ pkgs.hindent ]);

    # IaC backend package (Terraform or OpenTofu) controlled by
    # features.dev.iac.backend (default: "terraform").
    iac = let
      backend = config.features.dev.iac.backend or "terraform";
      main =
        if backend == "tofu"
        then opentofu
        else terraform;
    in [main ansible];
  };
in
  lib.mkIf config.features.dev.enable {
    home.packages =
      let
        flags = (config.features.dev.pkgs or {}) // {
          haskell = config.features.dev.haskell.enable or false;
        };
      in config.lib.neg.pkgsList (
        config.lib.neg.mkEnabledList flags groups
      );
  }
