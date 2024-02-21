{ pkgs, ... }: {
  home.packages = with pkgs; [
      fontforge # font processing
      ueberzugpp # better w3mimgdisplay
  ];
}
