{pkgs, ...}: {
  home.packages = with pkgs; [
    activitywatch # track your activity on pc
    blesh # bluetooth shell
    gnome.gpaste # clipboard manager
    gnupg # encryption
    imwheel # for mouse wheel scrolling
    neomutt # email client
    pwgen # generate passwords
  ];
}
