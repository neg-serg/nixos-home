{ pkgs, config, ... }: with {
    l = config.lib.file.mkOutOfStoreSymlink;
    dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  home.packages = with pkgs; [
      ffmpeg-full # famous multimedia lib
      ffmpegthumbnailer # thumbnail for video
      imagemagick # for convert
      mediainfo # tag information about video or audio
      media-player-info # repository of data files describing media player capabilities
      mpvc # CLI controller for mpv
      mpvScripts.mpris # playerctl support for mpv
      mpv # video player
      playerctl # media controller for everything
      simplescreenrecorder # screen recorder
  ];

  xdg.configFile = {
      "mpv" = { source = l "${dots}/media/.config/mpv"; recursive = true; };
      "pipewire" = { source = l "${dots}/media/.config/pipewire"; recursive = true; };
  };

  systemd.user.services = {
      playerctld = {
          Unit = {
              Description = "Keep track of media player activity";
              After = ["network.target" "sound.target"];
          };
          Service = {
              Type = "forking";
              ExecStart = "${pkgs.playerctl}/bin/playerctld daemon";
              RestartSec = "3";
              StartLimitBurst = "0";
          };
          Install = { WantedBy = ["default.target"]; };
      };
  };
}
