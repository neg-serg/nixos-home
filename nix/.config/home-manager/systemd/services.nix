{ pkgs, negwmPkg, executorPkg, ... }:
with {
    systemctl = "${pkgs.systemd}/bin/systemctl";
};{
    systemd.user.services = {
        executor = {
            Unit = {
                Description = "Terminal manager";
                PartOf = ["graphical-session.target"];
                StartLimitBurst = "5";
                StartLimitIntervalSec = "1";
            };
            Service = {
                Environment = "PATH=/home/neg/bin:/bin:/home/neg/.local/bin:/run/wrappers/bin:/home/neg/.local/bin:/home/neg/.nix-profile/bin:/home/neg/.local/state/nix/profile/bin:/etc/profiles/per-user/neg/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
                ExecStart = "${executorPkg.executor}/bin/executor daemon";
                Restart = "on-failure";
            };
        };

        negwm = {
            Unit = {
                Description = "negwm window manager mod for i3wm";
                PartOf = ["graphical-session.target"];
                StartLimitBurst = "5";
                StartLimitIntervalSec = "0";
            };
            Service = {
                Environment = "PATH=/home/neg/bin:/bin:/home/neg/.local/bin:/run/wrappers/bin:/home/neg/.local/bin:/home/neg/.nix-profile/bin:/home/neg/.local/state/nix/profile/bin:/etc/profiles/per-user/neg/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
                ExecStart = "${negwmPkg.negwm}/bin/negwm";
                Restart = "on-failure";
            };
        };

        negwm-autostart = {
            Unit = {
                Description = "Startup stuff depended on negwm";
                Requires = "negwm.service";
                After = ["negwm.service" "executor.service"];
            };
            Service = {
                Type = "oneshot";
                ExecStart = "${pkgs.zsh}/bin/zsh -c \"echo 'circle next term' | ${pkgs.netcat-openbsd}/bin/nc localhost 15555 -w 0\"";
                Restart = "on-failure";
                RestartSec = "1";
                StartLimitBurst = "20";
            };
        };

        openrgb = {
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

        shot-optimizer = {
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

        pass-secret-service = {
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

        pic-dirs = {
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

        i3 = {
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
                ExecReload = ["${pkgs.i3}/bin/i3-msg reload" "${systemctl} --user restart negwm.service"];
                ExecStopPost = "${systemctl} --user stop --no-block graphical-session.target";
                NotifyAccess = "all";
            };
        };

        polkit-gnome-authentication-agent-1 = {
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

        misc-x = {
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

        xiccd = {
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

        xss-lock = {
            Unit = {
                Description = "Session locker";
            };
            Service = {
                ExecStart = "${pkgs.xss-lock}/bin/xss-lock --transfer-sleep-lock -- %h/bin/x11lock";
                Restart = "on-failure";
            };
        };

        picom = {
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

        warpd = {
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

        unclutter = {
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

        inputplug = {
            Unit = {
                Description = "XInput event monitor";
                PartOf = ["graphical-session.target"];
            };
            Service = {
                ExecStart = "${pkgs.inputplug}/bin/inputplug -d -0 -c %h/bin/input-event";
                Restart = "on-failure";
            };
        };

        sway = {
            Unit = {
                Description = "sway - SirCmpwn's Wayland window manager";
                Documentation = "man:sway(5)";
                BindsTo = ["graphical-session.target"];
                Wants = ["graphical-session-pre.target"];
                After = ["graphical-session-pre.target"];
	    };
            Service = {
                Type = "simple";
                EnvironmentFile = "-%h/.config/sway/env";
                ExecStartPre = "${pkgs.systemd}/bin/systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY"; # This line make you able to logout to dm and login into sway again
                ExecStart = "${pkgs.sway}/bin/sway";
                Restart = "on-failure";
                RestartSec = "1";
                TimeoutStopSec = "10";
	    };
	};
    };
}
