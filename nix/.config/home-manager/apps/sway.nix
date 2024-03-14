{ pkgs, lib, ... }: {
    home.sessionVariables = {};
    home.packages = with pkgs; [
        fnott # wayland notifications
        fuzzel # wayland launcher
        swww # wallpaper daemon for wayland
        wtype # xdotool for wayland
        ydotool # xdotool systemwide
	sway
    ];
}

# bindsym Mod4+Return exec kitty
# bindsym Mod1+grave exec ~/bin/rofi-run
# 
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
