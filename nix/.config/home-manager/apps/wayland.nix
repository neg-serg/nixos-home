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
