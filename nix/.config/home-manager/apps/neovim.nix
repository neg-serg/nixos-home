{ pkgs, ... }: {
  home.packages = with pkgs; [
      manix
      neovim-remote # nvr for neovim
      nodejs_21 # dependency for some lsp stuff
  ];
}
