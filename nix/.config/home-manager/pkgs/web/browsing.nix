{pkgs, stable, ...}: {
  imports = [
      ./floorp.nix
  ];
  home.packages = with pkgs; [
    passff-host # host app for the WebExtension PassFF
    stable.tor-browser # browse web via tor
    stable.tor # anti-censorship network
    torsocks # tor stuff
    tridactyl-native # native package for nix
  ];
}
