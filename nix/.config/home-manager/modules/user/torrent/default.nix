{
  pkgs,
  lib,
  config,
  ...
}:
let
  transmissionPkg = pkgs.transmission_4;
  confDirNew = "${config.xdg.configHome}/transmission-daemon";
in lib.mkIf config.features.torrent.enable (lib.mkMerge [
{
  # Link selected Transmission config files from repo; runtime subdirs remain local
  xdg.configFile."transmission-daemon/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/misc/transmission-daemon/conf/settings.json";
    recursive = false;
  };
  xdg.configFile."transmission-daemon/bandwidth-groups.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/misc/transmission-daemon/conf/bandwidth-groups.json";
    recursive = false;
  };

  # Ensure runtime subdirectories exist even if the config dir is a symlink
  # to an external location. This avoids "resume: No such file or directory"
  # on first start after activation.
  home.activation.ensureTransmissionDirs =
    config.lib.neg.mkEnsureDirsAfterWrite [
      "${confDirNew}/resume"
      "${confDirNew}/torrents"
      "${confDirNew}/blocklists"
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
        ExecStart = "${lib.getExe' transmissionPkg "transmission-daemon"} -g ${confDirNew} -f --log-level=error";
        Restart = "on-failure";
        RestartSec = "30";
        StartLimitBurst = "8";
        ExecReload = "${lib.getExe' pkgs.util-linux "kill"} -s HUP $MAINPID";
      };
    }
    (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["net" "defaultWanted"]; })
  ];
}
# Soft migration warning: detect legacy config under $XDG_CONFIG_HOME/transmission
(let
  cfgFiles = builtins.attrNames (config.xdg.configFile or {});
  old = builtins.filter (n: lib.hasPrefix "transmission/" n) cfgFiles;
in {
  warnings = lib.optional (old != [])
    "Transmission config under $XDG_CONFIG_HOME/transmission detected; migrate to $XDG_CONFIG_HOME/transmission-daemon.";
})
])
