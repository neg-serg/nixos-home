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
      # Compose Tridactyl config to allow a small post-source override without
      # rewriting the user's rc in misc/ (restores Ctrl+C cancel in ex-mode).
      rcText = ''
        source ${base}/tridactylrc
        " Ensure Ctrl+C cancels commandline/completions in ex-mode
        bind --mode=ex <C-c> composite unfocus | mode normal
      '';
    in
      lib.mkMerge [
        # Write rc overlay that sources user's file and then applies small fixups
        (xdg.mkXdgText "tridactyl/tridactylrc" rcText)
        # Link supplemental files/dirs from misc
        (xdg.mkXdgSource "tridactyl/user.js" {
          source = config.lib.file.mkOutOfStoreSymlink "${base}/user.js";
          recursive = false;
        })
        (xdg.mkXdgSource "tridactyl/themes" {
          source = config.lib.file.mkOutOfStoreSymlink "${base}/themes";
          recursive = true;
        })
        (xdg.mkXdgSource "tridactyl/mozilla" {
          source = config.lib.file.mkOutOfStoreSymlink "${base}/mozilla";
          recursive = true;
        })
      ]
  )
