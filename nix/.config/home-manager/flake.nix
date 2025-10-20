let
  extraSubstituters = [
    "https://nix-community.cachix.org"
    "https://hyprland.cachix.org"
    # Additional popular caches
    "https://numtide.cachix.org"
    "https://nixpkgs-wayland.cachix.org"
    "https://hercules-ci.cachix.org"
    "https://cuda-maintainers.cachix.org"
    "https://nix-gaming.cachix.org"
    # Personal cache
    "https://neg-serg.cachix.org"
  ];
  extraTrustedKeys = [
    # nix-community
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # Hyprland
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    # numtide
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    # nixpkgs-wayland
    "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    # hercules-ci
    "hercules-ci.cachix.org-1:ZZeDl9Va+xe9j+KqdzoBZMFJHVQ42Uu/c/1/KMC5Lw0="
    # cuda-maintainers
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    # nix-gaming
    "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    # personal cache
    "neg-serg.cachix.org-1:MZ+xYOrDj1Uhq8GTJAg//KrS4fAPpnIvaWU/w3Qz/wo="
  ];
in
{
  description = "Home Manager configuration of neg";
  # Global Nix configuration for this flake (affects local and CI when respected)
  # Single source of truth for caches; Home Manager modules receive these via mkHMArgs.caches
  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    # Keep literal lists here to avoid early-import pitfalls; modules reuse these values via mkHMArgs
    extra-substituters = extraSubstituters;
    extra-trusted-public-keys = extraTrustedKeys;
  };
  inputs = {
    bzmenu = {
      url = "github:e-tho/bzmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    homeManagerInput.follows = "home-manager";
    # Pin hy3 to a commit compatible with Hyprland v0.50.1 (GitHub archive available)
    hy3 = {
      # Pin to the last commit before hy3 switched to the new render API (CHyprColor)
      # to stay compatible with Hyprland v0.50.1 which expects a float alpha
      url = "github:outfoxxed/hy3?rev=1fdc0a291f8c23b22d27d6dabb466d018757243c"; # 2025-08-03^ commit
      # Ensure hy3 uses the same Hyprland input we pin below
      inputs.hyprland.follows = "hyprland";
    };
    # Pin Hyprland to a stable release to reduce API churn with hy3
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.50.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    iosevka-neg = {
      url = "git+ssh://git@github.com/neg-serg/iosevka-neg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    iosevkaNegInput.follows = "iosevka-neg";
    iwmenu = {
      url = "github:e-tho/iwmenu";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Nushell package manager (non-flake repo) to avoid vendoring sources
    nupm = {
      url = "github:nushell/nupm";
      flake = false;
    };
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rsmetrx = {
      url = "github:neg-serg/rsmetrx";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    sopsNixInput.follows = "sops-nix";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    stylixInput.follows = "stylix";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # CamelCase alias for convenience in code
    yandexBrowserInput.follows = "yandex-browser";
  };

  outputs = inputs @ {
    self,
    chaotic,
    homeManagerInput,
    hy3,
    iosevkaNegInput,
    nixpkgs,
    nur,
    sopsNixInput,
    stylixInput,
    yandexBrowserInput,
    ...
  }: let
    inherit (nixpkgs) lib;
    # Helpers for environment parsing (DRY)
    boolEnv = name: let v = builtins.getEnv name; in v == "1" || v == "true" || v == "yes";
    splitEnvList = name: let v = builtins.getEnv name; in
      if v == "" then [] else (lib.filter (s: s != "") (lib.splitString "," v));
    docs = import ./flake/features-docs.nix {inherit lib;};
    # Prefer evaluating only one system by default to speed up local eval.
    # You can override the systems list for CI or cross builds by setting
    # HM_SYSTEMS to a comma-separated list (e.g., "x86_64-linux,aarch64-linux").
    defaultSystem = "x86_64-linux";
    systems = let
      fromEnv = splitEnvList "HM_SYSTEMS";
      cleaned = lib.unique fromEnv;
    in if cleaned == [] then [ defaultSystem ] else cleaned;

    # Pass only minimal inputs required by HM modules (hyprland for asserts, nupm for Nushell).
    # Nilla raw-loader compatibility: add a synthetic type to each selected input.
    hmInputs = let
      selected = {
        inherit (inputs) hyprland;
        inherit (inputs) nupm;
      };
    in builtins.mapAttrs (_: input: input // { type = "derivation"; }) selected;

    # Common Home Manager building blocks
    hmBaseModules = {
      profile ? null,
      extra ? [],
    }: let
      base = [
        ./home.nix
        stylixInput.homeModules.stylix
        chaotic.homeManagerModules.default
        sopsNixInput.homeManagerModules.sops
      ];
      profMod = lib.optional (profile == "lite") (_: {features.profile = "lite";});
    in
      profMod ++ base ++ extra;

    mkHMArgs = system: {
      # Pass inputs mapped for Nilla raw-loader and common extras
      inputs = hmInputs;
      inherit hy3;
      inherit (perSystem.${system}) iosevkaNeg;
      # Flake cache settings for reuse in modules (single source of truth)
      caches = {
        substituters = extraSubstituters;
        trustedPublicKeys = extraTrustedKeys;
      };
      # Provide lazy providers to avoid evaluating inputs unless features enable them
      # Firefox addons via NUR
      faProvider = (pkgs: (pkgs.extend nur.overlays.default).nur.repos.rycee.firefox-addons);
      # Lazy Yandex Browser provider
      yandexBrowserProvider = (pkgs: yandexBrowserInput.packages.${pkgs.system});
      # GUI helpers
      qsProvider = (pkgs: inputs.quickshell.packages.${pkgs.system}.default);
      iwmenuProvider = (pkgs: inputs.iwmenu.packages.${pkgs.system}.default);
      bzmenuProvider = (pkgs: inputs.bzmenu.packages.${pkgs.system}.default);
      rsmetrxProvider = (pkgs: inputs.rsmetrx.packages.${pkgs.system}.default);
      # Provide xdg helpers directly to avoid _module.args fallback recursion
      xdg = import ./modules/lib/xdg-helpers.nix { inherit lib; pkgs = perSystem.${system}.pkgs; };
    };

    # Build per-system attributes in one place
    perSystem = lib.genAttrs systems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import ./packages/overlay.nix)
          ]; # local packages overlay under pkgs.neg.* (no global NUR overlay)
          config = {
            allowAliases = false;
          };
        };
        iosevkaNeg = iosevkaNegInput.packages.${system};
        # NUR is accessed lazily via faProvider in mkHMArgs only when needed.

        # Common toolsets for devShells to avoid duplication
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
        rustExtraTools =
          with pkgs; [
            hyperfine # CLI benchmarking
            kitty # terminal (for graphics/testing)
            wl-clipboard # Wayland clipboard helpers
          ]
          # Optional tools/utilities guarded by availability on this pin
          # Keep semantics identical to previous code via a tiny helper
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
        inherit pkgs iosevkaNeg;

        devShells = import ./flake/devshells.nix {
          inherit pkgs rustBaseTools rustExtraTools devNixTools;
        };

        packages =
          let
            extras = boolEnv "HM_EXTRAS";
          in {
            default = pkgs.zsh;
          } // lib.optionalAttrs extras {
            hy3Plugin = hy3.packages.${system}.hy3;
            bpf-host-latency = pkgs.neg.bpf_host_latency;
          };

        # Formatter: treefmt wrapper pinned to repo config
        formatter = pkgs.writeShellApplication {
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
        };

        # Checks: fail if formatting or linters would change files
        checks =
          (import ./flake/checks.nix {
            inherit pkgs self system;
          })
          ;
      }
    );

    # Use defaultSystem for user HM configs
  in {
    # Gate devShells/formatter under HM_EXTRAS; always keep defaultSystem for local dev.
    # This reduces multi-system eval noise in CI unless explicitly requested.
    devShells =
      let
        extras = boolEnv "HM_EXTRAS";
        sysList = if extras then systems else [ defaultSystem ];
      in lib.genAttrs sysList (s: perSystem.${s}.devShells);
    packages = lib.genAttrs systems (s: perSystem.${s}.packages);
    formatter =
      let
        extras = boolEnv "HM_EXTRAS";
        sysList = if extras then systems else [ defaultSystem ];
      in lib.genAttrs sysList (s: perSystem.${s}.formatter);
    # Docs outputs are gated by HM_DOCS env; heavy HM evals are skipped by default.
    docs = lib.genAttrs systems (
      s: let
        pkgs = perSystem.${s}.pkgs;
        docsEnabled = boolEnv "HM_DOCS";
        featureOptionsItems = docs.getFeatureOptionsItems ./modules/features.nix;
      in
        if docsEnabled then {
          options-md = pkgs.writeText "OPTIONS.md" (
            let
              evalCfg = mods:
                homeManagerInput.lib.homeManagerConfiguration {
                  inherit (perSystem.${s}) pkgs;
                  extraSpecialArgs = mkHMArgs s;
                  modules = mods;
                };
              hmFeaturesFor = profile:
                (evalCfg (hmBaseModules {inherit profile;})).config.features;
              fNeg = hmFeaturesFor null;
              fLite = hmFeaturesFor "lite";
              toFlat = set: prefix:
                lib.foldl' (
                  acc: name: let
                    cur = lib.optionalString (prefix != "") (prefix + ".") + name;
                    v = set.${name};
                  in
                    acc
                    // (
                      if builtins.isAttrs v
                      then toFlat v cur
                      else if builtins.isBool v
                      then {${cur} = v;}
                      else {}
                    )
                ) {} (builtins.attrNames set);
              flatNeg = toFlat fNeg "features";
              flatLite = toFlat fLite "features";
              deltas = docs.renderDeltasMd {inherit flatNeg flatLite;};
            in
              (builtins.readFile ./OPTIONS.md)
              + "\n\n"
              + deltas
          );
          features-options-md = pkgs.writeText "features-options.md" (docs.renderFeaturesOptionsMd featureOptionsItems);
          features-options-json = pkgs.writeText "features-options.json" (docs.renderFeaturesOptionsJson featureOptionsItems);
        } else {
          options-md = pkgs.writeText "OPTIONS.md" ''
            Docs generation is disabled.
            Set HM_DOCS=1 to enable heavy docs evaluation.
          '';
        }
    );
    checks = lib.genAttrs systems (
      s:
        let
          fullChecks = boolEnv "HM_CHECKS_FULL";
          evalWith = profile: retroFlag: let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = mkHMArgs s;
              modules = hmBaseModules {
                inherit profile;
                extra = [(_: {features.emulators.retroarch.full = retroFlag;})];
              };
            };
          in
            perSystem.${s}.pkgs.writeText
            "hm-eval-${
              if profile == "lite"
              then "lite"
              else "neg"
            }-retro-${
              if retroFlag
              then "on"
              else "off"
            }.json"
            (builtins.toJSON hmCfg.config.features);
          # Fast-path eval: disable GUI and Web to focus on CLI/Dev
          evalNoGuiWith = profile: retroFlag: let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = mkHMArgs s;
              modules = hmBaseModules {
                inherit profile;
                extra = [
                  (_: {
                    features.gui.enable = false;
                    features.gui.qt.enable = false;
                    features.web.enable = false;
                    features.emulators.retroarch.full = retroFlag;
                  })
                ];
              };
            };
          in
            perSystem.${s}.pkgs.writeText
            "hm-eval-${
              if profile == "lite" then "lite" else "neg"
            }-nogui-retro-${
              if retroFlag then "on" else "off"
            }.json"
            (builtins.toJSON hmCfg.config.features);
          # Fast-path eval: disable only Web (keep GUI)
          evalNoWebWith = profile: retroFlag: let
            hmCfg = homeManagerInput.lib.homeManagerConfiguration {
              inherit (perSystem.${s}) pkgs;
              extraSpecialArgs = mkHMArgs s;
              modules = hmBaseModules {
                inherit profile;
                extra = [
                  (_: {
                    features.web.enable = false;
                    features.emulators.retroarch.full = retroFlag;
                  })
                ];
              };
            };
          in
            perSystem.${s}.pkgs.writeText
            "hm-eval-${
              if profile == "lite" then "lite" else "neg"
            }-noweb-retro-${
              if retroFlag then "on" else "off"
            }.json"
            (builtins.toJSON hmCfg.config.features);
          base = perSystem.${s}.checks;
          fast = {
            hm-eval-neg-retro-on = evalWith null true;
            hm-eval-neg-retro-off = evalWith null false;
            hm-eval-lite-retro-on = evalWith "lite" true;
            hm-eval-lite-retro-off = evalWith "lite" false;
            # No-GUI fast path (GUI + Web disabled)
            hm-eval-neg-nogui-retro-on = evalNoGuiWith null true;
            hm-eval-neg-nogui-retro-off = evalNoGuiWith null false;
            hm-eval-lite-nogui-retro-on = evalNoGuiWith "lite" true;
            hm-eval-lite-nogui-retro-off = evalNoGuiWith "lite" false;
            # No-Web fast path (Web disabled, GUI intact)
            hm-eval-neg-noweb-retro-on = evalNoWebWith null true;
            hm-eval-neg-noweb-retro-off = evalNoWebWith null false;
            hm-eval-lite-noweb-retro-on = evalNoWebWith "lite" true;
            hm-eval-lite-noweb-retro-off = evalNoWebWith "lite" false;
          };
          heavy = lib.optionalAttrs (s == defaultSystem) {
            hm = self.homeConfigurations."neg".activationPackage;
            hm-lite = self.homeConfigurations."neg-lite".activationPackage;
          };
        in
          base
          // fast
          // lib.optionalAttrs fullChecks heavy
    );

    homeConfigurations."neg" = homeManagerInput.lib.homeManagerConfiguration {
      inherit (perSystem.${defaultSystem}) pkgs;
      extraSpecialArgs = mkHMArgs defaultSystem;
      modules = hmBaseModules {};
    };

    homeConfigurations."neg-lite" = homeManagerInput.lib.homeManagerConfiguration {
      inherit (perSystem.${defaultSystem}) pkgs;
      extraSpecialArgs = mkHMArgs defaultSystem;
      modules = hmBaseModules {profile = "lite";};
    };

    # Reusable project templates
    templates = {
      rust-crane = {
        path = ./templates/rust-crane;
        description = "Rust project scaffold: crane, unified rust-toolchain, checks, devShell";
      };
    };
  };
}
