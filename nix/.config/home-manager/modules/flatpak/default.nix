{pkgs, ...}: {
  home.packages = with pkgs; [
    flatpak # sandboxing and distribution framework
  ];
}
