{
  pkgs,
  stable,
  ...
}: {
  home.packages = with pkgs; [
    gallery-dl # download image galleries/collections
    monolith # download all webpage stuff as one file
    pipe-viewer # lightweight youtube client
    plowshare # download/upload from popular sites
    prettyping # fancy ping
    stable.megacmd # cli for MEGA
    whois # get domain info
    xidel # download webpage parts
    yt-dlp_git # download from youtube and another sources
  ];
}
