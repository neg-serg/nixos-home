{ config, pkgs, ... }: {
  home.packages = with pkgs; [
      (rofi.override {plugins = [rofi-file-browser]; }) # modern dmenu alternative
      rofi-pass # pass integration for pass
    ];
}
