{
  lib,
  config,
  pkgs,
  caches,
  ...
}: let
  # Reuse flake-provided caches passed via mkHMArgs (single source of truth)
  cachixSubstituters = caches.substituters or [];
  cachixTrustedKeys = caches.trustedPublicKeys or [];
in {
  # Profile presets (full | lite). Full is default; set to "lite" for headless/minimal.
  features.profile = lib.mkDefault "full";
  # Exclude problematic packages from curated lists without editing modules
  features.excludePkgs = [
    # Network sniffing/passwords
    "dsniff"
    "crowbar"
    # Backdoor/tunneling tool candidates kept off by default
    "dns2tcp"
    "exe2hexbat"
    "laudanum"
    "mimikatz"
    "nishang"
    "powersploit"
    "ptunnel"
    "sbd"
    "shellter"
    "stunnel4"
    "veil"
    "webacoo"
    "weevely"
    # OpenMW now uses upstream packaging; not excluded
  ];

  # Temporarily disable Vdirsyncer units/timer until credentials are configured
  features.mail.vdirsyncer.enable = false;

  # Enable GPG stack (gpg + gpg-agent)
  features.gpg.enable = true;

  # Enable Unreal Engine tooling (ue5-sync/build/editor wrappers)
  features.dev.unreal.enable = true;

  # Enable OpenXR dev stack (installs Envision UI)
  features.dev.openxr.enable = true;

  # Prewarm scratchpad apps (persistent, background user services)
  neg.hypr.prewarm = {
    enable = true;
    apps = [
      # Terminal on workspace 1 (term)
      {
        name = "term";
        # Idempotent launch: use raise to focus existing or start if missing
        exec = "raise --class 'term' --launch 'kitty --class term'";
        class = "term";
        workspaceId = 1;
        noAnim = true;
      }
      # Default browser (Floorp) on workspace 2 (web)
      {
        name = "web";
        # Idempotent launch via raise; relies on PATH-resolved browser
        exec = "raise --class '(one.ablaze.floorp|floorp)' --launch 'floorp'";
        class = "(one\\.ablaze\\.floorp|floorp)";
        environment = { MOZ_ENABLE_WAYLAND = "1"; };
        workspaceId = 2;
        noAnim = true;
      }
      # Soulseek client (Nicotine+): focus existing or launch once
      {
        name = "slsk";
        exec = "raise --class 'org.nicotine_plus.Nicotine' --launch 'nicotine'";
        class = "org.nicotine_plus.Nicotine";
        workspaceId = 15;
        noAnim = true;
      }
      # Notes (Obsidian): focus existing or launch
      {
        name = "notes";
        exec = "raise --class 'Obsidian' --launch 'flatpak run md.obsidian.Obsidian || obsidian'";
        class = "Obsidian";
        workspaceId = 19;
        noAnim = true;
      }
    ];
  };

  # XDG aggregated fixups were removed; rely on per‑file `force = true` when needed.

  # Unfree policy centralized in modules/misc/unfree.nix (features.allowUnfree.allowed)

  nix = {
    package = pkgs.nix;
    # Per-user Nix settings
    settings = {
      # Trust flake-provided nixConfig (substituters, keys, features)
      accept-flake-config = true;
      # Use XDG paths so Home Manager uses modern v2 profile (nix profile)
      use-xdg-base-directories = true;
      # Speed + safety: keep eval cache on and forbid IFD during eval
      eval-cache = true;
      allow-import-from-derivation = false;
      # Use the sops-managed GitHub netrc for authenticated fetches
      netrc-file = config.sops.secrets."github-netrc".path;
      # Ensure features are available; caches and keys come from flake nixConfig (via mkHMArgs)
      experimental-features = ["nix-command" "flakes"];
      # Make caches visible in `nix show-config` via flake-provided lists
      # Keep cache.nixos.org first to retain the official cache
      substituters = ["https://cache.nixos.org/"] ++ cachixSubstituters;
      trusted-public-keys =
        ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="]
        ++ cachixTrustedKeys;
    };
  };
  imports = [
    ./secrets
    ./modules
  ];
  xdg.stateHome = "${config.home.homeDirectory}/.local/state";
  home = {
    homeDirectory = "/home/neg";
    stateVersion = "23.11"; # Please read the comment before changing.
    preferXdgDirectories = true;
    username = "neg";
  };

  # Auto-push built store paths to Cachix
  services.cachix.watchStore = {
    enable = true;
    cacheName = "neg-serg";
    authTokenFile = config.sops.secrets."cachix_env".path;
  };
}
