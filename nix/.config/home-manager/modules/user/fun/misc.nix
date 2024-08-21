{pkgs, ...}:
with {
  cxxmatrix = pkgs.callPackage ../../../packages/cxxmatrix {};
}; {
  home.packages = with pkgs; [
    almonds # TUI fractal viewer
    bucklespring # for keyboard sounds
    clolcat # rainbow color version of cat
    cool-retro-term # a retro terminal emulator
    cxxmatrix # nice matrix in terminal
    dotacat # yet another color version of cat
    figlet # ascii art
    fortune # fortune cookie
    free42 # A software clone of HP-42S Calculator
    neo-cowsay # say something
    neo # yet another digital rain
    nms # No More Secrets, a recreation of the live decryption effect from the famous hacker movie "Sneakers"
    solfege # ear training program
    taoup # The Tao of Unix Programming
    tmatrix # matrix-like screensaver for terminal
    toilet # text banners
    toipe # typing tester
    typioca # cozy typing tester
    xlife # cellular automata
  ];
}
