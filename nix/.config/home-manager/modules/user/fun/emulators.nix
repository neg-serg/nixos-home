{
  pkgs,
  stable,
  ...
}: {
  home.packages = with pkgs; [
    stable.pcem # emulator for ibm pc and clones
    retroarchFull # multiplatform emulator frontend
  ];
}
