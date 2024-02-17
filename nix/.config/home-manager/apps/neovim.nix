{ pkgs, config, stable, ... }: with rec {
    l = config.lib.file.mkOutOfStoreSymlink;
    dots = "${config.home.homeDirectory}/.dotfiles";
} ;{
    home.packages = with pkgs; [
        cargo
        manix
        neovim-remote # nvr for neovim
        nodejs_21 # dependency for some lsp stuff
        stable.nil # nixos language server
    ];
    programs.neovim.plugins = with pkgs; [ 
        vimPlugins.nvim-treesitter.withAllGrammars 
    ];
    xdg.configFile = {
        # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
        "nvim" = { source = l "${dots}/nvim/.config/nvim"; recursive = true; };
    };
}
