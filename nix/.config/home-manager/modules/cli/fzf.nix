{
  lib,
  pkgs,
  ...
}: {
  programs.fzf = {
    enable = true;
    defaultCommand = "${lib.getBin pkgs.fd}/bin/fd --type=f --hidden --exclude=.git";
    defaultOptions = builtins.filter (x: builtins.typeOf x == "string") [
      # Key bindings & quick actions
      "--bind='alt-p:toggle-preview,alt-a:select-all,alt-s:toggle-sort'"
      "--bind='alt-d:change-prompt(Directories> )+reload(fd . -t d)'"
      "--bind='alt-f:change-prompt(Files> )+reload(fd . -t f)'"
      "--bind='ctrl-j:execute(~/bin/v {+})+abort'"
      "--bind='ctrl-space:select-all'"
      "--bind='ctrl-t:accept'"
      "--bind='ctrl-v:execute(~/bin/v {+})'"
      "--bind='ctrl-y:execute-silent(echo {+} | xclip -i)'"
      "--bind='tab:execute(handlr open {+})+abort'"

      # UI/UX polish
      "--ansi"
      "--layout=reverse"
      "--cycle"
      "--border=rounded"
      "--margin=1,2"
      "--padding=1"
      "--header-first"
      "--header='[Alt-f] Files  [Alt-d] Dirs  [Alt-p] Preview  [Alt-s] Sort  [Tab] Open'"

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

      # Note: Preview config moved to widget-specific opts (history/file)
      # to avoid heavy quoting in FZF_DEFAULT_OPTS.
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

    # Restore previous custom theme colors
    colors = {
      "preview-bg" = "-1";
      "gutter" = "-1";
      "bg" = lib.mkForce "#000000";
      "bg+" = lib.mkForce "#000000";
      "fg" = lib.mkForce "#4f5d78";
      "fg+" = lib.mkForce "#8DA6B2";
      "hl" = lib.mkForce "#546c8a";
      "hl+" = lib.mkForce "#005faf";
      "header" = lib.mkForce "#4779B3";
      "info" = lib.mkForce "#3f5876";
      "pointer" = lib.mkForce "#005faf";
      "marker" = lib.mkForce "#04141C";
      "prompt" = lib.mkForce "#005faf";
      "spinner" = lib.mkForce "#3f5876";
      "preview-fg" = lib.mkForce "#4f5d78";
    };

    enableZshIntegration = true;
    enableBashIntegration = true;
  };
}
