{
  lib,
  pkgs,
  config,
  ...
}:
let
  # Robust relative import: resolves in normal and docs eval (same modules/ tree)
  xdg = import ../../../lib/xdg-helpers.nix { inherit lib; };
in with lib;
  mkIf (config.features.mail.enable && config.features.mail.vdirsyncer.enable) (lib.mkMerge [
    {
      home.packages = with pkgs; config.lib.neg.pkgsList [
        vdirsyncer # add vdirsyncer binary for sync and initialization
      ];

      # Ensure local storage directories exist
      home.activation.vdirsyncerDirs = config.lib.neg.mkEnsureDirsAfterWrite [
        "$HOME/.config/vdirsyncer/calendars"
        "$HOME/.config/vdirsyncer/contacts"
      ];

      # Ensure status path under XDG state exists to avoid first-run hiccups
      home.activation.vdirsyncerStateDir =
        config.lib.neg.mkEnsureDirsAfterWrite [
          "${config.xdg.stateHome or "$HOME/.local/state"}/vdirsyncer"
        ];
    }
    (config.lib.neg.systemdUser.mkSimpleService {
      name = "vdirsyncer";
      description = "Vdirsyncer synchronization service";
      execStart = "${lib.getExe pkgs.vdirsyncer} sync";
      presets = ["netOnline"];
      serviceExtra = {
        Type = "oneshot";
        ExecStartPre = "${lib.getExe pkgs.vdirsyncer} metasync";
      };
    })
    (config.lib.neg.systemdUser.mkSimpleTimer {
      name = "vdirsyncer";
      presets = ["timers"];
      description = "Vdirsyncer synchronization timer";
      timerExtra = {
        OnBootSec = "2m";
        OnUnitActiveSec = "5m";
        Unit = "vdirsyncer.service";
      };
    })
    (xdg.mkXdgText "vdirsyncer/config" ''
      [general]
      status_path = "${config.xdg.stateHome or "$HOME/.local/state"}/vdirsyncer"

      # Calendars pair (filesystem <-> CalDAV)
      [pair calendars]
      a = "calendars_local"
      b = "calendars_remote"
      collections = ["from b"]
      conflict_resolution = "b wins"
      metadata = ["color", "displayname"]

      [storage calendars_local]
      type = "filesystem"
      path = "${config.home.homeDirectory}/.config/vdirsyncer/calendars"
      fileext = ".ics"

      [storage calendars_remote]
      type = "caldav"
      # TODO: Replace with your CalDAV base URL (e.g., Nextcloud/Fastmail)
      # Example (Nextcloud): https://cloud.example.com/remote.php/dav/calendars/USERNAME/
      url = "https://REPLACE-ME-CALDAV-BASE/"
      username = "REPLACE-ME-USER"
      password = "REPLACE-ME-PASSWORD"
      verify = true

      # Contacts pair (filesystem <-> CardDAV)
      [pair contacts]
      a = "contacts_local"
      b = "contacts_remote"
      collections = ["from b"]
      conflict_resolution = "b wins"

      [storage contacts_local]
      type = "filesystem"
      path = "${config.home.homeDirectory}/.config/vdirsyncer/contacts"
      fileext = ".vcf"

      [storage contacts_remote]
      type = "carddav"
      # TODO: Replace with your CardDAV base URL (e.g., Nextcloud/Fastmail)
      # Example (Nextcloud): https://cloud.example.com/remote.php/dav/addressbooks/users/USERNAME/
      url = "https://REPLACE-ME-CARDDAV-BASE/"
      username = "REPLACE-ME-USER"
      password = "REPLACE-ME-PASSWORD"
      verify = true
    '')
  ])
