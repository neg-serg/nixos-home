{pkgs, ...}: {
  home.packages = with pkgs; [
    skypeforlinux # skype for linux client
    telegram-desktop # famous cloud-based im
    vesktop # alternative discord client
  ];
  services.kdeconnect.enable = true;
}
