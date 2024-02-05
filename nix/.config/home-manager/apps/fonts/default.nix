{ pkgs, ... }: {
  home.packages = with pkgs; [
    # fontpreview-ueberzug # commandline fontpreview
    fontforge # font processing
    ueberzugpp # better w3mimgdisplay
  ];
}
