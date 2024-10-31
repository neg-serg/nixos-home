{pkgs, ...}: {
  home.packages = with pkgs; [
    vesktop # alternative discord client
    telegram-desktop # famous cloud-based im
  ];
}
