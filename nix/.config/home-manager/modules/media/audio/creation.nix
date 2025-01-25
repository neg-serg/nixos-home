{pkgs, ...}: {
  home.packages = with pkgs; [
    noisetorch # virtual microphone to suppress the noise
    reaper # А вот в рипере!
    rnnoise # neural network noise reduction
    tenacity # audio editor
  ];
}
