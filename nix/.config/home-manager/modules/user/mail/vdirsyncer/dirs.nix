{ lib, config, ... }:
with lib;
mkIf (config.features.mail.enable && config.features.mail.vdirsyncer.enable) {
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

