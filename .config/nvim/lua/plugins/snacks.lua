return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = {},
    -- Obsidian-style sidebar file tree
    explorer = { replace_netrw = true },
  },
  keys = {
    -- open (focused) or close, from anywhere
    { "<leader>e", function() Snacks.explorer() end, desc = "File tree" },
    { "<C-h>", "<C-w>h", desc = "Go to left window (tree)" },
    { "<C-l>", "<C-w>l", desc = "Go to right window (document)" },
    { "<leader>b", function() Snacks.picker.buffers() end, desc = "Open files" },
    { "H", "<cmd>bprevious<CR>", desc = "Previous tab" },
    { "L", "<cmd>bnext<CR>", desc = "Next tab" },
    { "<leader>x", function() Snacks.bufdelete() end, desc = "Close tab" },
  },
}
