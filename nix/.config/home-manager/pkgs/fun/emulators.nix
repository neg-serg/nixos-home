{ pkgs, stable, ... }: {
  home.packages = with pkgs; [
      pcem # emulator for ibm pc and clones
      stable.retroarchFull # multiplatform emulator frontend
  ];
}
