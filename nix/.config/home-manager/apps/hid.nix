{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    evhz # show mouse refresh rate
    openrgb # manage rgb highlight
    polychromatic # razer mouse/keyboard config tool
  ];
}
