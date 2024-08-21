{
  pkgs,
  stable,
  ...
}: {
  home.packages = with pkgs; [
    fontforge # font processing
    pango # for pango-list
    stable.ueberzugpp # better w3mimgdisplay
  ];
}
