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
  home.packages = with pkgs; [
    blesh # bluetooth shell
    ccrypt # Secure encryption and decryption of files and streams
    dconf # gnome registry
    gnome.gpaste # clipboard manager
    gnupg # encryption
    imagemagick # for convert
    # imwheel # for mouse wheel scrolling
    libsForQt5.qt5ct libsForQt5.qtstyleplugin-kvantum qt6Packages.qtstyleplugin-kvantum # kvantum theme support
    neomutt # email client
    pwgen # generate passwords
    (python3-lto.withPackages (ps: with ps; [ docopt i3ipc psutil colored pynvim requests ]))
    # swayfx # i3 for wayland
    sway-unwrapped_git # i3 for wayland
  ];
}
