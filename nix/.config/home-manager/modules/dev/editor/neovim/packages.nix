{ config, pkgs, ... }:
{
  home.packages = config.lib.neg.pkgsList [
    pkgs.bash-language-server
    pkgs.neovim
    pkgs.neovim-remote
    pkgs.nil
    pkgs.pylyzer
    pkgs.pyright
    pkgs.ruff
    pkgs.rust-analyzer
  ];
}

