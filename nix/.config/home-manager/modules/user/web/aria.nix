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
          Service.ExecStart = let exe = aria2Bin; args = [ "--conf-path=${configHome}/aria2/aria2.conf" ]; in "${exe} ${lib.escapeShellArgs args}";
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })
      ];
    }
    # Keep the session file writable and avoid activation noise when it already exists
    {
      home.activation.ensureAria2SessionParent =
        config.lib.neg.mkEnsureRealParent sessionFile;
      home.activation.ensureAria2SessionFile =
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          set -eu
          session_path="${sessionFile}"
          if [ -L "$session_path" ]; then
            tmp="$(mktemp)"
            cp "$session_path" "$tmp"
            rm -f "$session_path"
            install -Dm600 "$tmp" "$session_path"
            rm -f "$tmp"
          elif [ ! -e "$session_path" ]; then
            install -Dm600 /dev/null "$session_path"
          fi
        '';
    }
  ])
