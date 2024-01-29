{ config, pkgs, ... }: {
  home.packages = with pkgs; [
      binwalk # search binary image for embedded files
      capstone # disassembly framework
  ];
}
