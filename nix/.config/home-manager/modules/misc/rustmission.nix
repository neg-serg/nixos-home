{
  lib,
  config,
  xdg,
  ...
}:
lib.mkMerge [
  # Live-editable out-of-store symlink via helper (guards parent dir and target)
  (xdg.mkXdgSource "rustmission" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/misc/rustmission/conf";
    recursive = true;
  })
]
