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
    { "<leader>e", function() Snacks.explorer() end, desc = "File tree" },
  },
}
