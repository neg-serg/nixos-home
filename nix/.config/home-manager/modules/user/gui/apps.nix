{
  pkgs,
  inputs,
  ...
}: {
  programs.wallust.enable = true;
  home.packages = with pkgs; [
    cliphist # wayland stuff for clipboard
    espanso # systemwide expander for keyboard
    inputs.bzmenu.packages.${pkgs.system}.default # bluetooth support menu
    matugen # modern theme generator like pywal
  ];
  # Deploy kitty and handlr configs from the repo
  xdg.configFile."kitty" = {
    source = inputs.self + "/wm/.config/kitty";
    recursive = true;
  };
  xdg.configFile."handlr/handlr.toml".source = inputs.self + "/wm/.config/handlr/handlr.toml";
}
