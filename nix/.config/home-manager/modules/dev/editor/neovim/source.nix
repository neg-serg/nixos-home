{
  lib,
  config,
  ...
}: let
  xdg = import ../../../lib/xdg-helpers.nix {inherit lib;};
in
  # Live-editable config and tiny init for kitty-scrollback.nvim kitten
  lib.mkMerge [
    (xdg.mkXdgSource "nvim" {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nvim/.config/nvim";
      recursive = true;
    })
    (xdg.mkXdgText "nvim/kitty-scrollback-nvim-kitten.lua" ''
      -- Minimal init for kitty-scrollback.nvim kitten: fast and isolated
      vim.g.loaded_node_provider = 0
      vim.g.loaded_python3_provider = 0
      vim.g.loaded_ruby_provider = 0
      vim.g.loaded_perl_provider = 0
      vim.opt.swapfile = false
      vim.opt.shadafile = "NONE"

      -- Optional: open file under terminal cursor when requested
      -- Triggered only when called with `--env KSB_OPEN_GF=1`
      if vim.env.KSB_OPEN_GF == '1' then
        vim.api.nvim_create_autocmd({ 'FileType' }, {
          group = vim.api.nvim_create_augroup('KittyScrollbackOpenFileUnderCursor', { clear = true }),
          pattern = { 'kitty-scrollback' },
          once = true,
          callback = function()
            -- Open file under cursor (gf) once the scrollback buffer is ready
            vim.schedule(function()
              pcall(vim.cmd.normal, { 'gf', bang = true })
            end)
            return true
          end,
        })
      end
    '')
  ]
