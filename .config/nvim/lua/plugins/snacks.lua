return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = {},
    -- Obsidian-style sidebar file tree
    explorer = { replace_netrw = true },
  },
  init = function()
    -- :q / ZZ / ZQ on the last document window: close the tree too, so nvim exits
    vim.api.nvim_create_autocmd("QuitPre", {
      callback = function()
        local cur = vim.api.nvim_get_current_win()
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local ft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
          if w ~= cur and vim.api.nvim_win_get_config(w).relative == "" and not ft:match("^snacks_") then
            return
          end
        end
        -- picker:close() is async, so close the tree windows directly
        vim.cmd("silent! only")
      end,
    })
  end,
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
