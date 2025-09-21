{ lib, config, ... }:
with lib;
mkIf (config.features.mail.enable && config.features.mail.vdirsyncer.enable) (
  let
    xdg = import ../../../lib/xdg-helpers.nix { inherit lib; };
    tpl = builtins.readFile ./config.tpl;
    stateHome = (config.xdg.stateHome or "$HOME/.local/state");
    home = config.home.homeDirectory;
    rendered = lib.replaceStrings ["@XDG_STATE@" "@HOME@"] [ stateHome home ] tpl;
  in xdg.mkXdgText "vdirsyncer/config" rendered
)

