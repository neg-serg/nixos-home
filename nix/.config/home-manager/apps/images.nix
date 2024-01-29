{ config, pkgs, ... }: {
  home.packages = with pkgs; [
      darktable # photo editing
      gcolor3 # color selector
      gpick # alternative color picker
      krita # digital painting
  ];
}
