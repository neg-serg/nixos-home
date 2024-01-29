{ config, pkgs, ... }: {
  home.packages = with pkgs; [
      amfora # terminal browser for gemini
      antiword # convert ms word to text or ps
      epr # cli epub reader
      glow # markdown viewer
      mdcat # cat for markdown
      zathura # pdf/djvu viewer
  ];
}
