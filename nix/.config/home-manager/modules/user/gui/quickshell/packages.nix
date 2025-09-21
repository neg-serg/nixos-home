{ lib, pkgs, config, rsmetrxProvider ? null, ... }:
with lib;
mkIf (config.features.gui.enable && (config.features.gui.qt.enable or false) && (! (config.features.devSpeed.enable or false))) {
  home.packages = config.lib.neg.pkgsList ([
    pkgs.cantarell-fonts
    pkgs.cava
    (if rsmetrxProvider != null then (rsmetrxProvider pkgs) else pkgs.emptyFile)
    pkgs.kdePackages.kdialog
    pkgs.kdePackages.qt5compat
    pkgs.kdePackages.qtdeclarative
    pkgs.kdePackages.qtimageformats
    pkgs.kdePackages.qtmultimedia
    pkgs.kdePackages.qtpositioning
    pkgs.kdePackages.qtquicktimeline
    pkgs.kdePackages.qtsensors
    pkgs.kdePackages.qtsvg
    pkgs.kdePackages.qttools
    pkgs.kdePackages.qttranslations
    pkgs.kdePackages.qtvirtualkeyboard
    pkgs.kdePackages.qtwayland
    pkgs.kdePackages.syntax-highlighting
    pkgs.material-symbols
    pkgs.networkmanager
    pkgs.qt6.qtimageformats
    pkgs.qt6.qtsvg
  ]);
}

