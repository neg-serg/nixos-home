-- │ █▓▒░ Hashino/speed.nvim                                                      │
-- Keyboard speedometer for Neovim. No intrusive UI by default; expose module
-- so it can be used by Heirline/Lualine if desired.
return {
  "Hashino/speed.nvim",
  main = "speed",
  lazy = true,
  cmd = { "Speed" },
  opts = {
    -- Integrate with Heirline: disable floating buffer and use statusline component.
    float_buffer = false,
  },
}
