{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];
  home.packages = with pkgs; [
      obsidian # notes
      zk # notes database
  ];
}
