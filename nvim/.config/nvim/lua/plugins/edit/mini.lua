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
    -- Other mini.* modules are added in follow-up commits.
  end,
}
