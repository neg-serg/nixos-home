-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ Help/LSP mappings (replace thinca/vim-ref)                                   │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {
  -- No plugin dependency; just keymaps using Telescope and LSP
  config = function()
    local ok_tb, tb = pcall(require, 'telescope.builtin')

    -- Search Neovim help tags
    if ok_tb then
      Map('n', '<leader>sh', function() tb.help_tags({}) end, { desc = '[S]earch [H]elp (Telescope)' })
      -- Grep current word in project (quick replacement for ref search)
      Map('n', '<leader>sg', function() tb.grep_string({ search = vim.fn.expand('<cword>') }) end,
        { desc = '[S]earch [G]rep word (Telescope)' })
    end

    -- LSP hover with fallback to :help keyword
    Map('n', 'K', function()
      local clients = {}
      if vim.lsp and vim.lsp.get_clients then
        clients = vim.lsp.get_clients({ bufnr = 0 })
      end
      if clients and #clients > 0 then
        return vim.lsp.buf.hover()
      end
      vim.cmd('help ' .. vim.fn.expand('<cword>'))
    end, { desc = 'Hover/Help' })

    -- LSP definition with Telescope fallback
    Map('n', 'gd', function()
      local clients = {}
      if vim.lsp and vim.lsp.get_clients then
        clients = vim.lsp.get_clients({ bufnr = 0 })
      end
      if clients and #clients > 0 then
        return vim.lsp.buf.definition()
      end
      if ok_tb and tb.lsp_definitions then
        return tb.lsp_definitions({})
      end
    end, { desc = 'Go to definition' })
  end,
}

