{pkgs, master, ...}: {
  home.packages = with pkgs; [
    master.element-desktop # matrix client to test #3
    skypeforlinux # skype for linux client
    telegram-desktop # famous cloud-based im
    vesktop # alternative discord client
  ];
}
