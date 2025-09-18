{ lib, config, ... }:
let
  cfgDev = config.features.dev;
  enableIac = cfgDev.enable && (config.features.dev.pkgs.iac or false);
  XDG_CFG = config.home.sessionVariables.XDG_CONFIG_HOME or "${config.home.homeDirectory}/.config";
  XDG_DATA = config.home.sessionVariables.XDG_DATA_HOME or "${config.home.homeDirectory}/.local/share";
  XDG_CACHE = config.home.sessionVariables.XDG_CACHE_HOME or "${config.home.homeDirectory}/.cache";
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in
  lib.mkIf enableIac (lib.mkMerge [
    {
      # Environment hints for tools that prefer env vars over ansible.cfg
      home.sessionVariables = {
        ANSIBLE_CONFIG = "${XDG_CFG}/ansible/ansible.cfg";
        ANSIBLE_ROLES_PATH = "${XDG_DATA}/ansible/roles";
        ANSIBLE_GALAXY_COLLECTIONS_PATHS = "${XDG_DATA}/ansible/collections";
      };
    }
  (let
     cfgTemplate = builtins.readFile ./ansible.cfg;
     rendered = lib.replaceStrings ["@XDG_DATA@" "@XDG_CFG@" "@XDG_CACHE@"] [XDG_DATA XDG_CFG XDG_CACHE] cfgTemplate;
   in xdg.mkXdgText "ansible/ansible.cfg" rendered)
  (xdg.mkXdgText "ansible/hosts" (builtins.readFile ./hosts))
  # Data/cache .keep files via helpers (ensure real dirs + safe writes)
  (xdg.mkXdgDataText "ansible/roles/.keep" "")
  (xdg.mkXdgDataText "ansible/collections/.keep" "")
  (xdg.mkXdgCacheText "ansible/facts/.keep" "")
  (xdg.mkXdgCacheText "ansible/ssh/.keep" "")
])
