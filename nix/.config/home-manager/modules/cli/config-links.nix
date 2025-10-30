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
  # Fish config (conf.d drop-ins)
  (xdg.mkXdgSource "fish" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/shell/.config/fish";
    recursive = true;
  })
  # Bash XDG config directory
  (xdg.mkXdgSource "bash" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/shell/.config/bash";
    recursive = true;
  })
  # Ensure classic ~/.bashrc sources XDG bashrc
  {
    home.file.".bashrc".text = ''
      # Forward to XDG bashrc managed by Home Manager
      if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash/bashrc" ]; then
        . "${XDG_CONFIG_HOME:-$HOME/.config}/bash/bashrc"
      fi
    '';
  }
]
