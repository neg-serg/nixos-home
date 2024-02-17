{ pkgs, config, stable, ... }: with {
    l = config.lib.file.mkOutOfStoreSymlink;
    dots = "${config.home.homeDirectory}/.dotfiles";
};{
    home.packages = with pkgs; [
        cargo
        manix
        neovim-remote # nvr for neovim
        nodePackages.bash-language-server
        nodePackages.pyright
        rust-analyzer
        stable.nil # nixos language server
    ];
    programs.neovim.plugins = with pkgs.vimPlugins; [
        clangd_extensions-nvim
        nvim-treesitter.withAllGrammars
    ];
    xdg.configFile = {
        # █▓▒░ nvim ─────────────────────────────────────────────────────────────────────────
        "nvim" = { source = l "${dots}/nvim/.config/nvim"; recursive = true; };
    };
}
