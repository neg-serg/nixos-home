{...}: {
  imports = [
    ./apps.nix
    ./audio
    ./images
    ./mpv
    ./pipewire.nix
    ./playerctld.nix
  ];
  # moved to playerctld.nix and pipewire.nix
}
