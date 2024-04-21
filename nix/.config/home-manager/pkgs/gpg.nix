{pkgs, ...}: with {
  pinentryRofi = pkgs.writeShellApplication {
    name = "pinentry-rofi-with-env";
    text = ''
      PATH="$PATH:${pkgs.coreutils}/bin:${pkgs.rofi}/bin"
      "${pkgs.pinentry-rofi}/bin/pinentry-rofi" "$@"
    '';
  };
}; {
  programs.gpg = {
    enable = true;
    scdaemonSettings = {
      disable-ccid = true;
      pcsc-shared = true;
    };
  };
  services.gpg-agent = {
    defaultCacheTtl = 60480000;
    enableExtraSocket = true;
    enableScDaemon = true;
    enableSshSupport = false;
    enable = true;
    extraConfig = ''pinentry-program ${pinentryRofi}/bin/pinentry-rofi-with-env '';
    verbose = true;
  };
}
