{ pkgs, lib, config, ... }:
let
  inherit (lib) optionals;
  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = super: {
      python3-lto = super.python3.override {
        packageOverrides = _: _: {
          enableOptimizations = true;
          enableLTO = true;
          reproducibleBuild = false;
        };
      };
    };
  };
  home.packages = with pkgs;
    let
      core = ps: with ps; [
        colored
        docopt
        numpy
        annoy
        orjson
        psutil
        requests
        tabulate
      ];
      tools = ps: with ps; [
        dbus-python # need for some scripts
        fontforge # for font monospacifier
        pynvim
      ];
      pyPackages = ps:
        (optionals config.features.dev.python.core (core ps))
        ++ (optionals config.features.dev.python.tools (tools ps));
    in [
      pipx
      (python3-lto.withPackages pyPackages)
    ];
}
