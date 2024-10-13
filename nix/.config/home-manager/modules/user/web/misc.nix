{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    gallery-dl # download image galleries/collections
    monolith # download all webpage stuff as one file
    pipe-viewer # lightweight youtube client
    prettyping # fancy ping
    megacmd # cli for MEGA
    whois # get domain info
    xidel # download webpage parts
  ];
}
