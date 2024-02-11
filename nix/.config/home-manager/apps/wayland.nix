{ pkgs, ... }: {
    home.sessionVariables = {
        WLR_BACKEND = "vulkan"; # nvidia compatibility
        WLR_DRM_NO_ATOMIC = "1";
        WLR_NO_HARDWARE_CURSORS = "1"; # nvidia compatibility
        WLR_RENDERER = "vulkan"; # nvidia compatibility
    };
    home.packages = with pkgs; [
        # fnott # wayland notifications
        # fuzzel # wayland launcher
        # wtype # xdotool for wayland
        ydotool # xdotool systemwide
    ];
}

# systemd.user.services.wpaperd = {
#     Unit = {
#         Description = "Wallpaper daemon";
#         After = ["graphical-session-pre.target"];
#         PartOf = ["graphical-session.target"];
#     };
#     Service = {
#         ExecStart = "${pkgs.wpaperd}/bin/wpaperd --no-daemon";
#         Environment = "XDG_CONFIG_HOME=${wpaperd-config-dir}";
#     };
#     Install.WantedBy = ["graphical-session.target"];
# };

# programs = {
#     gamescope = {
#         enable = true;
#         capSysNice = true;
#         args = [ "--steam"
#                 "--expose-wayland"
#                 "--rt"
#                 "-W 1920"
#                 "-H 1080"
#                 "--force-grab-cursor"
#                 "--grab"
#                 "--fullscreen"
#         ];
#     };
# }
