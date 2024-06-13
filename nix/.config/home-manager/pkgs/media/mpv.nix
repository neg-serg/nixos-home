{lib, ...}:{
    programs.mpv = {
      enable = true;

      config = {
        # https://freetime.mikeconnelly.com/archives/5371
        # https://github.com/classicjazz/mpv-config
        # https://github.com/mpv-player/mpv/blob/master/DOCS/man/options.rst
        #--[Main]--------------------------------------------------
        input-ipc-server = "~/.config/mpv/socket";
        hidpi-window-scale = false;
        #--[Decoding]----------------------------------------------
        cache = "no";
        correct-downscaling = true;
        hwdec-codecs = "all";
        vd-lavc-threads = "12";
        vo = "gpu-next";
        hwdec = "auto";
        gpu-api = "vulkan";
        vulkan-async-compute = true;
        vulkan-async-transfer = true;
        vulkan-queue-count = 1;
        vd-lavc-dr = true;
        vulkan-swap-mode = "fifo-relaxed";
        gpu-shader-cache-dir = "/home/neg/tmp/";
        icc-cache-dir = "/home/neg/tmp/";
        # profile=gpu-hq # used for any other OS on modern hardware
        # profile=gpu-next # for future use
        #--[ Debanding ]-------------------------------------------
        deband = true; # enabled by default 
        deband-iterations = 4; # deband steps
        deband-threshold = 48; # deband strength
        deband-range = 16; # deband range
        deband-grain = 48; # dynamic grain: set to "0" if using the static grain shader
        #--[ Interpolation ]---------------------------------------
        override-display-fps = 60;
        video-sync = "display-resample";
        interpolation = true;
        tscale = "oversample"; # smoothmotion
        #--[Color]-------------------------------------------------
        icc-profile-auto = true;
        # see https://github.com/mpv-player/mpv/wiki/Video-output---shader-stage-diagram
        target-prim = "adobe";
        # target-prim = "auto";
        # target-prim=bt.709 # target Rec.709 for SDR TVs
        # target-prim=bt.2020 # target Rec.2020 (wide color gamut) for HDR TVs
        target-trc = "auto";
        vf="format=colorlevels=full:colormatrix=auto";
        video-output-levels = "full";
        #--[Scaling]-----------------------------------------------
        cscale = "ewa_lanczossharp";
        dither-depth = "auto";
        dither = "fruit";
        temporal-dither = "yes";
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
        ###################################
        # Protocol Specific Configuration #
        ###################################
        "protocol.http" = {
            hls-bitrate = "max"; # use max quality for HLS streams
            cache = true;
            cache-pause = false; # don't pause when the cache runs low
        };
        "protocol.https" = { profile="protocol.http"; };
        "protocol.ytdl" = { profile="protocol.http"; };
        "4k60" = { # 2160p @ 60fps (3840x2160 UHDTV)
            profile-desc = "4k60";
            profile-cond = "((width ==3840 and height ==2160) and p[\"estimated-vf-fps\"]>=31)";
            # deband=yes # necessary to avoid blue screen with KrigBilateral.glsl
            deband = false; # turn off debanding because presume wide color gamut
            interpolation = false; # turn off interpolation because presume 60fps 
            # UHD videos are already 4K so no luma upscaling is needed
            # UHD videos are YUV420 so chroma upscaling is still needed
            glsl-shaders-clr=true;
            # glsl-shaders="~/etc/mpv/shaders/KrigBilateral.glsl" # enable if your hardware can support it
        };
        "4k30" = { # 2160p @ 24-30fps (3840x2160 UHDTV)
            profile-desc = "4k30";
            profile-cond = "((width ==3840 and height ==2160) and p[\"estimated-vf-fps\"]<31)";
            # deband=yes # necessary to avoid blue screen with KrigBilateral.glsl
            deband = false; # turn off debanding because presume wide color gamut
            # UHD videos are already 4K so no luma upscaling is needed
            # UHD videos are YUV420 so chroma upscaling is still needed
            glsl-shaders-clr=true;
            # glsl-shaders="~/etc/mpv/shaders/KrigBilateral.glsl" # enable if your hardware can support it
        };
        "full-hd60" = {  # 1080p @ 60fps (progressive ATSC)
            profile-desc = "full-hd60";
            profile-cond = "((width ==1920 and height ==1080) and not p[\"video-frame-info/interlaced\"] and p[\"estimated-vf-fps\"]>=31)";
            # apply all luma and chroma upscaling and downscaling settings
            interpolation = false; # no motion interpolation required because 60fps is hardware ceiling
        };
        "full-hd30" = {  # 1080p @ 24-30fps (NextGen TV/ATSC 3.0, progressive Blu-ray)
            profile-desc = "full-hd30";
            profile-cond = "((width ==1920 and height ==1080) and not p[\"video-frame-info/interlaced\"] and p[\"estimated-vf-fps\"]<31)";
            # apply all luma and chroma upscaling and downscaling settings
            interpolation = false; # no motion interpolation required because 60fps is hardware ceiling
        };
        "full-hd-interlaced" = {  # 1080i @ 24-30fps (HDTV, interlaced Blu-rays)
            profile-desc = "full-hd-interlaced";
            profile-cond = "((width ==1920 and height ==1080) and p[\"video-frame-info/interlaced\"] and p[\"estimated-vf-fps\"]<31)";
            # apply all luma and chroma upscaling and downscaling settings
            # apply motion interpolation
            vf = "bwdif"; # apply FFMPEG's bwdif deinterlacer
        };
        "hd" = { # 720p @ 60 fps (HDTV, Blu-ray - progressive)
            profile-desc = "hd";
            profile-cond = "(width == 1280 and height == 720)";
            # apply all luma and chroma upscaling and downscaling settings
            interpolation = false; # no motion interpolation required because 60fps is hardware ceiling
            # no deinterlacer required because progressive
        };
        "sdtv-ntsc" = { # 640x480, 704x480, 720x480 @ 30fps (NTSC DVD - interlaced)
            profile-desc = "sdtv-ntsc";
            profile-cond = "((width == 640 and height == 480) or (width == 704 and height == 480) or (width == 720 and height == 480))";
            # apply all luma and chroma upscaling and downscaling settings
            # apply motion interpolation
            vf = "bwdif"; # apply FFMPEG's bwdif deinterlacer
        }; 

        sdtv-pal = {  # 352x576, 480x576, 544x576, 720x576 @ 30fps (PAL broadcast or DVD - interlaced)
            profile-desc = "sdtv-pal";
            profile-cond = "((width==352 and height==576) or (width==480 and height==576) or (width==544 and height==576) or (width==720 and height==576))";
            # # apply all luma and chroma upscaling and downscaling settings
            # # apply motion interpolation
            vf = "bwdif"; # apply FFMPEG's bwdif deinterlacer
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

        "a" = "cycle audio";
        "i" = "script-message-to uosc flash-top-bar";

        ## the line under this one is not a comment
        "[" = "multiply speed 0.9091";
        "]" = "multiply speed 1.1";
        "BS" = "set speed 1.0";
        "Ctrl+h" = "multiply speed 1/1.1";
        "Ctrl+l" = "multiply speed 1.1";
        "Ctrl+H" = "set speed 1.0";
        

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
        "up" = "seek +30; script-binding uosc/flash-timeline";
        "down" = "seek -30; script-binding uosc/flash-timeline";
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
        "R" = "cycle_values window-scale 2 0.5 1"; # switch between 2x, 1/2, unresized window size
        "j" = "cycle sub";
        "s" = "cycle sub";

        "mbtn_left" = "cycle pause 1";
        "mbtn_right" = "script-binding uosc/menu";
        ## vim: set cc= tw=0 ft=input.conf:
      }];
    };
}

