{ lib, config, pkgs, xdg, ... }: {
  home.packages = with pkgs; [
      manix
      neovim-remote # nvr for neovim
      nodejs_21 # dependency for some lsp stuff
  ];
  # xdg.configFile = {
  #     "nvim" = {
  #         source = lib.mk "/home/neg/.dotfiles/dev/.config/nvim";
  #         recursive = true;
  #     };
  # };
}
