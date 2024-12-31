{lib, ...}: {
  programs.helix = {
    enable = true;
    settings = {
      theme = lib.mkForce "poimandres";
      keys.normal = {
        "{" = "goto_prev_paragraph";
        "}" = "goto_next_paragraph";
        "X" = "extend_line_above";
        "esc" = ["collapse_selection" "keep_primary_selection"];
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":bc";
        "C-f" = "file_picker";
        space.u = {
          f = ":format"; # format using LSP formatter
          w = ":set whitespace.render all";
          W = ":set whitespace.render none";
        };
      };
      keys.select = {
        "%" = "match_brackets";
      };
      editor = {
        color-modes = true;
        cursorline = true;
        mouse = false;
        idle-timeout = 1;
        line-number = "relative";
        scrolloff = 5;
        completion-replace = true;
        bufferline = "always";
        true-color = true;
        soft-wrap.enable = true;
        indent-guides = { render = true; };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        gutters = ["diagnostics" "line-numbers" "spacer" "diff"];
        statusline = {
          separator = "";
          left = ["mode" "selections" "spinner" "file-name" "total-line-numbers"];
          center = [];
          right = ["diagnostics" "file-encoding" "file-line-ending" "file-type" "position-percentage" "position"];
          mode = { normal = "N"; insert = "I"; select = "S"; };
        };
        whitespace.characters = { space = "·"; nbsp = "⍽"; tab = "→"; newline = "⤶"; };
        cursor-shape = { insert = "bar"; normal = "block"; select = "block"; };
      };
    };
  };
}
