{ lib, config, pkgs, xdg, ... }:
with lib; let
  hyprWinList = pkgs.writeShellApplication {
    name = "hypr-win-list";
    runtimeInputs = [ pkgs.jq pkgs.gawk pkgs.coreutils pkgs.gnused ];
    text = let tpl = builtins.readFile ../hypr/hypr-win-list.sh;
           in lib.replaceStrings ["@HYPRCTL@"] [ (lib.getExe' pkgs.hyprland "hyprctl") ] tpl;
  };
  coreFiles = [
    "init.conf"
    "vars.conf"
    "classes.conf"
    "rules.conf"
    "bindings.conf"
    "autostart.conf"
  ];
  mkHyprSource = rel: xdg.mkXdgSource ("hypr/" + rel) {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/hypr/conf/${rel}";
    recursive = false;
  };
in mkIf config.features.gui.enable (lib.mkMerge [
  {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      settings = {
        source = [
          "${config.xdg.configHome}/hypr/permissions.conf"
          "${config.xdg.configHome}/hypr/init.conf"
        ];
      };
      systemd.variables = ["--all"];
    };
    home.packages =
      config.lib.neg.pkgsList (
        let
          groups = {
            core = [
              pkgs.hyprcursor
              pkgs.hypridle
              pkgs.hyprpicker
              pkgs.hyprpolkitagent
              pkgs.hyprprop
              pkgs.hyprutils
              pkgs.pyprland
              pkgs.upower
            ];
            qt = [
              pkgs.hyprland-qt-support
              pkgs.hyprland-qtutils
              pkgs.kdePackages.qt6ct
            ];
            tools = [ hyprWinList ];
          };
          flags = {
            core = true;
            tools = true;
            qt = config.features.gui.qt.enable;
          };
        in config.lib.neg.mkEnabledList flags groups
      );
    programs.hyprlock.enable = true;
  }
  # Core config files from repo
  (lib.mkMerge (map mkHyprSource coreFiles))
])
