{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    autocutsel # tool to sync x11 buffers
    clipboard-jh # platform independent clipboard manager, test it more later
    clipcat # replacement for gpaste
    espanso # systemwide expander for keyboard
  ];
}
