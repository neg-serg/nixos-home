{
  pkgs,
  config,
  stable,
  master,
  ...
}: {
  home.packages = with pkgs; [
    ape # monkey audio codec
    cdparanoia # cdrip / cdrecord
    cider # apple music player
    dr14_tmeter # compute the DR14 of a given audio file according to the procedure from Pleasurize Music Foundation
    id3v2 # id3v2 edit
    mpc-cli # mpd client
    ncmpcpp # curses mpd client
    ncpamixer # cli-pavucontrol
    nicotine-plus # download music via soulseek
    opensoundmeter # sound measurement application for tuning audio systems in real-time
    picard # autotags
    roomeqwizard # room acoustics software
    screenkey # screencast tool to display your keys inspired by Screenflick
    sonic-visualiser # audio analyzer
    sox # audio processing
    stable.audiowaveform # shows soundwaveform
    stable.streamlink # CLI for extracting streams from websites
    tauon # fancy standalone music player
    unflac # split2flac alternative
  ];

  systemd.user.services = {
    mpdas = {
      Unit = {
        Description = "mpdas last.fm scrobbler";
        After = ["network.target" "sound.target" "mpd.service"];
        Requires = "mpd.service";
      };
      Service = {
        ExecStart = "${pkgs.mpdas}/bin/mpdas -c ${config.sops.secrets.mpdas_negrc.path}";
        Restart = "on-failure";
        RestartSec = "10";
      };
      Install = {WantedBy = ["default.target"];};
    };

    cover-notify = {
      Unit = {
        Description = "Music track notification with cover";
        After = ["network.target" "sound.target" "playerctld.service" "mpd.service" "mpDris.service"];
        BindsTo = "mpDris.service";
        StartLimitIntervalSec = "0";
      };
      Service = {
        ExecStart = "${pkgs.cached-nix-shell}/bin/cached-nix-shell -p 'python3.withPackages (p: [p.pygobject3 p.systemd])' -p gobject-introspection -p playerctl --run %h/bin/track-notification-daemon";
        Restart = "always";
        RestartSec = "3";
      };
    };

    mpDris = {
      Unit = {
        Description = "mpDris2 - Music Player Daemon D-Bus bridge";
        After = ["playerctld.service" "network.target" "sound.target" "mpd.service"];
        PartOf = ["mpd.socket" "mpd.service"];
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${pkgs.writeShellScriptBin "delay-mpdris2" "${pkgs.coreutils}/bin/sleep 1 && ${pkgs.mpdris2}/bin/mpDris2"}/bin/delay-mpdris2";
      };
      Install = {WantedBy = ["default.target"];};
    };

    mpd = {
      Unit = {
        Description = "Music Player Daemon";
        Documentation = "man:mpd(1) man:mpd.conf(5)";
        After = ["network.target" "sound.target"];
        ConditionPathExists = "${master.mpd}/bin/mpd";
      };
      Service = {
        Type = "notify";
        ExecStart = "${master.mpd}/bin/mpd --no-daemon";
        WatchdogSec = 120;
        ProtectSystem = "yes"; # disallow writing to /usr, /bin, /sbin, ...
        Restart = "on-failure";
        RestartSec = "5";
      };
      Install = {WantedBy = ["default.target"];};
    };
  };
}
