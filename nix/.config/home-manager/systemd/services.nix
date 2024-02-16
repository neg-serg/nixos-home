{ config, pkgs, negwmPkg, executorPkg, ... }:
with rec {
    systemctl = "${pkgs.systemd}/bin/systemctl";
};{
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
    };

    systemd.user.services.xsettingsd = {
        Unit = {
            Description = "XSETTINGS daemon";
            PartOf = ["graphical-session.target"];
            StartLimitIntervalSec = "0";
        };
        Service = {
            Restart = "on-failure";
            ExecStartPre = "-${pkgs.util-linux}/bin/mkdir %E/xsettingsd";
            ExecStart = "%h/bin/xsettingsd-setup";
            ExecReload = [
                "${pkgs.util-linux}/bin/kill -HUP $MAINPID"
                "${pkgs.i3}/bin/i3-msg reload"
                "${systemctl} --user try-restart polybar.service"
                "${systemctl} --user try-reload-or-restart picom.service"
            ];
        };
        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.xiccd = {
        Unit = {
            Description = "X color management";
            PartOf = "graphical-session.target";
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

    systemd.user.services.executor = {
        Unit = {
            Description = "Terminal manager";
            PartOf = ["graphical-session.target"];
            StartLimitBurst = "5";
            StartLimitIntervalSec = "1";
            Requires = ["i3.service"];
        };
        Service = {
            Environment = "PATH=/home/neg/bin:/bin:/home/neg/.local/bin:/run/wrappers/bin:/home/neg/.local/bin:/home/neg/.nix-profile/bin:/home/neg/.local/state/nix/profile/bin:/etc/profiles/per-user/neg/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
            ExecStart = "${executorPkg.executor}/bin/executor daemon";
            Restart = "on-failure";
        };
    };

    systemd.user.services.transmission-daemon = {
        Unit = {
            Description = "transmission service";
            After = ["network.target"];
            ConditionPathExists = "${pkgs.transmission}/bin/transmission-daemon";
        };
        Service = {
            Type = "notify";
            ExecStart = "${pkgs.transmission}/bin/transmission-daemon -g %E/transmission-daemon -f --log-error";
            Restart = "on-failure";
            RestartSec = "30";
            StartLimitBurst = "8";
            ExecReload = "${pkgs.util-linux}/bin/kill -s HUP $MAINPID";
        };
        Install = { WantedBy = ["default.target"]; };
    };

    systemd.user.services.negwm-autostart = {
        Unit = {
            Description = "Startup stuff depended on negwm";
            Requires = "negwm.service";
            After = ["negwm.service" "executor.service"];
        };
        Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.zsh}/bin/zsh -c \"echo 'circle next term' | ${pkgs.netcat}/bin/nc localhost 15555 -w 0\"";
            Restart = "on-failure";
            RestartSec = "1";
            StartLimitBurst = "20";
        };
    };

    systemd.user.services.negwm = {
        Unit = {
            Description = "negwm window manager mod for i3wm";
            PartOf = ["graphical-session.target"];
            StartLimitBurst = "5";
            StartLimitIntervalSec = "0";
            Requires = ["i3.service"];
        };
        Service = {
            Environment = "PATH=/home/neg/bin:/bin:/home/neg/.local/bin:/run/wrappers/bin:/home/neg/.local/bin:/home/neg/.nix-profile/bin:/home/neg/.local/state/nix/profile/bin:/etc/profiles/per-user/neg/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
            ExecStart = "${negwmPkg.negwm}/bin/negwm";
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

    systemd.user.services.mpDris = {
        Unit = {
            Description = "mpDris2 - Music Player Daemon D-Bus bridge";
            After = ["playerctld.service" "network.target" "sound.target" "mpd.service"];
            PartOf = ["mpd.socket" "mpd.service"];
        };
        Service = {
            Type = "simple";
            Restart = "on-failure";
            ExecStart = "${pkgs.writeShellScriptBin "delay-mpdris2" "${pkgs.coreutils}/bin/sleep 1 && ${pkgs.mpdris2}/bin/mpDris2"}/bin/delay-mpdris2";
        };
        Install = { WantedBy = ["default.target"]; };
    };

    systemd.user.services.cover-notify = {
        Unit = {
            Description = "Music track notification with cover";
            After = ["network.target" "sound.target" "playerctld.service" "mpd.service" "mpDris.service"];
            BindsTo = "mpDris.service";
            StartLimitIntervalSec = "0";
        };
        Service = {
            ExecStart = "${pkgs.cached-nix-shell}/bin/cached-nix-shell -p 'python3.withPackages (p: [p.pygobject3 p.systemd])' -p gobject-introspection -p playerctl --run %h/bin/track-notification-daemon";
            Restart = "always";
            RestartSec = "3";
        };
    };

    systemd.user.services.openrgb = {
        Unit = {
            Description = "OpenRGB Configuration utility for RGB lights supporting motherboards, RAM, & peripherals";
            After = ["dbus.socket"];
            PartOf = ["graphical-session.target"];
        };
        Service = {
            ExecStart = "${pkgs.openrgb}/bin/openrgb --server -p neg.orp";
            RestartSec = "30";
            StartLimitBurst = "8";
        };
        Install = { WantedBy = ["default.target"]; };
    };

    systemd.user.services.playerctld = {
        Unit = {
            Description = "Keep track of media player activity";
            After = ["network.target" "sound.target"];
            BindsTo = "mpd.service";
        };

        Service = {
            Type = "forking";
            ExecStart = "${pkgs.playerctl}/bin/playerctld daemon";
            RestartSec = "3";
            StartLimitBurst = "0";
        };
        Install = { WantedBy = ["default.target"]; };
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

    systemd.user.services.polybar = {
        Unit = {
            Description = "Polybar statusbar";
            PartOf = ["graphical-session.target"];
            StartLimitIntervalSec = "60";
            Requires = "xsettingsd.service";
            BindsTo = "xsettingsd.service";
        };
        Service = {
            ExecStart = "${pkgs.dash}/bin/dash -lc ${pkgs.polybar}/bin/polybar -q main";
            ExecStop = "${pkgs.polybar}/bin/polybar-msg cmd quit";
            Restart = "on-failure";
            RestartSec = "3";
            StartLimitBurst = "30";
        };
        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.polybar-watcher = {
        Unit = {
            Description = "Polybar autorestart service";
            After = ["network.target"];
        };
        Service = {
            Type = "oneshot";
            ExecStart = "${systemctl} --user restart polybar.service";
        };
        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.paths.polybar-watcher = {
        Unit = { Description = "Enable polybar on change"; };
        Path = { PathChanged = "%E/polybar/config.ini"; };
        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.mpdas = {
        Unit = {
            Description = "mpdas last.fm scrobbler";
            After = ["network.target" "sound.target" "mpd.service"];
            Requires = "mpd.service";
        };
        Service = {
            ExecStart = "${pkgs.mpdas}/bin/mpdas -c ${config.sops.secrets.mpdas_negrc.path}";
            Restart = "on-failure";
            RestartSec = "10";
        };
        Install = { WantedBy = ["default.target"]; };
    };

    systemd.user.services.shot-optimizer = {
        Unit = {
            Description = "Optimize screenshots";
            After = ["sockets.target"];
        };
        Service = {
            ExecStart = "%h/bin/shot-optimizer";
            WorkingDirectory = "%h/pic/shots";
            PassEnvironment = "HOME";
            Restart = "on-failure";
            RestartSec = "1";
            StartLimitBurst = "0";
        };
        Install = { WantedBy = ["default.target"]; };
    };

    systemd.user.services.pass-secret-service = {
        Unit = {
            Description = "pass secret service";
            After = ["sockets.target"];
        };
        Service = {
            ExecStart = "${pkgs.pass-secret-service}/bin/pass_secret_service --path %h/.local/share/pass";
            PassEnvironment = ["HOME"];
            Restart = "on-failure";
            RestartSec = "1";
            StartLimitBurst = "0";
        };
        Install = { WantedBy = ["default.target"]; };
    };

    systemd.user.services.pic-dirs = {
        Unit = {
            Description = "Pic dirs notification";
            After = ["sockets.target"];
            StartLimitIntervalSec = "0";
        };
        Service = {
            ExecStart = "/bin/sh -lc '%h/bin/pic-dirs-list'";
            PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
            Restart = "on-failure";
            RestartSec = "1";
        };
        Install = { WantedBy = ["default.target"]; };
    };

    systemd.user.services.unclutter = {
        Unit = {
            Description = "Unclutter to hide cursor";
            PartOf = ["graphical-session.target"];
            StartLimitIntervalSec = "60";
        };
        Service = {
            ExecStart = "${pkgs.unclutter-xfixes}/bin/unclutter --timeout 3 --jitter 50 --ignore-scrolling --start-hidden";
            Restart = "on-failure";
            RestartSec = "3";
        };
        Install = { WantedBy = ["graphical-session.target"]; };
    };

    systemd.user.services.i3 = {
        Unit = {
            Description = "i3 improved dynamic tiling window manager for X";
            Documentation = "man:i3(5)";
            BindsTo = ["graphical-session.target"];
            Wants = ["graphical-session-pre.target"];
            After = ["graphical-session-pre.target"];
        };
        Service = {
            Type = "notify";
            ExecStart = "/bin/sh -lc ${pkgs.i3}/bin/i3";
            ExecReload = ["${pkgs.i3}/i3-msg reload" "${systemctl} --user restart negwm.service"];
            ExecStopPost = "${systemctl} --user stop --no-block graphical-session.target";
            Restart = "on-failure";
            NotifyAccess="all";
        };
    };
    
    systemd.user.services.mpd = {
        Unit = {
            Description = "Music Player Daemon";
            Documentation = "man:mpd(1) man:mpd.conf(5)";
            After = ["network.target" "sound.target"];
            ConditionPathExists = "${pkgs.mpd}/bin/mpd";
        };
        Service = {
            Type = "notify";
            ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon";
            WatchdogSec = 120;
            LimitRTPRIO = "40"; # allow MPD to use real-time priority 40
            LimitRTTIME = "infinity";
            LimitMEMLOCK = "64M"; # for io_uring
            ProtectSystem = "yes"; # disallow writing to /usr, /bin, /sbin, ...
            NoNewPrivileges = "yes";
            ProtectKernelTunables = "yes";
            ProtectControlGroups = "yes";
            # AF_NETLINK is required by libsmbclient, or it will exit() .. *sigh*
            RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
            RestrictNamespaces = "yes";
            Restart = "on-failure";
            RestartSec = "5";
        };
        Install = { WantedBy = ["default.target"]; };
    };
}
