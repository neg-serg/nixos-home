{pkgs, ...}: {
  home.packages = with pkgs; [
    betterdiscord-installer
    betterdiscordctl # better discord
    discord # audio / video calls for gaming
    telegram-desktop # famous cloud-based im
    zoom-us # weird shit
  ];
}
