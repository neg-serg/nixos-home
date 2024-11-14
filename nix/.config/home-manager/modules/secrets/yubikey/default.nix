{pkgs, ...}: {
  home.packages = with pkgs; [
    yubikey-agent # ssh agent for yk
    yubikey-manager # yubikey manager cli
    yubikey-personalization # ykinfo
  ];
}
