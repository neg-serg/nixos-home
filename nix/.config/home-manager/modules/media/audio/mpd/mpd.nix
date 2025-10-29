{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.features.media.audio.mpd.enable (lib.mkMerge [
  {
    home.packages = config.lib.neg.pkgsList [
      pkgs.rmpc # alternative tui client with album cover
    ];

    services.mpd = {
      enable = false;
      dataDir = "${config.xdg.stateHome}/mpd";
      musicDirectory = "${config.home.homeDirectory}/music";
    };

    services.mpdris2 = {
      enable = true;
      mpd.host = "localhost";
      mpd.port = 6600;
    };

    systemd.user.services = {
      mpdas = lib.mkMerge [
        {
          Unit = {Description = "mpdas last.fm scrobbler";};
          Service = {
            ExecStart = let
              exe = lib.getExe pkgs.mpdas;
              args = ["-c" config.sops.secrets.mpdas_negrc.path];
            in "${exe} ${lib.escapeShellArgs args}";
            Restart = "on-failure";
            RestartSec = "10";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets {
          presets = ["net" "defaultWanted"];
          after = ["sound.target"]; # preserve additional ordering
        })
      ];
    };
  }
  # Soft migration notice removed (default points to XDG state; no warning needed)
])
