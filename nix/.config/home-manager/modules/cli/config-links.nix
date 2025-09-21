{ lib, config, xdg, ... }:
lib.mkMerge [
  # dircolors, f-sy-h, zsh from dotfiles; inputrc inline
  (xdg.mkXdgSource "dircolors" { source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/shell/.config/dircolors"; recursive = true; })
  (xdg.mkXdgSource "f-sy-h" { source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/shell/.config/f-sy-h"; recursive = true; })
  (xdg.mkXdgText "inputrc" (builtins.readFile ./inputrc))
  (xdg.mkXdgSource "zsh" { source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/shell/.config/zsh"; recursive = true; })
  # Soft migration note for Zsh: configuration is managed via $ZDOTDIR ($XDG_CONFIG_HOME/zsh)
  # If legacy ~/.zshrc or ~/.zshenv still exist, remove them or make them source
  # "$ZDOTDIR/zshrc" to avoid precedence issues.
  {
    warnings = [
      "Zsh is configured via $ZDOTDIR ($XDG_CONFIG_HOME/zsh). If ~/.zshrc or ~/.zshenv still exist, remove or source $ZDOTDIR/zshrc."
    ];
  }
]
