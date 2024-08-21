{lib, ...}: {
  programs.bat.enable = true;
  programs.bat.config = {
    theme = lib.mkForce "ansi";
    italic-text = "always";
    paging = "never";
    decorations = "never";
  };
}
