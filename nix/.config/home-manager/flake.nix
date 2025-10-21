let
  # Keep these literal to satisfy flake nixConfig (cannot be thunks)
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
    bzmenu = { url = "github:e-tho/bzmenu"; inputs.nixpkgs.follows = "nixpkgs"; };
    chaotic = { url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
    # CamelCase alias for convenience in code
    homeManagerInput.follows = "home-manager";
    # Pin hy3 to tag compatible with Hyprland v0.51.0
    hy3 = {
      # hy3 tags track Hyprland compatibility (hlX.Y.Z)
      url = "github:outfoxxed/hy3?rev=e317a4cf89486f33c0e09364fbb6949e9f4f5624"; # hl0.51.0
      # Ensure hy3 uses the same Hyprland input we pin below
      inputs.hyprland.follows = "hyprland";
    };
    # Pin Hyprland to v0.51.0 to match hy3
    hyprland = { url = "github:hyprwm/Hyprland?ref=v0.51.0"; inputs.nixpkgs.follows = "nixpkgs"; };
    iosevka-neg = { url = "git+ssh://git@github.com/neg-serg/iosevka-neg"; inputs.nixpkgs.follows = "nixpkgs"; };
    # CamelCase alias for convenience in code
    iosevkaNegInput.follows = "iosevka-neg";
    iwmenu = { url = "github:e-tho/iwmenu"; inputs.nixpkgs.follows = "nixpkgs"; };
    # Nushell package manager (non-flake repo) to avoid vendoring sources
    nupm = { url = "github:nushell/nupm"; flake = false; };
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    quickshell = { url = "git+https://git.outfoxxed.me/outfoxxed/quickshell"; inputs.nixpkgs.follows = "nixpkgs"; };
    rsmetrx = { url = "github:neg-serg/rsmetrx"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    # CamelCase alias for convenience in code
    sopsNixInput.follows = "sops-nix";
    stylix = { url = "github:danth/stylix"; inputs.nixpkgs.follows = "nixpkgs"; };
    # CamelCase alias for convenience in code
    stylixInput.follows = "stylix";
    nur = { url = "github:nix-community/NUR"; inputs.nixpkgs.follows = "nixpkgs"; };
    yandex-browser = { url = "github:miuirussia/yandex-browser.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
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
    hmHelpers = import ./flake/hm-helpers.nix {
      inherit lib stylixInput chaotic sopsNixInput;
    };
    inherit (hmHelpers) hmBaseModules;

    # mkHMArgs moved to a helper; keep semantics identical
    mkHMArgs = import ./flake/mkHMArgs.nix {
      inherit lib perSystem hy3 yandexBrowserInput nur inputs;
      inherit hmInputs extraSubstituters extraTrustedKeys;
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
        devTools = import ./flake/devtools.nix { inherit lib pkgs; };
        inherit (devTools) devNixTools rustBaseTools rustExtraTools;
      in {
        inherit pkgs iosevkaNeg;

        devShells = import ./flake/devshells.nix {
          inherit pkgs rustBaseTools rustExtraTools devNixTools;
        };

        packages =
          let
            extrasFlag = boolEnv "HM_EXTRAS";
            extrasSet = import ./flake/pkgs-extras.nix {
              inherit hy3 pkgs;
              system = system;
            };
          in {
            default = pkgs.zsh;
          } // lib.optionalAttrs extrasFlag extrasSet;

        # Formatter: treefmt wrapper pinned to repo config
        formatter = import ./flake/formatter.nix { inherit pkgs; };

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
    docs = import ./flake/docs.nix {
      inherit lib perSystem systems homeManagerInput mkHMArgs hmBaseModules boolEnv;
    };
    checks = import ./flake/checks-outputs.nix {
      inherit lib systems defaultSystem perSystem splitEnvList boolEnv homeManagerInput mkHMArgs hmBaseModules self;
    };

    homeConfigurations = lib.genAttrs [ "neg" "neg-lite" ] (n:
      homeManagerInput.lib.homeManagerConfiguration {
        inherit (perSystem.${defaultSystem}) pkgs;
        extraSpecialArgs = mkHMArgs defaultSystem;
        modules = hmBaseModules (lib.optionalAttrs (n == "neg-lite") { profile = "lite"; });
      }
    );

    # Reusable project templates
    templates = import ./flake/templates.nix;
  };
}
