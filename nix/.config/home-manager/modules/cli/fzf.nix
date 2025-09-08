{
  lib,
  pkgs,
  ...
}: {
  programs.fzf = {
    enable = true;
    defaultCommand = "${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
    defaultOptions = [
      # Key bindings & quick actions
      "--bind=alt-p:toggle-preview,alt-a:select-all,alt-s:toggle-sort"
      "--bind=alt-d:change-prompt(Directories> )+reload(fd . -t d)"
      "--bind=alt-f:change-prompt(Files> )+reload(fd . -t f)"
      "--bind=ctrl-j:execute(~/bin/v {+})+abort"
      "--bind=ctrl-space:select-all"
      "--bind=ctrl-t:accept"
      "--bind=ctrl-v:execute(~/bin/v {+})"
      "--bind=ctrl-y:execute-silent(echo {+} | xclip -i)"
      "--bind=tab:execute(handlr open {+})+abort"

      # UI/UX polish
      "--ansi"
      "--layout=reverse"
      "--cycle"
      "--border=rounded"
      "--margin=1,2"
      "--padding=1"
      "--header-first"
      "--header=[Alt-f] Files  [Alt-d] Dirs  [Alt-p] Preview  [Alt-s] Sort  [Tab] Open"

      # Search behavior: exact by default; quote for subsequence
      "--exact"

      # Sizing: compact by default but more breathable
      "--height=12"
      "--min-height=10"
      "--info=inline"
      "--multi"
      "--no-mouse"

      # Prompt & symbols (Nerd Font friendly)
      "--prompt=  "
      "--pointer=▶"
      "--marker=✓"
      "--with-nth=1.."

      # Preview (hidden by default; toggle with Alt-p). Rich preview for files/dirs.
      "--preview-window=border-left,wrap,hidden,60%"
      "--preview 'if [ -d "{}" ]; then (eza --tree --icons=auto -L 2 --color=always "{}" 2>/dev/null || tree -C -L 2 "{}" 2>/dev/null); else (bat --style=plain --color=always --line-range :200 "{}" 2>/dev/null || highlight -O ansi -l "{}" 2>/dev/null || head -200 "{}" 2>/dev/null || file -b "{}" 2>/dev/null); fi'"
    ];

    # FZF_CTRL_R_OPTS
    historyWidgetOptions = [
      "--sort"
      "--exact"
      "--border=rounded --margin=1,2 --padding=1"
      "--header-first --header='[Enter] Paste  [Ctrl-y] Yank  [?] Preview'"
      "--preview 'echo {}'"
      "--preview-window down:5:hidden,wrap --bind '?:toggle-preview'"
    ];

    # FZF_CTRL_T_OPTS
    fileWidgetOptions = [
      "--border=rounded --margin=1,2 --padding=1 --preview 'if [ -d \"{}\" ]; then (eza --tree --icons=auto -L 2 --color=always \"{}\" 2>/dev/null || tree -C -L 2 \"{}\" 2>/dev/null); else (bat --style=plain --color=always --line-range :200 \"{}\" 2>/dev/null || highlight -O ansi -l \"{}\" 2>/dev/null || head -200 \"{}\" 2>/dev/null || file -b \"{}\" 2>/dev/null); fi' --preview-window=right,60%,border-left,wrap"
    ];

    # Catppuccin-like dark theme (works well with Nerd Fonts)
    colors = {
      "preview-bg" = "-1";
      "gutter" = "-1";
      "bg" = lib.mkForce "#11111b";   # crust
      "bg+" = lib.mkForce "#181825";  # mantle
      "fg" = lib.mkForce "#cdd6f4";   # text
      "fg+" = lib.mkForce "#cdd6f4";
      "hl" = lib.mkForce "#89b4fa";   # blue
      "hl+" = lib.mkForce "#b4befe";  # lavender
      "header" = lib.mkForce "#94e2d5"; # teal
      "info" = lib.mkForce "#a6adc8"; # subtext0
      "pointer" = lib.mkForce "#f38ba8"; # red
      "marker" = lib.mkForce "#a6e3a1";  # green
      "prompt" = lib.mkForce "#cba6f7";  # mauve
      "spinner" = lib.mkForce "#f9e2af"; # yellow
      "border" = lib.mkForce "#181825";
      "preview-fg" = lib.mkForce "#cdd6f4";
    };

    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
