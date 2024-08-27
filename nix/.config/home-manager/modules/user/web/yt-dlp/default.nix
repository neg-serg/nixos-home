{master, ...}: {
  programs.yt-dlp = {
    enable = true;
    package = master.yt-dlp; # download from youtube and another sources
    settings = {
      cookies-from-browser = "chromium";
      downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
      downloader = "aria2c";
      embed-metadata = true;
      embed-subs = true;
      embed-thumbnail = true;
      sub-langs = "all";
    };
  };
}
