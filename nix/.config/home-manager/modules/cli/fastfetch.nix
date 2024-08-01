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
      percent = {type = 9;};
    };
    modules = [
      {
        type = "os";
        key = "󱄅 System";
        format = "{3}";
      }
      {
        type = "kernel";
        key = " Kernel";
        format = "{1} {2} ({4})";
      }
      {
        type = "uptime";
        key = " Uptime";
      }
      {
        type = "wm";
        key = " WM";
      }
      {
        type = "command";
        key = "󰆧 Packages";
        text = "(${lib.getExe' pkgs.nix "nix-store"} --query --requisites /run/current-system | wc -l | tr -d '\n') && echo ' (nix; /run/current-system)'";
      }
      {
        type = "memory";
        key = "󰍛 Memory";
      }
      {
        type = "host";
        key = "🖥Host";
      }
      {
        type = "monitor";
        key = " Monitor";
      }
      {
        type = "theme";
        key = " Theme";
      }
      {
        type = "icons";
        key = " Icons";
      }
      {
        type = "cursor";
        key = " Cursor";
      }
      {
        type = "shell";
        key = "︁ Shell";
      }
      {
        type = "terminal";
        key = "︁ Terminal";
      }
      {
        type = "terminalfont";
        key = "︁ Font";
      }
      {
        type = "cpu";
        key = " CPU";
      }
      {
        type = "board";
        key = " Board";
      }
      {
        type = "gpu";
        key = " GPU";
      }
      {
        type = "bios";
        key = " BIOS";
      }
      {
        type = "vulkan";
        key = " Vulkan";
      }
      {
        type = "disk";
        key = " Disk";
      }
      {
        type = "sound";
        key = " Sound";
      }
      {
        type = "player";
        key = " Player";
      }
      {
        type = "users";
        key = " Users";
      }
      {
        type = "locale";
        key = " Locale";
      }
      {
        type = "weather";
        key = " Weather";
      }
    ];
  };
}
