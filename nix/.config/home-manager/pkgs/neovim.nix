{
  pkgs,
  config,
  stable,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  home.packages = with pkgs; [
    neovim-remote # nvr for neovim
    nodePackages.bash-language-server # bash lsp
    nodePackages.pyright # python lsp
    rust-analyzer # rust lsp
    stable.nil # nixos language server
  ];
  programs.neovim.plugins = with pkgs.vimPlugins; [
    clangd_extensions-nvim # llvm-based engine
    nvim-treesitter.withAllGrammars # ts support
  ];
  xdg.configFile = {
    # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
    "nvim" = {
      source = l "${dots}/nvim/.config/nvim";
      recursive = true;
    };
  };
}
