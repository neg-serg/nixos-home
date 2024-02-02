{ config, pkgs, lib, ... }: {
  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = super: {
      python3-lto = super.python3.override {
        packageOverrides = python-self: python-super: {
          enableOptimizations = true;
          enableLTO = true;
          reproducibleBuild = false;
        };
      };
    };
  };
  home.packages = with pkgs; [
    # imwheel # for mouse wheel scrolling
    blesh # bluetooth shell
    ccrypt # Secure encryption and decryption of files and streams
    dconf # gnome registry
    gnome.gpaste # clipboard manager
    gnupg # encryption
    has # for verifying the availability and version of executables
    imagemagick # for convert
    libfido2 # ssh sk keys support (maybe not needed)
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum # kvantum theme support
    o # experiment
    pass-secret-service # gnome-keyring alternative via paste
    pinentry # for gpg/gnupg password entry GUI. why does it not install this itself? ah, found out... https://github.com/NixOS/nixpkgs/commit/3d832dee59ed0338db4afb83b4c481a062163771
    pwgen # generate passwords
    sysz # An fzf-based terminal UI for systemctl
    ydotool # xdotool systemwide
    zk # notes database

    (python3-lto.withPackages (ps: with ps; [ docopt i3ipc psutil colored ]))
  ];
}
