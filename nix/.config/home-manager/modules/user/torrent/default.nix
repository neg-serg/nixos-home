{
  pkgs,
  lib,
  config,
  ...
}:
let
  transmissionPkg = pkgs.transmission_4;
  confDirNew = "${config.xdg.configHome}/transmission-daemon";
  confDirOld = "${config.xdg.configHome}/transmission";
in lib.mkIf config.features.torrent.enable (lib.mkMerge [
{
  # Link selected Transmission config files from repo; runtime subdirs remain local
  xdg.configFile."transmission-daemon/settings.json" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/misc/transmission-daemon/conf/settings.json" false;
  xdg.configFile."transmission-daemon/bandwidth-groups.json" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/misc/transmission-daemon/conf/bandwidth-groups.json" false;

  # Ensure runtime subdirectories exist even if the config dir is a symlink
  # to an external location. This avoids "resume: No such file or directory"
  # on first start after activation.
  home.activation.ensureTransmissionDirs =
    config.lib.neg.mkEnsureDirsAfterWrite [
      "${confDirNew}/resume"
      "${confDirNew}/torrents"
      "${confDirNew}/blocklists"
      # Also ensure legacy path exists if the wrapper selects it
      "${confDirOld}/resume"
      "${confDirOld}/torrents"
      "${confDirOld}/blocklists"
    ];

  # Core torrent tools (migration helpers removed)
  home.packages = config.lib.neg.pkgsList [
    transmissionPkg
    pkgs.bitmagnet
    pkgs.neg.bt_migrate
    pkgs.rustmission
  ];

  # Preserve user symlinks for Transmission config (history/resume). Do not
  # force the directory to be a real dir here — only clean up if it's a broken
  # symlink to avoid nuking external setups.
  home.activation.keepTransmissionConfigSymlink =
    config.lib.neg.mkRemoveIfBrokenSymlink "${config.xdg.configHome}/transmission-daemon";

  # Wrapper selects existing config dir that contains resume files, preferring the new path
  home.file.".local/bin/transmission-daemon-wrapper" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      c1="${confDirNew}"
      c2="${confDirOld}"
      choose_dir() {
        if [ -d "$c1/resume" ] && compgen -G "$c1/resume/*.resume" >/dev/null 2>&1; then echo "$c1"; return; fi
        if [ -d "$c2/resume" ] && compgen -G "$c2/resume/*.resume" >/dev/null 2>&1; then echo "$c2"; return; fi
        if [ -d "$c1" ]; then echo "$c1"; return; fi
        if [ -d "$c2" ]; then echo "$c2"; return; fi
        echo "$c1"
      }
      gdir=$(choose_dir)
      exec "${lib.getExe' transmissionPkg "transmission-daemon"}" -g "$gdir" -f --log-level=error
    '';
  };

}
# Transmission daemon service (systemd user)
(config.lib.neg.systemdUser.mkSimpleService {
  name = "transmission-daemon";
  description = "transmission service";
  execStart = "${config.home.homeDirectory}/.local/bin/transmission-daemon-wrapper";
  presets = ["net" "defaultWanted"];
  unitExtra = {
    ConditionPathExists = "${lib.getExe' transmissionPkg "transmission-daemon"}";
  };
  serviceExtra = {
    Type = "simple";
    Restart = "on-failure";
    RestartSec = "30";
    StartLimitBurst = "8";
    ExecReload = "${lib.getExe' pkgs.util-linux "kill"} -s HUP $MAINPID";
  };
})
# Soft migration warning: detect legacy config under $XDG_CONFIG_HOME/transmission
(let
  cfgFiles = builtins.attrNames (config.xdg.configFile or {});
  old = builtins.filter (n: lib.hasPrefix "transmission/" n) cfgFiles;
in config.lib.neg.mkWarnIf (old != []) "Transmission config under $XDG_CONFIG_HOME/transmission detected; migrate to $XDG_CONFIG_HOME/transmission-daemon.")
])
