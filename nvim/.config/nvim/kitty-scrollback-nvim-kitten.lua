-- Minimal config for kitty-scrollback.nvim Neovim overlay
-- Scope: used only when launched via kitty kitten with -u this file

-- Optional light tweaks
vim.g.mapleader = ' '
vim.opt.termguicolors = true
vim.opt.number = false
vim.opt.relativenumber = false

-- Defer plugin setup until kitty-scrollback adds itself to runtimepath
-- The kitten injects a VimEnter callback that appends the plugin path
-- and then triggers the User event "KittyScrollbackLaunch".
-- Ensure our colorscheme is available in this minimal runtime
pcall(function()
  local neg_path = vim.fn.stdpath('data') .. '/lazy/neg.nvim'
  if vim.uv or vim.loop then -- nvim 0.10+ or legacy
    local fs = (vim.uv or vim.loop)
    if fs.fs_stat(neg_path) then
      vim.opt.runtimepath:append(neg_path)
    end
  end
  pcall(vim.cmd.colorscheme, 'neg')
end)

-- Direct clipboard yank on Shift+Y without any UI
vim.keymap.set('v', 'Y', '"+y', { noremap = true, silent = true })
-- And on Enter as well
vim.keymap.set('v', '<CR>', '"+y', { noremap = true, silent = true })

vim.api.nvim_create_autocmd('User', {
  pattern = 'KittyScrollbackLaunch',
  once = true,
  callback = function()
    -- Configure kitty-scrollback before it launches
    local ok, ksb = pcall(require, 'kitty-scrollback')
    if ok then
      ksb.setup({
        -- Global defaults applied to all configs
        {
          status_window = { show_timer = true },
          kitty_get_text = {
            ansi = true,
            clear_selection = true,
          },
          paste_window = {
            -- avoid any paste-window yank interference
            yank_register_enabled = false,
            hide_footer = true,
          },
        },
        -- Override builtin to prefer only the screen (lighter, fewer issues)
        ksb_builtin_get_text_all = {
          kitty_get_text = { extent = 'screen' },
        },
      })
    end
  end,
})
