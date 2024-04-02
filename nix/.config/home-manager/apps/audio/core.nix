{ pkgs, stable, ... }: {
  home.packages = with pkgs; [
      alsa-utils # aplay -l and friends
      helvum # pipewire router
      pw-volume # pipewire volume
      stable.pwvucontrol # pavucontrol for pipewire
  ];
}
