-- tree } / {: jump to the next / previous item at the same level,
-- skipping the contents of open subfolders
local function sibling(step)
  return function(picker)
    local cur = picker:current()
    if not cur then return end
    local i = picker.list.cursor + step
    while i >= 1 and i <= picker.list:count() do
      local item = picker.list:get(i)
      if item.parent == cur.parent then
        return picker.list:move(i, true)
      end
      i = i + step
    end
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    image = {},
    -- Obsidian-style sidebar file tree
    explorer = { replace_netrw = true },
    picker = {
      sources = {
        explorer = {
          actions = {
            sibling_next = sibling(1),
            sibling_prev = sibling(-1),
            -- l opens folders only; Enter still opens files
            open_dir = function(picker, item)
              if item and item.dir then picker:action("confirm") end
            end,
          },
          -- no side-by-side panes: tree Ctrl+v / Ctrl+s do nothing
          win = {
            -- false would fall back to vim's own Ctrl+v (visual block), so map to a no-op
            list = { keys = {
              ["<c-v>"] = function() end,
              ["<c-s>"] = function() end,
              ["}"] = "sibling_next",
              ["{"] = "sibling_prev",
              ["l"] = "open_dir",
            } },
            input = { keys = {
              ["<c-v>"] = { function() end, mode = { "i", "n" } },
              ["<c-s>"] = { function() end, mode = { "i", "n" } },
            } },
          },
        },
      },
    },
  },
  init = function()
    -- :q / ZZ / ZQ in the document: close the tree too, so nvim exits
    vim.api.nvim_create_autocmd("QuitPre", {
      callback = function()
        if not vim.bo.filetype:match("^snacks_") then
          -- picker:close() is async, so close the tree windows directly
          vim.cmd("silent! only")
        end
      end,
    })
  end,
  keys = {
    -- closed: open it; open but not focused: focus it; focused: close it
    { "<leader>e", function()
      local tree = Snacks.picker.get({ source = "explorer" })[1]
      if tree and not tree:is_focused() then
        tree:focus()
      else
        Snacks.explorer()
      end
    end, desc = "File tree" },
    { "<C-h>", "<C-w>h", desc = "Go to left window (tree)" },
    { "<C-l>", "<C-w>l", desc = "Go to right window (document)" },
    { "<leader>b", function() Snacks.picker.buffers() end, desc = "Open files" },
    { "H", "<cmd>bprevious<CR>", desc = "Previous tab" },
    { "L", "<cmd>bnext<CR>", desc = "Next tab" },
    { "<leader>x", function() Snacks.bufdelete() end, desc = "Close tab" },
  },
}
