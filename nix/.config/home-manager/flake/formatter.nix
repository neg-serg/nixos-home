{ pkgs }:
pkgs.writeShellApplication {
  name = "fmt";
  runtimeInputs = [
    pkgs.alejandra # Nix formatter
    pkgs.black # Python formatter
    pkgs.deadnix # find dead Nix code
    pkgs.ruff # Python linter/fixer
    pkgs.shellcheck # shell linter
    pkgs.shfmt # shell formatter
    pkgs.statix # Nix linter
    pkgs.treefmt # tree-wide formatter orchestrator
  ];
  text = ''
    set -euo pipefail
    # Use project-local config to keep path inside tree root for treefmt
    exec treefmt -c treefmt.toml "$@"
  '';
}

