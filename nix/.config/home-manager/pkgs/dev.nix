{ pkgs, ... }: {
  home.packages = with pkgs; [
      # chez # Chez Scheme (useful for idris)
      # cosmocc # Cosmopolitan (Actually Portable Executable) C/C++ toolchain; use via CC=cosmocc, CXX=cosmoc++
      # idris2 # Idris2 functional statically-typed programming language that looks cool and compiles to C
      # micromamba # for python env
      cloc # count lines of code
      deheader # remove unneeded includes for c, cpp
      flawfinder # examine c, cpp code for security flaws
      mypy # optional static-typing for python
      nixfmt # nix formatter
      shfmt # shell formatting
      stylua # lua styler
      tokei # count your code, quickly
  ];
}
