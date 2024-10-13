{pkgs, ...}: {
  home.packages = with pkgs; [
    evhz # show mouse refresh rate
    openrgb # manage rgb highlight
  ];
}
