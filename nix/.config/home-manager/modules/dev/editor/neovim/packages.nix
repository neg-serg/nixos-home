{ config, pkgs, ... }:
{
  home.packages = config.lib.neg.pkgsList [
    pkgs.bash-language-server # Bash LSP
    pkgs.neovim # Neovim editor
    pkgs.neovim-remote # nvr (remote control for Neovim)
    pkgs.nil # Nix language server
    pkgs.pylyzer # Python type checker
    pkgs.pyright # Python LSP
    pkgs.ruff # Python linter
    pkgs.rust-analyzer # Rust LSP
    pkgs.clang-tools # Clangd + friends
    pkgs.lua-language-server # Lua LSP
    pkgs.hyprls # Hyprland language server
    pkgs.emmet-language-server # Emmet LSP
    pkgs.yaml-language-server # YAML LSP
    pkgs.taplo # TOML toolkit + LSP
    pkgs.marksman # Markdown LSP
    pkgs.nodePackages_latest.typescript-language-server # TS/JS LSP
    pkgs.nodePackages_latest.vscode-langservers-extracted # HTML/CSS/etc LSPs
    pkgs.qt6.qtdeclarative # Provides qmlls
    pkgs.just-lsp # Justfile LSP
    pkgs.lemminx # XML LSP
    pkgs.awk-language-server # AWK LSP
    pkgs.cmake-language-server # CMake LSP
    pkgs.dhall-lsp-server # Dhall LSP
    pkgs.docker-compose-language-service # Docker Compose LSP
    pkgs.nodePackages_latest.dockerfile-language-server-nodejs # Dockerfile LSP
    pkgs.dot-language-server # Graphviz dot LSP
  ];
}
