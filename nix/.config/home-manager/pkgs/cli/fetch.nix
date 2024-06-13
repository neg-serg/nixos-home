{pkgs, ...}: {
  home.packages = with pkgs; [
    fastfetch # nice fetch
    onefetch # show you git stuff
  ];
}
