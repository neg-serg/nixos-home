{ lib, pkgs }:
let
  devNixTools = [
    pkgs.alejandra # Nix formatter
    pkgs.age # modern encryption tool (for sops)
    pkgs.deadnix # find dead Nix code
    pkgs.git-absorb # autosquash fixups into commits
    pkgs.gitoxide # fast Rust Git tools
    pkgs.just # task runner
    pkgs.nil # Nix language server
    pkgs.sops # secrets management
    pkgs.statix # Nix linter
    pkgs.treefmt # formatter orchestrator
  ];
  rustBaseTools = [
    pkgs.cargo # Rust build tool
    pkgs.rustc # Rust compiler
  ];
  # Preserve the availability-guarded helper semantics
  rustExtraTools =
    with pkgs; [
      hyperfine # CLI benchmarking
      kitty # terminal (for graphics/testing)
      wl-clipboard # Wayland clipboard helpers
    ]
    ++ (
      let opt = path: items: lib.optionals (lib.hasAttrByPath path pkgs) items; in
      lib.concatLists [
        # Cross-building support for cargo-zigbuild
        (opt ["zig"] [ zig ])
        # Common native deps helpers
        (opt ["pkg-config"] [ pkg-config ])
        (opt ["openssl"] [ openssl openssl.dev ])
        # Useful cargo subcommands
        (opt ["cargo-nextest"] [ cargo-nextest ])
        (opt ["cargo-audit"] [ cargo-audit ])
        (opt ["cargo-deny"] [ cargo-deny ])
        (opt ["cargo-outdated"] [ cargo-outdated ])
        (opt ["cargo-bloat"] [ cargo-bloat ])
        (opt ["cargo-modules"] [ cargo-modules ])
        (opt ["cargo-zigbuild"] [ cargo-zigbuild ])
        (opt ["bacon"] [ bacon ])
      ]
    );
in {
  inherit devNixTools rustBaseTools rustExtraTools;
}

