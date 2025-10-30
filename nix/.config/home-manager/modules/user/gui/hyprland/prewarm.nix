{
  lib,
  pkgs,
  config,
  xdg,
  ...
}:
with lib; let
  cfg = config.neg.hypr.prewarm;
  # Local mkBool to avoid early dependency on config.lib.neg during option evaluation
  mkBool = desc: default: (lib.mkEnableOption desc) // { inherit default; };

  # Render optional window rules for prewarmed apps
  mkRulesText = apps:
    let
      mkOne = a: let
        # Build match expression for Hyprland windowrulev2
        match =
          if (a.class or null) != null then "class:^(${a.class})$"
          else if (a.match or null) != null then a.match
          else null;
        rules =
          lib.concatStringsSep "\n" (
            lib.concatLists [
              (lib.optional (match != null) ("windowrulev2 = noinitialfocus, " + match))
              (
                let target = a.workspace or null; in
                lib.optional ((match != null) && (target != null))
                ("windowrulev2 = workspace name:" + target + ", " + match)
              )
            ]
          );
      in rules;
      lines = lib.filter (s: s != "") (map mkOne apps);
    in
      if (lines == []) then "# no prewarm rules"
      else "# prewarm: generated rules\n" + (lib.concatStringsSep "\n" lines) + "\n";

  # Build systemd user services for each app
  mkServices = apps:
    lib.listToAttrs (map (a: {
      name = "warm-" + a.name;
      value = lib.mkMerge [
        {
          Unit.Description = "Prewarm: " + a.name;
          Service = {
            ExecStart = a.exec;
            Restart = "on-failure";
            RestartSec = 2;
            Slice = "background-graphical.slice";
            # Don't tear down children when reloading the unit
            KillMode = "mixed";
            Environment = lib.optionals ((a.environment or {}) != {}) (
              lib.mapAttrsToList (k: v: "${k}=${toString v}") a.environment
            );
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; })
      ];
    }) apps);
in {
  # Options: neg.hypr.prewarm
  options.neg.hypr.prewarm = {
    enable = mkBool "Enable persistent prewarmed apps managed by systemd (Hyprland)" false;
    apps = lib.mkOption {
      type = with lib.types;
        listOf (submodule ({...}: {
          options = {
            name = mkOption {
              type = str;
              description = "Logical name for the app (used in unit name warm-<name>).";
            };
            exec = mkOption {
              type = str;
              description = "ExecStart command (absolute path or relies on PATH).";
              example = "floorp";
            };
            package = mkOption {
              type = nullOr package;
              default = null;
              description = "Optional package to add to home.packages for this app.";
            };
            class = mkOption {
              type = nullOr str;
              default = null;
              description = "Optional Hyprland class regex (without ^$) to match the app for rules.";
              example = "(one\\.ablaze\\.floorp|floorp)";
            };
            match = mkOption {
              type = nullOr str;
              default = null;
              description = "Advanced Hyprland windowrulev2 match (e.g., 'title:^Foo$'). Overrides class when set.";
            };
            workspace = mkOption {
              type = nullOr str;
              default = null;
              description = "Optional workspace name (exact, e.g., ' 𐌱:web') for routing rule.";
            };
            environment = mkOption {
              type = attrsOf (oneOf [str int bool]);
              default = {};
              description = "Extra environment variables for the service.";
            };
          };
        }));
      default = [];
      description = "List of apps to prewarm as persistent user services.";
    };
  };

  # Config
  config = lib.mkIf (config.features.gui.enable && (cfg.enable or false)) (lib.mkMerge [
    # Optional Hyprland rules to keep windows unfocused on start and route to a workspace
    (lib.mkIf (((cfg.apps or []) != [])) (
      lib.mkMerge [
        (xdg.mkXdgText "hypr/rules-prewarm.conf" (mkRulesText cfg.apps))
        {
          wayland.windowManager.hyprland.settings.source = lib.mkAfter [
            "${config.xdg.configHome}/hypr/rules-prewarm.conf"
          ];
        }
      ]
    ))

    # Systemd (user) services per app
    {
      systemd.user.services = mkServices (cfg.apps or []);
    }

    # Optional: install declared packages if provided (kept minimal)
    (let
      pkgsToInstall = builtins.filter (p: p != null) (map (a: a.package or null) (cfg.apps or []));
    in {
      home.packages = config.lib.neg.pkgsList pkgsToInstall;
    })
  ]);
}
