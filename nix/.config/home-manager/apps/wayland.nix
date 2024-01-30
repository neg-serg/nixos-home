{ config, pkgs, negwmPkg, ... }: {
    home.packages = with pkgs; [
        # fnott # wayland notifications
        # fuzzel # wayland launcher
        # wtype # xdotool for wayland
    ];
}
