{
  pkgs,
  config,
  ...
}: {
  # Prefer Home Manager module for asciinema (installs pkg and manages XDG config)
  programs.asciinema.enable = true;

  home.packages = config.lib.neg.pkgsList [
    pkgs.asciinema-agg # asciinema files to gif
    pkgs.chafa # terminal graphics
    pkgs.kitty # fastest terminal emulator so far
    pkgs.kitty-img # print images inline in kitty
  ];
}
