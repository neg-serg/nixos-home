{ pkgs, ... }: {
  imports = [ ./unfree.nix ];
  home.packages = with pkgs; [
    blesh # bluetooth shell
    pwgen # generate passwords
  ];
}
