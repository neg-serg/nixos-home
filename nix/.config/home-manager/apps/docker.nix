{ pkgs, ... }: {
  home.packages = with pkgs; [
      docker
      cntr
  ];
}
