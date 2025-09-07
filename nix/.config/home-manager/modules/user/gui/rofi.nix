{pkgs, inputs, ...}: {
  home.packages = with pkgs; [
    rofi-pass-wayland # pass interface for rofi-wayland
    (rofi-wayland.override {
      plugins = [
        rofi-file-browser
        pkgs.neg.rofi_games
      ];
    }) # modern dmenu alternative
  ];
  # Deploy rofi config and themes from the repo
  xdg.configFile."rofi" = {
    source = inputs.self + "/rofi/.config/rofi";
    recursive = true;
  };
}
