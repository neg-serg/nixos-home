{ config, xdg, ... }: with rec {
    l = config.lib.file.mkOutOfStoreSymlink; 
    dots = "/home/neg/.dotfiles";
}; {
    xdg.configFile = {
      "amfora" = { source = l "${dots}/misc/.config/amfora"; recursive = true; };
      "bat" = { source = l "${dots}/misc/.config/bat"; recursive = true; };
      "beets" = { source = l "${dots}/music/.config/beets"; recursive = true; };
      "dircolors" = { source = l "${dots}/sys/.config/dircolors"; recursive = true; };
      "fastfetch" = { source = l "${dots}/misc/.config/fastfetch"; recursive = true; };
      "gdb" = { source = l "${dots}/dev/.config/gdb"; recursive = true; };
      "git" = { source = l "${dots}/git/.config/git"; recursive = true; };
      "i3" = { source = l "${dots}/negwm/.config/i3"; recursive = true; };
      "macchina" = { source = l "${dots}/misc/.config/macchina"; recursive = true; };
      "nvim" = { source = l "${dots}/dev/.config/nvim"; recursive = true; };
  };
  xdg.dataFile = {
      "hack-art" = { source = l "${dots}/art/.local/share/hack-art"; recursive = true; };
  };
  home.file = {
      "bin" = { source = l "${dots}/bin/bin"; recursive = false; };
  };
}
