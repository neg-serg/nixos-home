{ config, lib, pkgs, xdg, ... }:
let
  inherit (lib) getExe';
  inherit (config.xdg) configHome dataHome;
  aria2Bin = getExe' pkgs.aria2 "aria2c";
  sessionFile = "${dataHome}/aria2/session";
in
  lib.mkIf (config.features.web.enable && config.features.web.tools.enable) (lib.mkMerge [
    {
      # Minimal, robust aria2 configuration through Home Manager
      programs.aria2 = {
        enable = true;
        settings = {
          # Download destination under XDG paths
          dir = "${config.xdg.userDirs.download}/aria";
          # Enable RPC for external clients/UI
          enable-rpc = true;
          # Session file kept in XDG data (persist resume state)
          save-session = sessionFile;
          input-file = sessionFile;
          save-session-interval = 1800;
        };
      };
    }
    # Simple user service: read only from the generated config
    {
      systemd.user.services.aria2 = lib.mkMerge [
        {
          Unit = { Description = "aria2 download manager"; };
          Service.ExecStart = "${aria2Bin} --conf-path=${configHome}/aria2/aria2.conf";
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })
      ];
    }
    # Ensure the session file exists so input-file does not fail on first run
    (xdg.mkXdgDataText "aria2/session" "")
    # Soft migration warning: ensure session paths are under XDG data
    (let
      s = toString ((config.programs.aria2.settings or {}).save-session or "");
      i = toString ((config.programs.aria2.settings or {})."input-file" or "");
      dh = toString config.xdg.dataHome;
      ok = (lib.hasPrefix (dh + "/") s) && (lib.hasPrefix (dh + "/") i);
    in {
      warnings = lib.optional (! ok)
        "aria2 session paths should be under $XDG_DATA_HOME/aria2 (save-session/input-file).";
    })
  ])
