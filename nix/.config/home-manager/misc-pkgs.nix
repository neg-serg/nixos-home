{ pkgs, ... }: {
    home.packages = with pkgs; [
       blesh # bluetooth shell
       ccrypt # Secure encryption and decryption of files and streams
       dconf # gnome registry
       gnome.gpaste # clipboard manager
       gnupg # encryption
       imagemagick # for convert
       imwheel # for mouse wheel scrolling
       libsForQt5.qt5ct libsForQt5.qtstyleplugin-kvantum qt6Packages.qtstyleplugin-kvantum # kvantum theme support
       neomutt # email client
       pango # for pango-list
       pwgen # generate passwords
       # pritunl-client # alternative openvpn client
  ];
}
