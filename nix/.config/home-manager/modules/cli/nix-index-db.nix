{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.features.cli.nixIndexDB;
in {
  options.features.cli.nixIndexDB.enable =
    (lib.mkEnableOption "keep nix-index prebuilt DB fresh") // { default = true; };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    # Ensure cache dir exists post-write; keeps activation quiet/clean
    { home.activation.ensureNixIndexCache = config.lib.neg.mkEnsureDirsAfterWrite [
        "${config.xdg.cacheHome}/nix-index"
      ];
    }

    # Systemd user unit: fetch/update prebuilt DB (nix-index -f)
    {
      systemd.user.services.nix-index-update = lib.mkMerge [
        {
          Unit.Description = "Update nix-index prebuilt database";
          Service = {
            Type = "simple";
            # Explicitly pass nixpkgs path; nix-index >= 0.3 requires --nixpkgs when no channels are used
            ExecStart = "${pkgs.nix-index}/bin/nix-index -f --nixpkgs ${pkgs.path}";
          };
        }
        # No presets required for the service; timer triggers it.
        # Keep pattern consistent if presets are added later.
      ];

      systemd.user.timers.nix-index-update = lib.mkMerge [
        {
          Unit.Description = "Timer: update nix-index prebuilt DB";
          Timer = {
            OnBootSec = "2m";
            OnUnitActiveSec = "24h";
            Unit = "nix-index-update.service";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["timers"]; })
      ];
    }
  ]);
}
