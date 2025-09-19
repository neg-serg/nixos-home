{
  pkgs,
  self,
  system,
}: let
  # Formatters-only check (auto-fixes applied in a throwaway copy, then fail on diff)
  fmtCheck =
    pkgs.runCommand "fmt-check" {
      nativeBuildInputs = [
        pkgs.treefmt
        pkgs.alejandra
        pkgs.statix
        pkgs.deadnix
        pkgs.shfmt
        pkgs.shellcheck
        pkgs.black
        pkgs.ruff
        pkgs.findutils
        pkgs.gnugrep
      ];
      src = ./.;
    } ''
      set -euo pipefail
      # Work on a writable copy of the repo
      cp -r "$src" ./src
      chmod -R u+w ./src
      cd ./src
      # Ensure cache dir is writable for treefmt/formatters
      export XDG_CACHE_HOME="$PWD/.cache"
      mkdir -p "$XDG_CACHE_HOME"
      # 1) Strict Nix formatting check (alejandra only)
      cat > ./.treefmt-check.toml <<'EOF'
      [global]
      excludes = ["flake.lock", ".git/*", "secrets/crypted/*"]
      [formatter.nix]
      command = "alejandra"
      options = ["-q"]
      includes = ["*.nix"]
      [formatter.shfmt]
      command = "shfmt"
      options = ["-w", "-i", "2", "-ci", "-bn", "-sr"]
      includes = ["**/*.sh", "**/*.bash"]
      [formatter.black]
      command = "black"
      options = ["--quiet", "--line-length", "100"]
      includes = ["**/*.py"]
      [formatter.ruff]
      command = "ruff"
      options = ["--fix"]
      includes = ["**/*.py"]
      EOF
      treefmt --config-file ./.treefmt-check.toml --fail-on-change .
      touch "$out"
    '';

  # Lints-only check (no formatters, fail-only)
  lintCheck =
    pkgs.runCommand "lint" {
      nativeBuildInputs = [
        pkgs.statix
        pkgs.deadnix
        pkgs.findutils
        pkgs.gnugrep
        pkgs.shellcheck
      ];
      src = ./.;
    } ''
      set -euo pipefail
      cp -r "$src" ./src
      chmod -R u+w ./src
      cd ./src

      # 1) Lint checks: statix (no writes)
      statix check -- .

      # 2) Dead code check: deadnix (no writes, fail on findings)
      deadnix --fail .

      # 3) Shell lint (POSIX): only *.sh and *.bash to avoid zsh files
      if find . -type f \( -name '*.sh' -o -name '*.bash' \) -print -quit | grep -q .; then
        find . -type f \( -name '*.sh' -o -name '*.bash' \) -print0 \
          | xargs -0 shellcheck -S style -x
      fi
      # 4) Style guard: discourage `with pkgs; [ ... ]` lists and FHS targetPkgs using `with pkgs`
      if grep -R -nE --include='*.nix' --exclude='flake/checks.nix' --exclude='checks.nix' 'with[[:space:]]+pkgs;[[:space:]]*\[' . | grep -q .; then
        echo 'Found discouraged pattern: use explicit pkgs.* items instead of `with pkgs; [...]`' >&2
        grep -R -nE --include='*.nix' --exclude='flake/checks.nix' --exclude='checks.nix' 'with[[:space:]]+pkgs;[[:space:]]*\[' . || true
        exit 1
      fi
      if grep -R -nE --include='*.nix' --exclude='flake/checks.nix' --exclude='checks.nix' 'targetPkgs[[:space:]]*=[[:space:]]*pkgs:[[:space:]]*with[[:space:]]+pkgs' . | grep -q .; then
        echo 'Found discouraged pattern in FHS targetPkgs: avoid `with pkgs`' >&2
        grep -R -nE --include='*.nix' --exclude='flake/checks.nix' --exclude='checks.nix' 'targetPkgs[[:space:]]*=[[:space:]]*pkgs:[[:space:]]*with[[:space:]]+pkgs' . || true
        exit 1
      fi
      touch "$out"
    '';
in
  let
    hasDocs = builtins.hasAttr "docs" self && builtins.hasAttr system self.docs;
    hasFeaturesMd = hasDocs && builtins.hasAttr "features-options-md" self.docs.${system};
    hasFeaturesJson = hasDocs && builtins.hasAttr "features-options-json" self.docs.${system};
  in {
    fmt-check = fmtCheck;
    lint = lintCheck;
    # Back-compat: keep old 'treefmt' name
    treefmt = fmtCheck;

    # Build the options documentation as part of checks
    options-md = pkgs.runCommand "options-md" {} ''
      cp ${self.docs.${system}.options-md} "$out"
    '';
  } // pkgs.lib.optionalAttrs hasFeaturesMd {
    features-options-md = pkgs.runCommand "features-options-md" {} ''
      cp ${self.docs.${system}.features-options-md} "$out"
    '';
  } // pkgs.lib.optionalAttrs hasFeaturesJson {
    features-options-json = pkgs.runCommand "features-options-json" {} ''
      cp ${self.docs.${system}.features-options-json} "$out"
    '';
  }
