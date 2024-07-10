{
  pkgs,
  master,
  ...
}: {
  home.packages = with pkgs; [
    # asciinema # record terminal
    chafa # terminal graphics
    master.kitty # fastest terminal emulator so far
    master.kitty-img # print images inline in kitty
    termplay # play video in terminal
  ];
}
