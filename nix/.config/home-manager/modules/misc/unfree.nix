{ lib, config, ... }:
with lib;
let
  cfg = config.features.allowUnfree or {};
in {
  options.features.allowUnfree.allowed = mkOption {
    type = types.listOf types.str;
    default = [
      "yandex-browser-stable"
      "lmstudio"
      "code-cursor-fhs"
    ];
    description = "List of allowed unfree package names (by pname).";
  };

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg:
      let
        name = (pkg.pname or (builtins.parseDrvName (pkg.name or "")).name);
      in builtins.elem name config.features.allowUnfree.allowed;
  };
}

