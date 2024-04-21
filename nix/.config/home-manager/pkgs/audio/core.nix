{
  pkgs,
  stable,
  ...
}: {
  home.packages = with pkgs; [
    alsa-utils # aplay -l and friends
    helvum # pipewire router
    open-music-kontrollers.patchmatrix # alternative patcher
    pw-volume # pipewire volume
    stable.pwvucontrol # pavucontrol for pipewire
  ];
}
