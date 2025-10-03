-- │ █▓▒░ y3owk1n/time-machine.nvim                                              │
-- Interactive undo history tree with diffs/bookmarks/cleanup.
-- Lazy-load on commands and leader keymaps.
return {
  "y3owk1n/time-machine.nvim",
  version = "*",
  cmd = {
    "TimeMachineToggle",
    "TimeMachinePurgeBuffer",
    "TimeMachinePurgeAll",
    "TimeMachineLogShow",
    "TimeMachineLogClear",
  },
  keys = {
    { "<leader>t",  "",                             desc = "Time Machine" },
    { "<leader>tt", "<cmd>TimeMachineToggle<cr>",    desc = "[Time] Toggle Tree" },
    { "<leader>tx", "<cmd>TimeMachinePurgeBuffer<cr>", desc = "[Time] Purge current" },
    { "<leader>tX", "<cmd>TimeMachinePurgeAll<cr>", desc = "[Time] Purge all" },
    { "<leader>tl", "<cmd>TimeMachineLogShow<cr>",  desc = "[Time] Show log" },
  },
  opts = {
    -- Keep defaults; we already use persistent undo in settings
    -- You can set diff_tool = 'difft' if you have it installed
  },
}

