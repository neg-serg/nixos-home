{ config, pkgs, negwmPkg, executorPkg, ... }:
with rec {
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
                ExecStart = "${pkgs.zsh}/bin/zsh -c \"echo 'circle next term' | ${pkgs.netcat}/bin/nc localhost 15555 -w 0\"";
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
                ExecReload = ["${pkgs.i3}/i3-msg reload" "${systemctl} --user restart negwm.service"];
                ExecStopPost = "${systemctl} --user stop --no-block graphical-session.target";
                NotifyAccess = "all";
                RemainAfterExit = "yes";
            };
        };
    };

}
