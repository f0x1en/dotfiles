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
    -- jump into the tree if open, open it if not
    { "<leader>o", function()
      local p = Snacks.picker.get({ source = "explorer" })[1]
      if p then p:focus() else Snacks.explorer() end
    end, desc = "Focus file tree" },
    { "<leader>b", function() Snacks.picker.buffers() end, desc = "Open files" },
  },
}
