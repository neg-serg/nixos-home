{lib, ...}: {
  # Reduce activation noise: keep bat disabled by default (can be overridden)
  programs.bat.enable = lib.mkDefault false;
  programs.bat.config = {
    theme = lib.mkForce "ansi";
    italic-text = "always";
    paging = "never";
    decorations = "never";
  };
}
