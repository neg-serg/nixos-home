{ pkgs, config, stable, ... }: with rec {
    l = config.lib.file.mkOutOfStoreSymlink;
    dots = "${config.home.homeDirectory}/.dotfiles";
} ;{
    home.packages = with pkgs; [
        cargo
        manix
        neovim-remote # nvr for neovim
        nodePackages.bash-language-server
        nodePackages.pyright
        rust-analyzer
        stable.nil # nixos language server
    ];
    programs.neovim.plugins = with pkgs; [ 
        vimPlugins.nvim-treesitter.withAllGrammars 
        vimPlugins.clangd_extensions-nvim
    ];
    xdg.configFile = {
        # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
        "nvim" = { source = l "${dots}/nvim/.config/nvim"; recursive = true; };
    };
}
