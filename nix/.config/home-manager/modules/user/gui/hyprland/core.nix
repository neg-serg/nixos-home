{
  lib,
  config,
  pkgs,
  xdg,
  ...
}:
with lib; let
  hyprWinList = pkgs.writeShellApplication {
    name = "hypr-win-list";
    runtimeInputs = [
      pkgs.python3
      pkgs.wl-clipboard
    ];
    text = let
      tpl = builtins.readFile ../hypr/hypr-win-list.py;
    in ''
                   exec python3 <<'PY'
      ${tpl}
      PY
    '';
  };
  coreFiles = [
    "init.conf"
    "vars.conf"
    "classes.conf"
    "rules.conf"
    "bindings.conf"
    "autostart.conf"
  ];
  mkHyprSource = rel:
    xdg.mkXdgSource ("hypr/" + rel) {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/hypr/conf/${rel}";
      recursive = false;
    };
in
  mkIf config.features.gui.enable (lib.mkMerge [
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        settings = {
          source = [
            # Apply permissions first so plugin load is allowed
            "${config.xdg.configHome}/hypr/permissions.conf"
            # Load plugins (hy3) before the rest of the config
            "${config.xdg.configHome}/hypr/plugins.conf"
            "${config.xdg.configHome}/hypr/init.conf"
          ];
        };
        systemd.variables = ["--all"];
      };
      home.packages = config.lib.neg.pkgsList (
        let
          groups = {
            core = [
              pkgs.hyprcursor # modern cursor theme format (replaces xcursor)
              pkgs.hypridle # idle daemon
              pkgs.hyprpicker # color picker
              pkgs.hyprpolkitagent # polkit agent
              pkgs.hyprprop # xprop-like tool for Hyprland
              pkgs.hyprutils # core utils for Hyprland
              pkgs.pyprland # Hyprland plugin system
              pkgs.upower # power management daemon
            ];
            qt = [
              pkgs.hyprland-qt-support # Qt integration fixes
              pkgs.kdePackages.qt6ct # Qt6 config tool
            ];
            tools = [hyprWinList]; # helper: list windows from Hyprctl JSON
          };
          flags = {
            core = true;
            tools = true;
            qt = config.features.gui.qt.enable;
          };
        in
          config.lib.neg.mkEnabledList flags groups
      );
      programs.hyprlock.enable = true;
    }
    # Core config files from repo
    (lib.mkMerge (map mkHyprSource coreFiles))
    # Dynamically generated plugin loader (pin to flake hy3 package)
    (xdg.mkXdgText "hypr/plugins.conf" (
      let
        pluginPath = "/etc/hypr/libhy3.so";
      in ''
        # Hyprland plugins
        plugin = ${pluginPath}
      ''
    ))
  ])
