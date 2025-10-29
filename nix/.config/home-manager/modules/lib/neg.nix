{
  lib,
  pkgs,
  config,
  ...
}: {
  # Project-specific helpers under lib.neg
  config.lib.neg = rec {
    # Configurable root of your dotfiles repository (see options.neg.dotfilesRoot)

    # mkEnabledList flags groups -> concatenated list of groups
    # flags: { a = true; b = false; }
    # groups: { a = [pkg1]; b = [pkg2]; }
    # => [pkg1]
    mkEnabledList = flags: groups: let
      names = builtins.attrNames groups;
    in
      lib.concatLists (
        builtins.map (n: lib.optionals (flags.${n} or false) (groups.${n} or [])) names
      );

    # Alias
    mkPackagesFromGroups = flags: groups: (mkEnabledList flags groups);

    # Package list helpers
    pnameOf = pkg: (pkg.pname or (builtins.parseDrvName (pkg.name or "")).name);
    filterByNames = names: pkgsList:
      builtins.filter (p: !(builtins.elem (pnameOf p) names)) pkgsList;
    # Apply global excludePkgs filter to a list of packages by pname
    # Example: exclude tools like "dsniff" from curated groups without editing modules
    filterByExclude = pkgsList:
      builtins.filter (p: !(builtins.elem (pnameOf p) (config.features.excludePkgs or []))) pkgsList;

    # Shorthand: apply global excludePkgs filter to a list of packages
    # Usage (preferred explicit pkgs.* form):
    #   home.packages = config.lib.neg.pkgsList [ pkgs.foo pkgs.bar ];
    pkgsList = filterByExclude;

    # Emit a warning (non-fatal) when condition holds
    mkWarnIf = cond: msg: {
      warnings = lib.optional cond msg;
    };

    # Make an enable option with default value
    mkBool = desc: default:
      (lib.mkEnableOption desc) // {inherit default;};

    # Conditional sugar for readability in mkMerge blocks
    # Usage:
    #   lib.mkMerge [ (config.lib.neg.mkWhen cond { ... }) (config.lib.neg.mkUnless cond { ... }) ]
    mkWhen = cond: attrs: lib.mkIf cond attrs;
    mkUnless = cond: attrs: lib.mkIf (! cond) attrs;

    # mkDotfilesSymlink removed to avoid config.lib recursion in evaluation.

    # Browser addons helper: produce well-known addon lists given NUR addons set
    browserAddons = fa: {
      common = with fa; [
        augmented-steam
        cookie-quick-manager
        darkreader
        enhanced-github
        export-tabs-urls-and-titles
        lovely-forks
        search-by-image
        stylus
        tabliss
        to-google-translate
        tridactyl
      ];
    };

    # Systemd (user) helpers to avoid repeating arrays in many modules
    systemdUser = let
      # Preset collections of common targets
      presets = {
        graphical = {
          after = ["graphical-session.target"];
          wants = ["graphical-session.target"];
          wantedBy = ["graphical-session.target"];
          partOf = [];
        };
        defaultWanted = {
          after = [];
          wants = [];
          wantedBy = ["default.target"];
          partOf = [];
        };
        timers = {
          after = [];
          wants = [];
          wantedBy = ["timers.target"];
          partOf = [];
        };
        net = {
          after = ["network.target"];
          wants = [];
          wantedBy = [];
          partOf = [];
        };
        netOnline = {
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = [];
          partOf = [];
        };
        sops = {
          after = ["sops-nix.service"];
          wants = ["sops-nix.service"];
          wantedBy = [];
          partOf = [];
        };
        dbusSocket = {
          after = ["dbus.socket"];
          wants = [];
          wantedBy = [];
          partOf = [];
        };
        socketsTarget = {
          after = ["sockets.target"];
          wants = [];
          wantedBy = [];
          partOf = [];
        };
      };
      # Merge preset array fields with optional extras and produce Unit/Install
      mkUnitFromPresets = args: let
        # args: { presets = ["graphical" "defaultWanted" ...]; after ? [], wants ? [], partOf ? [], wantedBy ? [] }
        names = args.presets or [];
        accum =
          lib.foldl'
          (acc: n: {
            after = acc.after ++ (presets.${n}.after or []);
            wants = acc.wants ++ (presets.${n}.wants or []);
            partOf = acc.partOf ++ (presets.${n}.partOf or []);
            wantedBy = acc.wantedBy ++ (presets.${n}.wantedBy or []);
          })
          {
            after = [];
            wants = [];
            partOf = [];
            wantedBy = [];
          }
          names;
        merged = {
          after = lib.unique (accum.after ++ (args.after or []));
          wants = lib.unique (accum.wants ++ (args.wants or []));
          partOf = lib.unique (accum.partOf ++ (args.partOf or []));
          wantedBy = lib.unique (accum.wantedBy ++ (args.wantedBy or []));
        };
      in {
        Unit =
          lib.optionalAttrs (merged.after != []) {After = merged.after;}
          // lib.optionalAttrs (merged.wants != []) {Wants = merged.wants;}
          // lib.optionalAttrs (merged.partOf != []) {PartOf = merged.partOf;};
        Install = lib.optionalAttrs (merged.wantedBy != []) {WantedBy = merged.wantedBy;};
      };
    in {
      inherit presets mkUnitFromPresets;

      # Minimal sugar to declare a simple user service with presets.
      # Usage:
      #   (config.lib.neg.systemdUser.mkSimpleService {
      #     name = "aria2";
      #     description = "aria2 download manager";
      #     execStart = "${pkgs.aria2}/bin/aria2c --conf-path=$XDG_CONFIG_HOME/aria2/aria2.conf";
      #     presets = ["graphical"];
      #   })
      mkSimpleService = {
        name,
        execStart,
        presets ? [],
        description ? null,
        serviceExtra ? {},
        unitExtra ? {},
        after ? [],
        wants ? [],
        partOf ? [],
        wantedBy ? [],
      }: {
        systemd.user.services."${name}" =
          lib.recursiveUpdate
          {
            Unit =
              (lib.optionalAttrs (description != null) {Description = description;})
              // unitExtra;
            Service = {ExecStart = execStart;} // serviceExtra;
          }
          (mkUnitFromPresets {
            inherit presets after wants partOf wantedBy;
          });
      };

      # Minimal sugar to declare a simple Timer unit with presets.
      # Creates systemd.user.timers.<name>. Does not define the matching Service.
      # Defaults to WantedBy=["timers.target"] when using the "timers" preset and not overridden.
      # Usage:
      #   (config.lib.neg.systemdUser.mkSimpleTimer {
      #     name = "my-job"; onCalendar = "daily"; presets = ["timers"]; timerExtra = { Persistent = true; };
      #   })
      mkSimpleTimer = {
        name,
        presets ? [],
        description ? null,
        onCalendar ? null,
        accuracySec ? null,
        persistent ? null,
        timerExtra ? {},
        unitExtra ? {},
        after ? [],
        wants ? [],
        partOf ? [],
        wantedBy ? null,
      }: let
        # Default WantedBy to timers.target if not explicitly provided and timers preset is used
        finalWantedBy =
          if wantedBy != null
          then wantedBy
          else (lib.optional (lib.elem "timers" presets) "timers.target");
      in {
        systemd.user.timers."${name}" =
          lib.recursiveUpdate
          {
            Unit =
              (lib.optionalAttrs (description != null) {Description = description;})
              // unitExtra;
            Timer =
              {}
              // lib.optionalAttrs (onCalendar != null) {OnCalendar = onCalendar;}
              // lib.optionalAttrs (accuracySec != null) {AccuracySec = accuracySec;}
              // lib.optionalAttrs (persistent != null) {Persistent = persistent;}
              // timerExtra;
          }
          (mkUnitFromPresets {
            inherit presets after wants partOf;
            wantedBy = finalWantedBy;
          });
      };

      # Minimal sugar to declare a simple Socket unit with presets.
      # Creates systemd.user.sockets.<name>. Often pair with a .service of same name.
      # Defaults to WantedBy=["sockets.target"] when using the "socketsTarget" preset and not overridden.
      # Usage:
      #   (config.lib.neg.systemdUser.mkSimpleSocket {
      #     name = "my-sock"; listenStream = "%t/my.sock"; presets = ["socketsTarget"]; socketExtra = { SocketMode = "0600"; };
      #   })
      mkSimpleSocket = {
        name,
        presets ? [],
        description ? null,
        listenStream ? null,
        listenDatagram ? null,
        listenFIFO ? null,
        socketExtra ? {},
        unitExtra ? {},
        after ? [],
        wants ? [],
        partOf ? [],
        wantedBy ? null,
      }: let
        finalWantedBy =
          if wantedBy != null
          then wantedBy
          else (lib.optional (lib.elem "socketsTarget" presets) "sockets.target");
      in {
        systemd.user.sockets."${name}" =
          lib.recursiveUpdate
          {
            Unit =
              (lib.optionalAttrs (description != null) {Description = description;})
              // unitExtra;
            Socket =
              {}
              // lib.optionalAttrs (listenStream != null) {ListenStream = listenStream;}
              // lib.optionalAttrs (listenDatagram != null) {ListenDatagram = listenDatagram;}
              // lib.optionalAttrs (listenFIFO != null) {ListenFIFO = listenFIFO;}
              // socketExtra;
          }
          (mkUnitFromPresets {
            inherit presets after wants partOf;
            wantedBy = finalWantedBy;
          });
      };
    };

    # Web helpers defaults
    # Provide a safe fallback default browser so modules can refer to
    # config.lib.neg.web.defaultBrowser even when features.web.enable = false.
    web.defaultBrowser = lib.mkDefault {
      name = "xdg-open";
      pkg = pkgs.xdg-utils;
      bin = "${pkgs.xdg-utils}/bin/xdg-open";
      desktop = "xdg-open.desktop";
      newTabArg = "";
    };

    # Home activation DAG helpers to avoid repeating small shell snippets
    # Usage patterns:
    #   home.activation.fixZsh = config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/zsh";
    #   home.activation.fixGdbDir = config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/gdb";
    #   home.activation.fixTigFile = config.lib.neg.mkRemoveIfNotSymlink "${config.xdg.configHome}/tig/config";
    mkRemoveIfSymlink = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -L "${path}" ]; then
          rm -f "${path}"
        fi
      '';

    # Remove the path only if it is a broken symlink (preserve valid symlinks)
    mkRemoveIfBrokenSymlink = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -L "${path}" ] && [ ! -e "${path}" ]; then
          rm -f "${path}"
        fi
      '';

    mkEnsureRealDir = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -L "${path}" ]; then
          rm -f "${path}"
        fi
        mkdir -p "${path}"
      '';

    # Ensure multiple directories exist before linkGeneration and are real dirs (not symlinks)
    # For each path: if path is a symlink, remove it, then mkdir -p path
    mkEnsureRealDirsMany = paths: let
      quoted = lib.concatStringsSep " " (map (p: ''"'' + p + ''"'') paths);
    in
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        for p in ${quoted}; do
          if [ -L "$p" ]; then
            rm -f "$p"
          fi
          mkdir -p "$p"
        done
      '';

    mkRemoveIfNotSymlink = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -e "${path}" ] && [ ! -L "${path}" ]; then
          rm -f "${path}"
        fi
      '';

    # Ensure directories exist after HM writes files
    # Useful for app runtime dirs that must be present before services start.
    mkEnsureDirsAfterWrite = paths: let
      quoted = lib.concatStringsSep " " (map (p: ''"'' + p + ''"'') paths);
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        set -eu
        mkdir -p ${quoted}
      '';

    # XDG aggregated fixups removed; prefer per-file force=true when needed.

    # Ensure a set of Maildir-style folders exist under a base path.
    # Example: mkEnsureMaildirs "$HOME/.local/mail/gmail" ["INBOX" "[Gmail]/Sent Mail" ...]
    mkEnsureMaildirs = base: boxes: let
      mkLine = b: ''mkdir -p "${base}/${b}/cur" "${base}/${b}/new" "${base}/${b}/tmp"'';
      body = lib.concatStringsSep "\n" (map mkLine boxes);
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        set -eu
        ${body}
      '';

    # Ensure a path is absent before HM links/writes files.
    # Removes regular files with rm -f and directories with rm -rf, ignores symlinks
    # (combine with mkRemoveIfSymlink if needed).
    mkEnsureAbsent = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -e "${path}" ] && [ ! -L "${path}" ]; then
          if [ -d "${path}" ]; then
            rm -rf "${path}"
          else
            rm -f "${path}"
          fi
        fi
      '';

    mkEnsureAbsentMany = paths: let
      scriptFor = p: ''
        if [ -e "${p}" ] && [ ! -L "${p}" ]; then
          if [ -d "${p}" ]; then rm -rf "${p}"; else rm -f "${p}"; fi
        fi
      '';
      body = lib.concatStringsSep "\n" (map scriptFor paths);
    in
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        ${body}
      '';

    # Ensure the parent directory of a path is a real directory (not a symlink)
    # and exists. Uses dirname at runtime to avoid brittle string parsing in Nix.
    mkEnsureRealParent = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        parent_dir="$(dirname "${path}")"
        if [ -L "$parent_dir" ]; then
          rm -f "$parent_dir"
        fi
        mkdir -p "$parent_dir"
      '';

    # Create a local wrapper script under ~/.local/bin with activation-time guard.
    # See packages/lib/local-bin.nix for implementation details.
    mkLocalBin = import ../../packages/lib/local-bin.nix {inherit lib;};

    # XDG file helpers were split into a dedicated pure helper module
    # to avoid config/lib coupling in regular modules. Prefer importing
    # modules/lib/xdg-helpers.nix locally where needed:
    #   let xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
    #   in xdg.mkXdgText "path/in/config" "...contents..."
    # See STYLE.md ("XDG file helpers") for examples and guidance.
  };

  # Provide a typed option for dotfiles root
  options.neg.dotfilesRoot = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.dotfiles";
    description = "Path to the root of the user's dotfiles repository.";
    example = "/home/neg/.cfg";
  };

  # Optional integration points for modules under the 'neg' namespace
  options.neg.quickshell = {
    wrapperPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Wrapped quickshell package (provides 'qs') with required QT/QML env prefixes.";
      example = "pkgs.callPackage ./path/to/wrapper.nix {}";
    };
  };

  # Rofi package (single source of truth) used by wrapper and config
  options.neg.rofi = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.rofi.override {
        plugins = [
          pkgs.rofi-file-browser # file browser mode for rofi
          pkgs.neg.rofi_games # custom games menu plugin
        ];
      };
      description = "Rofi build with required plugins (file-browser, rofi-games).";
    };
  };
}
