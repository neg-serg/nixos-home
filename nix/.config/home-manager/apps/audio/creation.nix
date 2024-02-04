{ pkgs, ... }: {
  home.packages = with pkgs; [
      bitwig-studio # great DAW
      reaper # А вот в рипере!
      renoise # modern tracker
      rnnoise # neural network noise reduction
      tenacity # audio editor
      yabridge # vst for linux
      yabridgectl # vst control for linux
  ];
}
