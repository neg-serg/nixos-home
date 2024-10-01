{...}: {
  services.picom.enable = true;
  services.picom.settings = {
    backend = "glx";
    active-opacity = 1.0;
    detect-client-leader = true;
    detect-client-opacity = true;
    detect-rounded-corners = false;
    detect-transient = true;
    frame-opacity = 1.0;
    glx-no-rebind-pixmap = false;
    inactive-dim = 0.0;
    inactive-opacity = 1.0;
    transparent-clipping = false;
    unredir-if-possible = true;
    use-damage = true;
    vsync = false;
    xrender-sync-fence = false; # set true for nvidia only

    wintypes = {
      dock = {
        opacity = 1.0;
        shadow = false;
        full-shadow = false;
      };
      menu = {
        fade = false;
        opacity = false;
        shadow = false;
        full-shadow = false;
      };
      utility = {
        fade = false;
        opacity = false;
        shadow = false;
        full-shadow = false;
      };
      tooltip = {
        fade = false;
        opacity = false;
        shadow = false;
        full-shadow = false;
        focus = false;
      };
      dropdown_menu = {
        opacity = 0.89;
        fade = false;
        shadow = false;
        full-shadow = false;
      };
      popup_menu = {
        opacity = 0.89;
        fade = false;
        shadow = false;
        full-shadow = false;
      };
    };

    opacity-exclude = [
      "class_g = 'mpv'"
      "class_i = 'mpv'"
    ];

    focus-exclude = [
      "class_g = 'Polybar'"
      "class_g = 'mpv'"
      "class_g = 'rofi'"
      "class_g = 'slop'"
      "class_g *?= 'Steam'"
      "name *?= 'Steam'"
    ];

    blur-background-exclude = [
      "class_g = 'nwim'"
      "class_g = 'slop'"
      "class_g = 'term'"
      "class_i = 'nwim'"
      "class_i = 'term'"
      "name *= 'overlay'"
      "window_type = 'desktop'"
      "window_type = 'dnd'"
      "_GTK_FRAME_EXTENTS@"
    ];

    blur = {
      method = "dual_kawase";
      blur-strengh = 5;
      blur-background-fixed = true;
    };

    opacity-rule = [
      "80:class_g = 'i3-frame'"
      "95:class_g = 'Zathura'"
      "100:class_g = 'mpv'"
      "100:class_g = 'slop'"
      "100:fullscreen"
      "0:_NET_WM_STATE@ *= '_NET_WM_STATE_HIDDEN'"
      "100:_GTK_FRAME_EXTENTS@"
    ];

    shadow-exclude = [
      "!focused"
      "class_g = 'Conky'"
      "class_g = 'Dunst'"
      "class_g = 'Firefox' && argb"
      "class_g = 'Rofi'"
      "name *= 'polybar'"
      "name = 'cpt_frame_window'" # Zoom
      "name = 'cpt_frame_xcb_window'" # Zoom
      "name = 'as_toolbar'" # Zoom
      "_GTK_FRAME_EXTENTS@"
      "_NET_WM_STATE@ *= '_NET_WM_STATE_HIDDEN'"
    ];

    shadow = true;
    shadow-radius = 9.0;
    shadow-offset-x = -9.0;
    shadow-offset-y = -9.0;
    shadow-opacity = 0.8;
    shadow-red = 0.0;
    shadow-green = 0.3;
    shadow-blue = 0.35;
    # shadow-exclude-reg = "x10+0+0";
  };
}
