{
  pkgs,
  lib,
  config,
  ...
}: let
  transmissionPkg = pkgs.transmission_4;
  confDirNew = "${config.xdg.configHome}/transmission-daemon";
in
  lib.mkIf config.features.torrent.enable (lib.mkMerge [
    {
      # Link selected Transmission config files from repo; runtime subdirs remain local
      xdg.configFile."transmission-daemon/settings.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/misc/transmission-daemon/conf/settings.json";
        recursive = false;
        force = true;
      };
      xdg.configFile."transmission-daemon/bandwidth-groups.json" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/misc/transmission-daemon/conf/bandwidth-groups.json";
        recursive = false;
        force = true;
      };

      # Ensure runtime subdirectories exist even if the config dir is a symlink
      # to an external location. This avoids "resume: No such file or directory"
      # on first start after activation.
      home.activation.ensureTransmissionDirs = config.lib.neg.mkEnsureDirsAfterWrite [
        "${confDirNew}/resume"
        "${confDirNew}/torrents"
        "${confDirNew}/blocklists"
      ];

      # Core torrent tools (migration helpers removed)
      home.packages = config.lib.neg.pkgsList [
        transmissionPkg # Transmission 4 BitTorrent client
        pkgs.bitmagnet # BitTorrent DHT crawler/search (CLI)
        pkgs.neg.bt_migrate # migrate legacy torrent data/config
        pkgs.rustmission # transmission-remote replacement (Rust CLI)
        pkgs.curl # required by trackers update helper
        pkgs.jq # required by trackers update helper
      ];

      # No additional activation cleanup for Transmission config; rely on XDG helpers.
    }
    {
      # Transmission daemon service (systemd user)
      systemd.user.services."transmission-daemon" = lib.mkMerge [
        {
          Unit = {
            Description = "transmission service";
            ConditionPathExists = "${lib.getExe' transmissionPkg "transmission-daemon"}";
          };
          Service = {
            Type = "simple";
            ExecStart = let
              exe = lib.getExe' transmissionPkg "transmission-daemon";
              args = ["-g" confDirNew "-f" "--log-level=error"];
            in "${exe} ${lib.escapeShellArgs args}";
            Restart = "on-failure";
            RestartSec = "30";
            StartLimitBurst = "8";
            ExecReload = let kill = lib.getExe' pkgs.util-linux "kill"; in "${kill} -s HUP $MAINPID";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["net" "defaultWanted"];})
      ];
    }
    # Local bin wrapper installed to ~/.local/bin (avoid config.* to prevent recursion)
    (let
      mkLocalBin = import ../../../packages/lib/local-bin.nix {inherit lib;};
    in
      mkLocalBin "transmission-add-trackers" ''        #!/usr/bin/env bash
            set -euo pipefail
            cd "$HOME/src/trackerslist"
            exec bash tools/add_transmission_trackers.sh trackers_best.txt
      '')

    {
      # Periodic job to add/update public trackers on existing torrents
      # Run manually: transmission-trackers-update (service) or timer start
      #   systemctl --user start transmission-trackers-update.service
      #   systemctl --user start transmission-trackers-update.timer

      # One-shot service that runs the wrapper
      systemd.user.services."transmission-trackers-update" = lib.mkMerge [
        {
          Unit = {
            Description = "Update Transmission trackers from trackerslist";
            After = ["transmission-daemon.service"];
            Wants = ["transmission-daemon.service"];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${config.home.homeDirectory}/.local/bin/transmission-add-trackers";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["netOnline"];})
      ];

      # Daily timer with persistence (runs missed executions on boot)
      systemd.user.timers."transmission-trackers-update" = lib.mkMerge [
        {
          Unit = {Description = "Timer: update Transmission trackers daily";};
          Timer = {
            OnCalendar = "daily";
            RandomizedDelaySec = "15m";
            Persistent = true;
            Unit = "transmission-trackers-update.service";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["timers"];})
      ];
    }
    # Soft migration warning removed; defaults and docs are sufficient
  ])
