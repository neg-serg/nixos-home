{ pkgs, ... }: {
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
  wayland.windowManager.sway = {
      extraOptions = [ "--unsupported-gpu" ];
  };
  home.packages = with pkgs; [
    blesh # bluetooth shell
    ccrypt # Secure encryption and decryption of files and streams
    dconf # gnome registry
    gnome.gpaste # clipboard manager
    gnupg # encryption
    imagemagick # for convert
    # imwheel # for mouse wheel scrolling
    libfido2 # ssh sk keys support (maybe not needed)
    libsForQt5.qt5ct libsForQt5.qtstyleplugin-kvantum qt6Packages.qtstyleplugin-kvantum # kvantum theme support
    pinentry # for gpg/gnupg password entry GUI. why does it not install this itself? ah, found out... https://github.com/NixOS/nixpkgs/commit/3d832dee59ed0338db4afb83b4c481a062163771
    pwgen # generate passwords
    (python3-lto.withPackages (ps: with ps; [ docopt i3ipc psutil colored ]))
    eww
    # swayfx
    sway
    glxinfo
    vulkan-tools
    glmark2
  ];
}
