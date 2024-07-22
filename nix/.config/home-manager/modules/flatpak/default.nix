{pkgs, ...}: {
  home.packages = with pkgs; [
    flatpak # sandboxing and distribution framework
  ];
  home.sessionVariables = {
    XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"; # lets flatpak work
  };
}
