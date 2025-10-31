{  
  lib,
  config,
  xdg,
  ...
}:
with lib;
  mkIf config.features.web.enable (
    let
      base = "${config.neg.dotfilesRoot}/misc/.config/tridactyl";
      rcPath = let bck = base + "/tridactylrc.bck"; in if builtins.pathExists bck then bck else (base + "/tridactylrc");
      themesPath = let bck = base + "/themes.bck"; in if builtins.pathExists bck then bck else (base + "/themes");
      mozillaPath = let bck = base + "/mozilla.bck"; in if builtins.pathExists bck then bck else (base + "/mozilla");
      userjsPath = let bck = base + "/user.js.bck"; in if builtins.pathExists bck then bck else (base + "/user.js");
      # Compose Tridactyl config to allow a small post-source override without
      # rewriting the user's rc in misc/ (restores Ctrl+C cancel in ex-mode).
      rcText = ''
        source ${rcPath}
        " Ensure Ctrl+C cancels commandline/completions in ex-mode
        bind --mode=ex <C-c> composite unfocus | mode normal
      '';
    in
      lib.mkMerge [
        # Ensure ~/.config/tridactyl is a real dir (not a previous symlink)
        { home.activation.fixTridactylDir = config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/tridactyl"; }
        # Write rc overlay that sources user's file and then applies small fixups
        (xdg.mkXdgText "tridactyl/tridactylrc" rcText)
        # Link supplemental files/dirs from misc (prefer *.bck real copies to avoid symlink cycles)
        (xdg.mkXdgSource "tridactyl/user.js" {
          source = config.lib.file.mkOutOfStoreSymlink userjsPath;
          recursive = false;
        })
        (xdg.mkXdgSource "tridactyl/themes" {
          source = config.lib.file.mkOutOfStoreSymlink themesPath;
          recursive = true;
        })
        (xdg.mkXdgSource "tridactyl/mozilla" {
          source = config.lib.file.mkOutOfStoreSymlink mozillaPath;
          recursive = true;
        })
      ]
  )
