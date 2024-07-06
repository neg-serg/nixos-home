{pkgs, ...}: {
  home.packages = with pkgs; [
    blesh # bluetooth shell
    imwheel # for mouse wheel scrolling
    neomutt # email client
    pwgen # generate passwords
  ];
}
