{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.mail.enable (lib.mkMerge [
    {
    # Install isync/mbsync and keep using the XDG config at ~/.config/isync/mbsyncrc
    programs.mbsync.enable = true;

    # Inline mbsyncrc under XDG with automatic guards via helper
    # (ensures parent dir is real and removes stale file/symlink)
    xdg.configFile."isync/mbsyncrc".text = builtins.readFile ./mbsyncrc;

    # Optional: ensure the binary is present even if HM changes defaults
    # Also provide a non-blocking trigger to start sync in background
    home.packages = config.lib.neg.pkgsList [
      pkgs.isync # mbsync binary (isync)
      (pkgs.writeShellScriptBin "sync-mail" ''
        #!/usr/bin/env bash
        set -euo pipefail
        # Fire-and-forget start of the mbsync systemd unit
        exec systemctl --user start --no-block mbsync-gmail.service
      '')
    ];

    # Create base maildir on activation (mbsync can also create, but this avoids first-run hiccups)
    # Maildir creation handled by global prepareUserPaths action

      # Periodic sync in addition to imapnotify (fallback / catch-up)
      (config.lib.neg.systemdUser.mkSimpleService {
        name = "mbsync-gmail";
        description = "Sync mail via mbsync (gmail)";
        execStart = ''${pkgs.isync}/bin/mbsync -Va -c %h/.config/isync/mbsyncrc'';
        presets = ["netOnline"];
        serviceExtra = {
          Type = "simple";
          TimeoutStartSec = "30min";
        };
      })
      (config.lib.neg.systemdUser.mkSimpleTimer {
        name = "mbsync-gmail";
        presets = ["timers"];
        description = "Timer: mbsync gmail";
        timerExtra = {
          OnBootSec = "2m";
          OnUnitActiveSec = "10m";
          Persistent = true;
        };
      })
    }
  ])
