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
    -- closed: open it; open: jump into it; already in it: close it
    { "<leader>e", function()
      local p = Snacks.picker.get({ source = "explorer" })[1]
      if not p then
        Snacks.explorer()
      elseif p:is_focused() then
        p:close()
      else
        p:focus()
      end
    end, desc = "File tree" },
    { "<leader>b", function() Snacks.picker.buffers() end, desc = "Open files" },
    { "H", "<cmd>bprevious<CR>", desc = "Previous tab" },
    { "L", "<cmd>bnext<CR>", desc = "Next tab" },
    { "<leader>x", function() Snacks.bufdelete() end, desc = "Close tab" },
  },
}
