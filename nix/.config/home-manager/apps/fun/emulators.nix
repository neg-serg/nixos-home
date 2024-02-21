{ pkgs, ... }: {
  home.packages = with pkgs; [
      pcem # emulator for ibm pc and clones
      retroarchFull # multiplatform emulator frontend
      yuzu-mainline # experimental Nintendo Switch emulator
  ];
}
