-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │ █▓▒░ natecraddock/telescope-zf-native.nvim                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
return {'natecraddock/telescope-zf-native.nvim', -- telescope-sorter via zf integration
    config=function() require("telescope").load_extension("zf-native") end}
    opts={},
}
