{ config, pkgs, ... }: {
  home.packages = with pkgs; [
      betterdiscord-installer betterdiscordctl # better discord
      discord # audio / video calls for gaming
      telegram-desktop_git
      zoom-us # weird shit
  ];
}

