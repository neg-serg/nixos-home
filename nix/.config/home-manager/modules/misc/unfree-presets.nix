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
    "yandex-browser-stable" # Chromium-based Yandex browser
    "lmstudio" # desktop app for local/open LLMs
    "code-cursor-fhs" # Cursor packaged via FHS env
  ];

  # Headless/server preset: no unfree packages allowed
  headless = [ ];
}
