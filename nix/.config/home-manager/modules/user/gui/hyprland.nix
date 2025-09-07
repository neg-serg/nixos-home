{
  config,
  pkgs,
  hy3,
  inputs,
  ...
}: let
  hy3Plugin = hy3.packages.${pkgs.system}.hy3;
in {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
      source = [
        "${config.xdg.configHome}/hypr/init.conf"
      ];
      permission = [
        "${hy3Plugin}/lib/libhy3.so, plugin, allow"
        "${pkgs.grim}/bin/grim, screencopy, allow"
        "${pkgs.hyprlock}/bin/hyprlock, screencopy, allow"
      ];
    };
    plugins = [
      hy3Plugin
    ];
    systemd.variables = ["--all"];
  };
  # Deploy Hypr config files from the repo
  xdg.configFile."hypr/init.conf".source = inputs.self + "/wm/.config/hypr/init.conf";
  xdg.configFile."hypr/autostart.conf".source = inputs.self + "/wm/.config/hypr/autostart.conf";
  xdg.configFile."hypr/rules.conf".source = inputs.self + "/wm/.config/hypr/rules.conf";
  xdg.configFile."hypr/bindings.conf".source = inputs.self + "/wm/.config/hypr/bindings.conf";
  xdg.configFile."hypr/workspaces.conf".source = inputs.self + "/wm/.config/hypr/workspaces.conf";
  xdg.configFile."hypr/pyprland.toml".source = inputs.self + "/wm/.config/hypr/pyprland.toml";
  home.packages = with pkgs; [
    hyprcursor # is a new cursor theme format that has many advantages over the widely used xcursor.
    hypridle # idle daemon
    hyprland-qt-support # qt support
    hyprland-qtutils # utility apps for hyprland
    hyprpicker # color picker
    hyprpolkitagent # better polkit agent
    hyprprop # xrop for hyprland
    hyprutils # small library for hyprland
    kdePackages.qt6ct
    pyprland # hyperland plugin system
    upower
  ];
  programs.hyprlock.enable = true;
}
