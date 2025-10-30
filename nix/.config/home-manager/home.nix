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
      # Discord (vesktop) scratchpad
      {
        name = "discord";
        exec = "${lib.getExe pkgs.vesktop} --ozone-platform=wayland --enable-features=WaylandWindowDecorations";
        package = pkgs.vesktop;
        class = "vesktop";
        workspace = " 𐍀:im";
        workspaceId = 17;
        noAnim = true;
        environment = { NIXOS_OZONE_WL = "1"; };
      }
      # Telegram scratchpad
      {
        name = "telegram";
        exec = "${lib.getExe pkgs.telegram-desktop}";
        package = pkgs.telegram-desktop;
        class = "org.telegram.desktop";
        workspace = " 𐍀:im";
        workspaceId = 17;
        noAnim = true;
        environment = { QT_QPA_PLATFORM = "wayland"; };
      }
      # Music (rmpc in kitty) scratchpad
      {
        name = "music";
        exec = "${lib.getExe pkgs.kitty} --class music -e ${lib.getExe pkgs.rmpc}";
        package = pkgs.rmpc;
        class = "music";
      }
      # Torrents dashboard (rustmission in kitty) scratchpad
      {
        name = "torrment";
        exec = "${lib.getExe pkgs.kitty} --class torrment -e ${lib.getExe pkgs.rustmission}";
        package = pkgs.rustmission;
        class = "torrment";
      }
      # Teardown monitor (btop in kitty) scratchpad
      {
        name = "teardown";
        exec = "${lib.getExe pkgs.kitty} --class teardown -e ${lib.getExe pkgs.btop}";
        package = pkgs.btop;
        class = "teardown";
      }
      # PipeWire mixer scratchpad
      {
        name = "mixer";
        exec = "${lib.getExe pkgs.pwvucontrol}";
        package = pkgs.pwvucontrol;
        class = "com.saivert.pwvucontrol";
        environment = { QT_QPA_PLATFORM = "wayland"; };
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