# #############################################################
# # Upscaling & Processing Based on Source Video's Resolution #
# #############################################################
# # Chroma subsampling means that chroma information is encoded at lower resolution than luma
# # In MPV, chroma is upscaled to luma resolution (video size) and then the converted RGB is upscaled to target resolution (screen size)
# # For detailed analysis of upscaler/downscaler quality, see https://artoriuz.github.io/blog/mpv_upscaling.html
# fbo-format=rgba16f # use with gpu-api=opengl
# # fbo-format=rgba16hf # use with gpu-api=vulkan
# # fbo-format is not not supported in gpu-next profile
# glsl-shaders-clr
# # luma upscaling
# # note: any FSRCNNX above FSRCNNX_x2_8-0-4-1 is not worth the additional computional overhead
# glsl-shaders="~/etc/mpv/shaders/FSRCNNX_x2_8-0-4-1.glsl"
# glsl-shaders="~/etc/mpv/shaders/FSRCNNX_x2_8-0-4-1.glsl"
# scale=ewa_lanczos
# # luma downscaling
# # note: ssimdownscaler is tuned for mitchell and downscaling=no
# glsl-shaders-append="~/etc/mpv/shaders/SSimDownscaler.glsl"
# dscale=mitchell
# linear-downscaling=no
# # chroma upscaling and downscaling
# glsl-shaders-append="~/etc/mpv/shaders/KrigBilateral.glsl" 
# cscale=mitchell # ignored with gpu-next
# sigmoid-upscaling=yes

