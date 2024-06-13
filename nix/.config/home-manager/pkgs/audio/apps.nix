{
  pkgs,
  lib,
  config,
  stable,
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

  services.mpd = {
      enable = true;
      dataDir = "${config.home.homeDirectory}/music";
      network.startWhenNeeded = true;
      network.listenAddress = "127.0.0.1";
      extraConfig = ''
      log_file "/dev/null"
      max_output_buffer_size "131072"
      max_connections "100"
      connection_timeout "864000"
      restore_paused "yes"
      save_absolute_paths_in_playlists "yes"
      #metadata_to_use "artist,album,title,track,name,genre,date"
      follow_inside_symlinks "yes"
      replaygain "off"
      auto_update "yes"
      mixer_type "software"

      input_cache {
          size "1 GB"
      }

      audio_output {
          type "alsa"
          name "RME ADI-2/4 PRO SE"
          device "hw:CARD=SE53011083"
          auto_resample "no"
          auto_format "no"
          auto_channels "no"
          replay_gain_handler "none"
          dsd_native "yes"
          dop "no"
          tags "yes"
      }

      audio_output {
          type "pipewire"
          name "PipeWire"
          dsd "yes"
      }
      '';
  };

  services.mpd-mpris = {
    enable = true;
    mpd.port = "6600";
    mpd.host = "127.0.0.1";
  };

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
        After = ["mpd.service"];
        StartLimitIntervalSec = "1";
        BindsTo = ["mpd.service"];
      };
      Service = {
        ExecStart = lib.strings.concatStringsSep " " ["${pkgs.cached-nix-shell}/bin/cached-nix-shell "
            "-p 'python3.withPackages (p: [p.pygobject3 p.systemd p.dbus-python])' "
            "-p gobject-introspection"
            "-p mpc-cli"
            "-p sox"
            "-p dunst"
            "-p id3lib"
            "--run %h/bin/track-notification"];
        Restart = "always";
        RestartSec = "3";
      };
      Install = {WantedBy = ["default.target"];};
    };
  };
}
