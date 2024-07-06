{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    android-tools # android debug stuff
    jmtpfs # mount mtp devices
    scrcpy # rule android device via pc
  ];
}
