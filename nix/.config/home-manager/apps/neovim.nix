{ config, pkgs, xdg, ... }: with {
    l = config.lib.file.mkOutOfStoreSymlink; 
    dots = "/home/neg/.dotfiles";
}; {
  home.packages = with pkgs; [
      manix
      neovim-remote # nvr for neovim
      nodejs_21 # dependency for some lsp stuff
  ];
  xdg.configFile = {
      "nvim" = {
          source = l "${dots}/dev/.config/nvim";
          recursive = true;
      };
  };
}
