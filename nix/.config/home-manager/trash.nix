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
