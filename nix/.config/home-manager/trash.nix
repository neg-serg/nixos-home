# # config = mkMerge [
#     (mkIf cfg.enable {
#       home-manager.users."${user}" = { programs.zsh.shellAliases = { nlo = "${pkgs.nix-index}/bin/nix-locate --"; }; };
#       systemd.user.services."nix-update-index" = {
#         description = "Update nix packages metadata index";
#         serviceConfig = {
#           Type = "oneshot";
#           CPUSchedulingPolicy = "idle";
#           IOSchedulingClass = "idle";
#           ExecStart = "${pkgs.nix-index}/bin/nix-index";
#           StandardOutput = "journal";
#           StandardError = "journal";
#         };
#       };
#       systemd.user.timers."nix-update-index" = renderTimer "Update nix packages metadata index" "" "" "*-*-* 6:00:00" false ""; })
#   ];

#   nixpkgs-patched = (import nixpkgs { inherit system; }).applyPatches {
#   name = "nixpkgs-patched";
#   src = nixpkgs;
#   patches = [ ./example-patch.nix ];
# };

# # configure pkgs
# pkgs = import nixpkgs-patched { inherit system; };

# # configure lib
# lib = nixpkgs.lib;

# #nixpkgs.overlays = [
#       # "overwrite" xdg-open with handlr
#       (final: prev: {
#           # very expensive since this invalidates the cache for a lot of (almost all) graphical apps.
#           xdg-utils = prev.xdg-utils.overrideAttrs (oldAttrs: {
#               postInstall = oldAttrs.postInstall + ''
#                   # "overwrite" xdg-open with handlr
#                   cp ${prev.writeShellScriptBin "xdg-open" "${prev.handlr}/bin/handlr open \"$@\""}/bin/xdg-open $out/bin/xdg-open
#               '';
#           });
#       })
#   ];

# nixpkgs.overlays = [
#       (final: prev: {
#            libadwaita = prev.libadwaita.overrideAttrs (o: {
#                patches = (o.patches or [ ]) ++ [ ./patch/libadwaita-without-adwaita.patch ];
#            });
#        })
# ];

# nixosConfigurations = {
#     jano = nixpkgs.lib.nixosSystem {
#         system = "x86_64-linux";
#         modules = [
#             ({ pkgs, ... }: {
#              nixpkgs.overlays = [
#              inputs.neovim-nightly-overlay.overlay
#              ];
#              pkgs = [
#              inputs.st.packages."${pkgs.system}".st-snazzy
#              ];
#              })
#         ./host
#             home-manager.nixosModules.home-manager
#         ];
#         specialArgs = { inherit inputs; };
#     };
# };

# systemd.user.services.polybar = {
#     Unit = {
#         Description = "Polybar statusbar";
#         PartOf = ["graphical-session.target"];
#         StartLimitIntervalSec = "60";
#         Requires = "xsettingsd.service";
#     };
#     Service = {
#         ExecStart = "${pkgs.dash}/bin/dash -lc ${pkgs.polybar}/bin/polybar -q main";
#         ExecStop = "${pkgs.polybar}/bin/polybar-msg cmd quit";
#         Restart = "on-failure";
#         RestartSec = "3";
#         StartLimitBurst = "30";
#     };
#     Install = { WantedBy = ["graphical-session.target"]; };
# };

# systemd.user.services.polybar-watcher = {
#     Unit = {
#         Description = "Polybar autorestart service";
#         After = ["network.target"];
#     };
#     Service = {
#         Type = "oneshot";
#         ExecStart = "${systemctl} --user restart polybar.service";
#     };
#     Install = { WantedBy = ["graphical-session.target"]; };
# };
#
# systemd.user.paths.polybar-watcher = {
#     Unit = { Description = "Enable polybar on change"; };
#     Path = { PathChanged = "%E/polybar/config.ini"; };
#     Install = { WantedBy = ["graphical-session.target"]; };
# };

# systemd.user.services.xsettingsd = {
#     Unit = {
#         Description = "XSETTINGS daemon";
#         PartOf = ["graphical-session.target"];
#         StartLimitIntervalSec = "0";
#     };
#     Service = {
#         Restart = "on-failure";
#         ExecStartPre = "-${pkgs.util-linux}/bin/mkdir %E/xsettingsd";
#         ExecStart = "%h/bin/xsettingsd-setup";
#         ExecReload = [
#             "${pkgs.util-linux}/bin/kill -HUP $MAINPID"
#             "${pkgs.i3}/bin/i3-msg reload"
#             "${systemctl} --user try-restart polybar.service"
#             "${systemctl} --user try-reload-or-restart picom.service"
#         ];
#     };
#     Install = { WantedBy = ["graphical-session.target"]; };
# };
