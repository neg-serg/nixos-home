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
    # Ensure the session file exists under XDG data (no activation DAG noise)
    (xdg.mkXdgDataText "aria2/session" "")
    # Simple user service: read only from the generated config
    {
      systemd.user.services.aria2 = lib.mkMerge [
        {
          Unit = { Description = "aria2 download manager"; };
          Service.ExecStart = let exe = aria2Bin; args = [ "--conf-path=${configHome}/aria2/aria2.conf" ]; in "${exe} ${lib.escapeShellArgs args}";
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })
      ];
    }
  ])
