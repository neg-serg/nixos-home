{pkgs, stable, ...}: {
  imports = [
    ./firefox.nix
    # ./floorp.nix
  ];
  home.packages = with pkgs; [
    passff-host # host app for the WebExtension PassFF
    stable.tor-browser # browse web via tor
  ];
}
