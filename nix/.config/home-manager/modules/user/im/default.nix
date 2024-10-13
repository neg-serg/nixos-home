{pkgs, stable, ...}: {
  home.packages = with pkgs; [
    vesktop # alternative discord client
    stable.telegram-desktop # famous cloud-based im
  ];
}
