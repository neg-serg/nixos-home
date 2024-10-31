{stable, ...}: {
  home.packages = with stable; [
    yubikey-agent # ssh agent for yk
    yubikey-manager # yubikey manager cli
    yubikey-personalization # ykinfo
  ];
}
