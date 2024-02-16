{ config, pkgs, ... }: {
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
        Unit = {
            Description = "polkit-gnome-authentication-agent-1";
            Wants = ["graphical-session.target"];
            After = ["graphical-session.target"];
        };
        Service = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
        };
        Install = { WantedBy = ["default.target"]; };
    };

    systemd.user.services.misc-x = {
        Unit = {
            Description = "Miscellaneous settings for X11";
            PartOf = ["graphical-session.target"];
            BindsTo = ["graphical-session.target"];
        };
        Service = {
            ExecStart = [
                "${pkgs.xorg.xset}/bin/xset dpms 0 0 0"
                "${pkgs.xorg.xset}/bin/xset -b"
                "${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr"
            ];
            Type = "oneshot";
            RemainAfterExit = "false";
        };
        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.xiccd = {
        Unit = {
            Description = "X color management";
            PartOf = "graphical-session.target";
            BindsTo = ["graphical-session.target"];
        };
        Service = {
            ExecStart = "${pkgs.xiccd}/bin/xiccd --edid";
            Restart = "on-failure";
        };
        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.xss-lock = {
        Unit = {
            Description = "Session locker";
        };
        Service = {
            ExecStart = "${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- %h/bin/x11lock";
            Restart = "on-failure";
        };
    };

    systemd.user.services.picom = {
        Unit = {
            Description = "Compositing manager";
            Documentation = "man:Xorg(1)";
            After = ["dbus.socket"];
            PartOf = ["graphical-session.target"];
            StartLimitIntervalSec = "60";
        };
        Service = {
            ExecStart = "${pkgs.picom}/bin/picom --dbus --backend glx";
            ExecReload = "${pkgs.util-linux}/bin/kill -SIGUSR1 $MAINPID";
            Restart = "on-failure";
            RestartSec = "1";
            StartLimitBurst = "3000";
        };
        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.warpd = {
        Unit = {
            Description = "Modal keyboard driven interface for mouse manipulation";
            PartOf = ["graphical-session.target"];
            After = ["dbus.socket"];
            StartLimitIntervalSec = "0";
        };

        Service = {
            ExecStart = "${pkgs.warpd}/bin/warpd -f";
            Restart = "always";
            RestartSec = "2";
            StartLimitBurst = "8";
        };

        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.unclutter = {
        Unit = {
            Description = "Unclutter to hide cursor";
            PartOf = ["graphical-session.target"];
            StartLimitIntervalSec = "60";
            BindsTo = ["graphical-session.target"];
        };

        Service = {
            ExecStart = "${pkgs.unclutter-xfixes}/bin/unclutter --timeout 3 --jitter 50 --ignore-scrolling --start-hidden";
            Restart = "on-failure";
            RestartSec = "3";
        };

        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.inputplug = {
        Unit = {
            Description = "XInput event monitor";
            PartOf = ["graphical-session.target"];
        };
        Service = {
            ExecStart = "${pkgs.inputplug}/bin/inputplug -d -0 -c %h/bin/input-event";
            Restart = "on-failure";
        };
    };
    
}
