{lib, ...}:{
    programs.mpv = {
      enable = true;

      config = {
        #--[Main]--------------------------------------------------
        input-ipc-server = "~/.config/mpv/socket";
        target-prim = "adobe";
        hidpi-window-scale = false;
        icc-profile-auto = true;
        #--[Decoding]----------------------------------------------
        cache = "no";
        correct-downscaling = true;
        hwdec-codecs = "all";
        interpolation = "no";
        vd-lavc-threads = "12";
        vo = "gpu-next";
        gpu-api = "vulkan";
        hwdec = "auto";
        vulkan-swap-mode = "fifo-relaxed";
        vf="format=colorlevels=full:colormatrix=auto";
        video-output-levels = "full";
        gpu-shader-cache-dir = "/home/neg/tmp/";
        icc-cache-dir = "/home/neg/tmp/";
        #--[Scaling]-----------------------------------------------
        cscale = "ewa_lanczossharp";
        dither-depth = "auto";
        dscale = "mitchell";
        linear-downscaling = "yes";
        sigmoid-upscaling = "yes";
        #--[Antiringing]-------------------------------------------
        cscale-antiring = "0.7"; # chroma upscale deringing
        dscale-antiring = "0.7"; # luma downscale deringing
        scale-antiring = "0.7";  # luma upscale deringing
        #--[Volume]------------------------------------------------
        ao = "pipewire,alsa,jack";
        volume-max = "100";
        volume = "100";
        #--[Language]----------------------------------------------
        alang = "en";
        slang = "ru,rus";
        #--[Geometry]----------------------------------------------
        fullscreen = "yes";
        geometry = "100%:100%";
        border = "no";
        #--[Subtitles]---------------------------------------------
        sub-auto = "fuzzy";
        sub-font = ["Helvetica Neue LT Std" "HelveticaNeue LT CYR 57 Cond"];
        sub-gauss = ".82";
        sub-gray = "yes";
        sub-scale = "0.7";
        #--[OSD]---------------------------------------------------
        osc = "no";
        osd-bar = "no";
        cursor-autohide = "500";
        osd-bar-align-y = "0";
        osd-bar-h = "3";
        osd-border-color = "#cc000000";
        osd-border-size = "1";
        osd-color = "#bb6d839e";
        osd-font-size = "24";
        osd-font = "Iosevka";
        osd-status-msg = "$\{time-pos\} / $\{duration\} ($\{percent-pos\}%)$\{?estimated-vf-fps: FPS: $\{estimated-vf-fps\}\}";
        #--[Youtube-DL]--------------------------------------------
        ytdl-format = "bestvideo+bestaudio/best";
        #--[ETC]---------------------------------------------------
        screenshot-template = "~/dw/scr-%F_%P";
        # vim: set ft=dosini:
      };

      profiles = {
        #--[Audio]-------------------------------------------------
        "extension.ape" = {
            term-osd-bar-chars = "──╼ ·";
            term-osd-bar = true;
            term-osd = "auto";
        };
        "extension.alac" = {
            term-osd-bar-chars = "──╼ ·";
            term-osd-bar = true;
            term-osd = "auto";
        };
        "extension.flac" = {
            term-osd-bar-chars = "──╼ ·";
            term-osd-bar = true;
            term-osd = "auto";
        };
        "extension.mp3" = {
            term-osd-bar-chars = "──╼ ·";
            term-osd-bar = true;
            term-osd = "auto";
        };
        "extension.wav" = {
            term-osd-bar-chars = "──╼ ·";
            term-osd-bar = true;
            term-osd = "auto";
        };
        "extension.gif" = {
            osc = "no";
            loop-file = true;
        };
      };

      bindings = lib.mkMerge [{   # mpv keybindings
        "+" = "add panscan +0.1";
        "-" = "add panscan -0.1";
        "q" = "quit";
        "tab" = "script-binding uosc/toggle-ui";

        "space" = "cycle pause; script-binding uosc/flash-pause-indicator";
        "p" = "cycle pause; script-binding uosc/flash-pause-indicator";
        "ctrl+enter" = "script-binding uosc/open-file";

        "a" = "show_text '\$\{path\}'";
        "i" = "script-message-to uosc flash-top-bar";

        ## the line under this one is not a comment
        "[" = "multiply speed 0.9091";
        "]" = "multiply speed 1.1";
        "BS" = "set speed 1.0";

        "d" = "cycle framedrop 1";
        # Next 3 currently only work with --no-ass
        "r" = "add sub-pos -1";         # move subtitles up
        "t" = "add sub-pos +1";         # down
        "v" = "cycle sub-visibility 1";
        "f" = "cycle fullscreen 1";
        "F" = "cycle fullscreen 1";

        #--[ Sometimes I double click and the window will resize ]--
        #--[ This makes it idiot proof ]----------------------------
        #--[ Navigation ]---------------
        "right" = "seek +5; script-binding uosc/flash-timeline";
        "left" = "seek -5; script-binding uosc/flash-timeline";
        "up" = "seek +5; script-binding uosc/flash-timeline";
        "down" = "seek -5; script-binding uosc/flash-timeline";
        "l" = "seek +5; script-binding uosc/flash-timeline";
        "h" = "seek -5; script-binding uosc/flash-timeline";
        "L" = "seek +60; script-binding uosc/flash-timeline";
        "H" = "seek -60; script-binding uosc/flash-timeline";
        #--[ Volume ]-------------------
        "0" = "no-osd add volume +1; script-binding uosc/flash-volume";
        "9" = "no-osd add volume -1; script-binding uosc/flash-volume";
        "m" = "no-osd cycle mute; script-binding uosc/flash-volume";
        "A" = "cycle audio 1";
        #--[ Playlist control ]---------
        ">" = "script-binding uosc/next; script-message-to uosc flash-elements top_bar,timeline";
        "<" = "script-binding uosc/prev; script-message-to uosc flash-elements top_bar,timeline";
        "ESC" = "playlist_next";
        "j" = "cycle sub";

        "mbtn_left" = "cycle pause 1";
        "mbtn_right" = "script-binding uosc/menu";
        ## vim: set cc= tw=0 ft=input.conf:
        
        # "Y" = "add sub-scale +0.1"; # increase subtitle font size
        # "G" = "add sub-scale -0.1"; # decrease subtitle font size
        # "y" = "sub_step -1"; # immediately display next subtitle
        # "g" = "sub_step +1"; # previous
        # "R" = "cycle_values window-scale 2 0.5 1"; # switch between 2x, 1/2, unresized window size

        # "l" = "seek 5";
        # "h" = "seek -5";
        # "j" = "seek -60";
        # "k" = "seek 60";

        # "s" = "cycle sub";
        # "a" = "cycle audio";

        # "Alt+h" = "add chapter -1";
        # "Alt+l" = "add chapter 1";
        # "Ctrl+SPACE" = "add chapter 1";

        # "Alt+j" = "add video-zoom -0.25";
        # "Alt+k" = "add video-zoom 0.25";

        # "Alt+J" = "add sub-pos -1";
        # "Alt+K" = "add sub-pos +1";

        # "Ctrl+h" = "multiply speed 1/1.1";
        # "Ctrl+l" = "multiply speed 1.1";
        # "Ctrl+H" = "set speed 1.0";

        # merge low1k's keybindings into mpv bindings section
        # low1k
      }];
    };
}

