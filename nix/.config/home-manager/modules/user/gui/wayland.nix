{
  lib,
  pkgs,
  config,
  iwmenuProvider ? null,
  ...
}:
with lib;
  mkIf config.features.gui.enable (
    let
      devSpeed = config.features.devSpeed.enable or false;
      groups = {
        core = with pkgs; [
          dragon-drop # drag-n-drop from console
          gowall # tool to convert a Wallpaper's color scheme / palette
          grimblast # hyprland screenshot tool
          grim # to take screenshots
          slurp # select region in wayland compositor
          swww # wallpaper daemon for wayland
          waybar # status bar (Wayland)
          waypipe # proxy for wayland similar to ssh -X
          wev # xev for wayland
          wf-recorder # tool to make screencasts
          wl-clipboard # copy-paste for wayland
          wl-clip-persist # clipboard persistence tool
          wtype # typing for wayland
        ];
        # extras evaluated only when enabled (prevents pulling input in dev-speed)
        extras = lib.optionals (! devSpeed && (iwmenuProvider != null)) [ (iwmenuProvider pkgs) ];
      };
      flags = { core = true; extras = true; };
    in {
      home.sessionVariables = {};
      home.packages = config.lib.neg.pkgsList (config.lib.neg.mkEnabledList flags groups);
    }
  )
