{pkgs, stable, ...}: {
  home.packages = with pkgs; [
    bitwig-studio # great DAW
    noisetorch # virtual microphone to suppress the noise
    reaper # А вот в рипере!
    # renoise # modern tracker
    rnnoise # neural network noise reduction
    tenacity # audio editor
    stable.zrythm # free audio workstation
  ];
}
