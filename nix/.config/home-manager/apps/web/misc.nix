{ pkgs, ... }: {
  home.packages = with pkgs; [
      gallery-dl # download image galleries/collections
      magic-wormhole # tool for local file sharing
      megacmd # cli for MEGA
      monolith # download all webpage stuff as one file
      pipe-viewer # lightweight youtube client
      plowshare # download/upload from popular sites
      prettyping # fancy ping
      whois # get domain info
      xidel # download webpage parts
      yt-dlp # download from youtube and another sources
  ];
}
