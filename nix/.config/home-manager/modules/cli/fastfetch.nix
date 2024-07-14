{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    fastfetch # nice fetch
    onefetch # show you git stuff
  ];
  xdg.configFile."fastfetch/skull".text = ''
                          :::!~!!!!!:.
                      .xUHWH!! !!?M88WHX:.
                    .X*#M@$!!  !X!M$$$$$$WWx:.
                   :!!!!!!?H! :!$!$$$$$$$$$$8X:
                  !!~  ~:~!! :~!$!#$$$$$$$$$$8X:
                 :!~::!H!<   ~.U$X!?R$$$$$$$$MM!
                 ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!
                   !:~~~ .:!M"T#$$$$WX??#MRRMMM!
                   ~?WuxiW*`   `"#$$$$8!!!!??!!!
                 :X- M$$$$       `"T#$T~!8$WUXU~
                :%`  ~#$$$m:        ~!~ ?$$$$$$
              :!`.-   ~T$$$$8xx.  .xWW- ~""##*"
    .....   -~~:<` !    ~?T#$$@@W@*?$$      /`
    W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :
    #"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`
    :::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~
    .~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `
    Wi.~!X$?!-~    : ?$$$B$Wu("**$RM!
    $R@i.~~ !     :   ~$$$$$B$$en:``
    ?MXT@Wx.~    :     ~"##*$$$$M~
  '';
  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
    logo = {
      source = "~/.config/fastfetch/skull";
      width = 65;
      padding = {
        left = 1;
        right = 3;
      };
    };
    display = {
      color = {
        keys = "3";
        title = "4";
      };
      size = {maxPrefix = "PB";};
      percent = {type = 3;};
    };
    modules = [
      {
        type = "os";
        key = "󱄅 system";
        format = "{3}";
      }
      {
        type = "kernel";
        key = " kernel";
        format = "{1} {2} ({4})";
      }
      {
        type = "uptime";
        key = " uptime";
      }
      {
        type = "wm";
        key = " wm";
      }
      {
        type = "wmtheme";
        key = " wmtheme";
      }
      {
        type = "command";
        key = "󰆧 packages";
        text = "(${lib.getExe' pkgs.nix "nix-store"} --query --requisites /run/current-system | wc -l | tr -d '\n') && echo ' (nix; /run/current-system)'";
      }
      {
        type = "memory";
        key = "󰍛 memory";
      }
      {
        type = "host";
        key = "🖥 host";
      }
      {
        type = "monitor";
        key = " monitor";
      }
      {
        type = "theme";
        key = " theme";
      }
      {
        type = "icons";
        key = " icons";
      }
      {
        type = "cursor";
        key = " cursor";
      }
      {
        type = "locale";
        key = " language";
      }
      {
        type = "shell";
        key = "︁ shell";
      }
      {
        type = "terminal";
        key = "︁ terminal";
      }
      {
        type = "terminalfont";
        key = "︁ term-font";
      }
      {
        type = "terminalsize";
        key = "︁ term-size";
      }
      {
        type = "cpu";
        key = " CPU";
      }
      {
        type = "board";
        key = " board";
      }
      {
        type = "bios";
        key = " bios";
      }
      {
        type = "vulkan";
        key = " vulkan";
      }
      {
        type = "disk";
        key = " disk";
      }
      {
        type = "sound";
        key = " sound";
      }
      {
        type = "player";
        key = " player";
      }
      {
        type = "weather";
        key = " weather";
      }
    ];
  };
}
