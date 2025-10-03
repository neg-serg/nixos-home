-- │ █▓▒░ Hashino/speed.nvim                                                      │
-- Keyboard speedometer for Neovim. No intrusive UI by default; expose module
-- so it can be used by Heirline/Lualine if desired.
return {
  "Hashino/speed.nvim",
  main = "speed",
  lazy = true,
  cmd = { "Speed" },
  opts = {
    -- Default config; keep float buffer on unless you plan to integrate with statusline
    -- float_buffer = false,
  },
}

