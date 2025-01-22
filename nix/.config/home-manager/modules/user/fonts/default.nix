{
  pkgs,
  stable,
  ...
}: {
  home.packages = with pkgs; [
    stable.fontforge # font processing
    pango # for pango-list
  ];
}
