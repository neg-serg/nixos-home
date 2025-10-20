{
  description = "Shell app packaged with writeShellApplication";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in {
      packages = forAllSystems (pkgs: {
        default = pkgs.writeShellApplication {
          name = "mytool";
          runtimeInputs = [ ];
          text = ''
            #!/usr/bin/env bash
            set -euo pipefail
            echo "Hello from mytool"
          '';
        };
      });
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          name = "shell-app-dev";
          packages = [ pkgs.shellcheck pkgs.shfmt ];
        };
      });
    };
}

