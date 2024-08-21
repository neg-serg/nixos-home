{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
    "python3.12-youtube-dl-2021.12.17"
  ];
  home.packages = with pkgs; [
    obsidian # notes
    zk # notes database
  ];
}
