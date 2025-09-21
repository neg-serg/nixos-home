{ pkgs, lib, config, xdg, ... }:
lib.mkMerge [
  # Install tmux and provide its configuration via XDG
  # Avoid adding base python when a python env is present elsewhere (prevents bin/idle conflict)
  {
    home.packages = config.lib.neg.pkgsList [
      pkgs.tmux # terminal multiplexer
      pkgs.wl-clipboard # Wayland clipboard (wl-copy/wl-paste)
    ];

  }
  # Ship the entire tmux config directory (conf + bin) via pure helper
  (xdg.mkXdgSource "tmux" { source = ./tmux-conf; })
  # Soft migration note: tmux config is managed under $XDG_CONFIG_HOME/tmux
  # If you still have legacy ~/.tmux.conf or ~/.tmux, prefer migrating to
  # $XDG_CONFIG_HOME/tmux/tmux.conf to avoid precedence confusion.
  {
    warnings = [
      "tmux config is under $XDG_CONFIG_HOME/tmux. If ~/.tmux.conf or ~/.tmux still exist, migrate to ~/.config/tmux/tmux.conf."
    ];
  }
]
