-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ echasnovski/mini.nvim                                                       │
-- └───────────────────────────────────────────────────────────────────────────────────┘
-- Configure selected mini.nvim modules. Start with mini.align to replace
-- vim-easy-align and reuse the familiar `ga` mappings.
return {
  'echasnovski/mini.nvim',
  config = function()
    local ok_align, align = pcall(require, 'mini.align')
    if ok_align then
      align.setup()
      -- Use function mappings to mimic EasyAlign UX
      Map('x', 'ga', function() align.operator(align.gen_spec.input()) end, { desc = 'Align (visual)' })
      Map('n', 'ga', function() align.operator(align.gen_spec.input()) end, { desc = 'Align (operator)' })
    end
    -- Trailing whitespace helper (replaces trim.nvim). No auto-trim on write.
    local ok_ts, trail = pcall(require, 'mini.trailspace')
    if ok_ts then
      trail.setup()
      -- Optional manual trim command example (kept commented to match previous behavior):
      -- Map('n', '<leader>tw', function() trail.trim() end, { desc = 'Trim trailing whitespace' })
    end

    -- Split/Join (replaces treesj): simple toggle on <leader>a
    local ok_sj, sj = pcall(require, 'mini.splitjoin')
    if ok_sj then
      sj.setup()
      Map('n', '<leader>a', function() sj.toggle() end, { desc = 'Split/Join toggle' })
    end
  end,
}
