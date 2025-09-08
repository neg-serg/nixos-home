{
  # Desktop-oriented unfree packages
  desktop = [
    "abuse" # classic side-scrolling shooter customizable with LISP
    "ocenaudio" # good audio editor
    "reaper" # digital audio workstation (DAW)
    "vcv-rack" # powerful soft modular synth
    "vital" # serum-like digital synth
    "roomeqwizard" # room acoustics software
    "stegsolve" # image steganography analyzer/solver
    "volatility3" # memory forensics framework
    "cursor" # AI-powered code editor (VS Code-based)
    "claude-code" # Claude Code desktop client
    "libretro-fbalpha2012" # libretro arcade core (FBA 2012)
    "libretro-fbneo" # libretro arcade core (FBNeo)
    "libretro-fmsx" # libretro core (MSX)
    "libretro-genesis-plus-gx" # libretro core (Sega Genesis/Master System)
    "libretro-mame2000" # libretro core (MAME 2000)
    "libretro-mame2003" # libretro core (MAME 2003)
    "libretro-mame2003-plus" # libretro core (MAME 2003 Plus)
    "libretro-mame2010" # libretro core (MAME 2010)
    "libretro-mame2015" # libretro core (MAME 2015)
    "libretro-opera" # libretro core (3DO / Opera)
    "libretro-picodrive" # libretro core (Sega PicoDrive)
    "libretro-snes9x" # libretro core (SNES)
    "libretro-snes9x2002" # libretro core (SNES 2002)
    "libretro-snes9x2005" # libretro core (SNES 2005)
    "libretro-snes9x2005-plus" # libretro core (SNES 2005 Plus)
    "libretro-snes9x2010" # libretro core (SNES 2010)
    "yandex-browser-stable" # Chromium-based Yandex browser
    "lmstudio" # desktop app for local/open LLMs
    "code-cursor-fhs" # Cursor packaged via FHS env
  ];

  # Headless/server preset: no unfree packages allowed
  headless = [ ];
}
