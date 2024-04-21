{pkgs, ...}: {
  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = super: {
      python3-lto = super.python3.override {
        packageOverrides = python-self: python-super: {
          enableOptimizations = true;
          enableLTO = true;
          reproducibleBuild = false;
        };
      };
    };
  };
  home.packages = with pkgs; [
    (python3-lto.withPackages (ps:
      with ps; [
        colored
        docopt
        i3ipc
        psutil
        pynvim
        requests
      ]))
  ];
}
