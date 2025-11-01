{
  lib,
  pkgs,
  config,
  xdg,
  ...
}:
with lib;
  mkIf config.features.gui.enable (
    lib.mkMerge [
      {
        # Reserved for Wayland-specific session variables if needed
        home.sessionVariables = {};
      }
      # Expose UWSM user units in XDG systemd path.
      # Minimal, no detection; matches uwsm-0.24.x layout.
      (xdg.mkXdgSource "systemd/user/wayland-wm@.service" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-wm@.service";
      })
      (xdg.mkXdgSource "systemd/user/wayland-wm-env@.service" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-wm-env@.service";
      })
      (xdg.mkXdgSource "systemd/user/wayland-wm-app-daemon.service" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-wm-app-daemon.service";
      })
      (xdg.mkXdgSource "systemd/user/wayland-session@.target" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-session@.target";
      })
      (xdg.mkXdgSource "systemd/user/wayland-session-pre@.target" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-session-pre@.target";
      })
      (xdg.mkXdgSource "systemd/user/wayland-session-shutdown.target" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-session-shutdown.target";
      })
      (xdg.mkXdgSource "systemd/user/wayland-session-xdg-autostart@.target" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-session-xdg-autostart@.target";
      })
      (xdg.mkXdgSource "systemd/user/wayland-session-bindpid@.service" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-session-bindpid@.service";
      })
      (xdg.mkXdgSource "systemd/user/wayland-session-waitenv.service" {
        source = "${pkgs.uwsm}/lib/systemd/user/wayland-session-waitenv.service";
      })
      # Graphical slices used by UWSM
      (xdg.mkXdgSource "systemd/user/app-graphical.slice" {
        source = "${pkgs.uwsm}/lib/systemd/user/app-graphical.slice";
      })
      (xdg.mkXdgSource "systemd/user/background-graphical.slice" {
        source = "${pkgs.uwsm}/lib/systemd/user/background-graphical.slice";
      })
      (xdg.mkXdgSource "systemd/user/session-graphical.slice" {
        source = "${pkgs.uwsm}/lib/systemd/user/session-graphical.slice";
      })
    ]
  )
