{ config, pkgs, ... }: {
  home.packages = with pkgs; [
      pcem # emulator for ibm pc and clones
      yuzu-mainline # experimental Nintendo Switch emulator
      # retroarchFull # multiplatform emulator frontend
  ];
}
