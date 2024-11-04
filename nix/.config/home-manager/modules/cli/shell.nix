{
  pkgs,
  ...
}: {
  programs.carapace.enable = true; # cross-shell completion
  home.packages = with pkgs; [
    dash # faster sh
    nushell # alternative shell
    oils-for-unix # better bash
  ];
}
