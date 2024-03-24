{ pkgs, ... }: {
    home.packages = with pkgs; [
       blesh # bluetooth shell
       gnome.gpaste # clipboard manager
       gnupg # encryption
       imwheel # for mouse wheel scrolling
       neomutt # email client
       pwgen # generate passwords
  ];
}
