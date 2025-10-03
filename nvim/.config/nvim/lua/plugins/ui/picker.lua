-- │ █▓▒░ santhosh-tekuri/picker.nvim                                             │
-- Minimal picker (files/buffers/grep/LSP/qf) + vim.ui.select replacement.
-- Complements Telescope; very fast, zero deps. Wired under <leader>p prefix.
return {
  'Santhosh-tekuri/picker.nvim',
  cmd = { 'Pick' },
  keys = {
    { '<leader>p',  '',                               desc = 'Picker' },
    { '<leader>pf', function() require('picker').pick_file() end,    desc = '[Picker] Files' },
    { '<leader>pb', function() require('picker').pick_buffer() end,  desc = '[Picker] Buffers' },
    { '<leader>ph', function() require('picker').pick_help() end,    desc = '[Picker] Help' },
    { '<leader>pg', function() require('picker').pick_grep() end,    desc = '[Picker] Grep' },
    { '<leader>pq', function() require('picker').pick_qfitem() end,  desc = '[Picker] Quickfix items' },
    -- LSP helpers hooked on LspAttach to be buffer-local
  },
  config = function()
    local ok, m = pcall(require, 'picker'); if not ok then return end
    -- Use picker for vim.ui.select for consistency
    vim.ui.select = m.select
    -- Buffer-local LSP pickers
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('PickerLspAttach', {}),
      callback = function(ev)
        local function opts(desc) return { buffer = ev.buf, desc = desc } end
        vim.keymap.set('n', 'gd', m.pick_definition,        opts('[Picker] Goto definition'))
        vim.keymap.set('n', 'gD', m.pick_declaration,       opts('[Picker] Goto declaration'))
        vim.keymap.set('n', 'gy', m.pick_type_definition,   opts('[Picker] Goto type definition'))
        vim.keymap.set('n', 'gi', m.pick_implementation,    opts('[Picker] Goto implementation'))
        vim.keymap.set('n', '<leader>r', m.pick_reference,  opts('[Picker] References'))
        vim.keymap.set('n', '<leader>s', m.pick_document_symbol,  opts('[Picker] Document symbols'))
        vim.keymap.set('n', '<leader>S', m.pick_workspace_symbol, opts('[Picker] Workspace symbols'))
        vim.keymap.set('n', '<leader>d', m.pick_document_diagnostic,  opts('[Picker] Diagnostics (doc)'))
        vim.keymap.set('n', '<leader>D', m.pick_workspace_diagnostic, opts('[Picker] Diagnostics (ws)'))
      end,
    })
  end,
}

