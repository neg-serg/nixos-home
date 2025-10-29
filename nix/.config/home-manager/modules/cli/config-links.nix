{
  lib,
  config,
  xdg,
  ...
}:
lib.mkMerge [
  # dircolors, f-sy-h, zsh from dotfiles; inputrc inline
  (xdg.mkXdgSource "dircolors" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/shell/.config/dircolors";
    recursive = true;
  })
  (xdg.mkXdgSource "f-sy-h" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/shell/.config/f-sy-h";
    recursive = true;
  })
  (xdg.mkXdgText "inputrc" (builtins.readFile ./inputrc))
  (xdg.mkXdgSource "zsh" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/shell/.config/zsh";
    recursive = true;
  })
]
