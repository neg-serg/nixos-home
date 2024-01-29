{ config, pkgs, ... }: {
  home.packages = with pkgs; [
      asciinema # record terminal
      chafa # terminal graphics
      kitty # fastest terminal emulator so far
  ];
}
