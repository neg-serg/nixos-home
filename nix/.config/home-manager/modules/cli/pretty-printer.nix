{ lib, pkgs, config, ... }:
with lib;
lib.mkMerge [
  {
    # Install the library + CLI (ppinfo)
    home.packages = config.lib.neg.pkgsList [
      pkgs.neg.pretty_printer # pretty-printer library + ppinfo CLI
    ];
  }
  {
    # Make pretty_printer visible to generic Python invocations (e.g. /usr/bin/env python3)
    # by setting PYTHONPATH to include the packaged library paths.
    home.sessionVariables.PYTHONPATH = let
      libpp = "${pkgs.neg.pretty_printer}/${pkgs.python3.sitePackages}";
      libcolored = "${pkgs.python3Packages.colored}/${pkgs.python3.sitePackages}";
    in lib.concatStringsSep ":" [ libpp libcolored ];
  }
  {
    # Legacy cleanup removed to reduce activation noise; PATH prefers ~/.local/bin now.
  }
  (
    # Add a user site .pth to expose the library on Python's sys.path for scripts
    # that import `pretty_printer` or `neg_pretty_printer` directly via /usr/bin/env python3
    let
      verFull = pkgs.python3.pythonVersion; # e.g. "3.13.0"
      parts = lib.splitString "." verFull;
      pyMM = lib.concatStringsSep "." (lib.take 2 parts); # e.g. "3.13"
      userSite = "${config.home.homeDirectory}/.local/lib/python${pyMM}/site-packages";
      pkgPath = "${pkgs.neg.pretty_printer}/${pkgs.python3.sitePackages}";
      coloredPath = "${pkgs.python3Packages.colored}/${pkgs.python3.sitePackages}";
      pth = builtins.concatStringsSep "\n" [ pkgPath coloredPath ];
    in {
      home.file."${userSite}/neg_pretty_printer.pth".text = pth;
    }
  )
]
