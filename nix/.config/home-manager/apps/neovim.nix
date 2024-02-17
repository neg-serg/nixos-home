{ pkgs, stable, ... }: {
    home.packages = with pkgs; [
        cargo
        manix
        neovim-remote # nvr for neovim
        nodejs_21 # dependency for some lsp stuff
        stable.nil # nixos language server
    ];
}
