{ config, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
      # interbench # interactive benchmark
      memtester # memory test
      phoronix-test-suite # massive benchmark toolset
      stress stress-ng # stress testing
      vrrtest # freesync/gsync working test
  ];
}
