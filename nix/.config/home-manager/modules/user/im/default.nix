{pkgs, ...}: {
  home.packages = with pkgs; [
    telegram-desktop # famous cloud-based im
    vesktop # alternative discord client
  ];
  services.kdeconnect.enable = true;
}
