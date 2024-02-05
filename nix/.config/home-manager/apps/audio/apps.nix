{ pkgs, ... }: {
  home.packages = with pkgs; [
      ape # monkey audio codec
      audiowaveform # shows soundwaveform
      cdparanoia # cdrip / cdrecord
      easytag # use this for tags
      id3v2 # id3v2 edit
      jamesdsp # pipewire dsp
      media-player-info # repository of data files describing media player capabilities
      mediainfo # tag information about video or audio
      mpc-cli # mpd client
      mpd # music player daemon
      mpdas # mpd scrobbler
      mpdris2 # playerctl for mpd
      ncmpcpp # curses mpd client
      ncpamixer # cli-pavucontrol
      nicotine-plus # download music via soulseek
      picard # autotags
      playerctl # media controller for everything
      sonic-visualiser # audio analyzer
      tauon # fancy standalone music player
      unflac # split2flac alternative

      dr14_tmeter # compute the DR14 of a given audio file according to the procedure from Pleasurize Music Foundation
      ffmpeg-full
      ffmpegthumbnailer # thumbnail for video
      haruna # a nicer, better front end for mpv
      mpvc # CLI controller for mpv
      mpvScripts.mpris # playerctl support for mpv
      mpv # video player
      screenkey # screencast tool to display your keys inspired by Screenflick
      simplescreenrecorder # screen recorder
      sox # audio processing
      streamlink  # CLI for extracting streams from websites
      termplay # play video in terminal
  ];
}
