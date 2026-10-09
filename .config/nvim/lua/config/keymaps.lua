vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape" })

-- Better line movement
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- Never overwrite yank/clipboard when deleting or changing
local delete_blackhole = {
  -- Normal mode
  { "n", "d",  '"_d' },
  { "n", "dd", '"_dd' },
  { "n", "D",  '"_D' },
  { "n", "x",  '"_x' },
  { "n", "X",  '"_X' },

  -- Change commands
  { "n", "c",  '"_c' },
  { "n", "cc", '"_cc' },
  { "n", "C",  '"_C' },
  { "n", "s",  '"_s' },
  { "n", "S",  '"_S' },

  -- Visual mode
  { "x", "d", '"_d' },
  { "x", "D", '"_D' },
  { "x", "x", '"_x' },
  { "x", "X", '"_X' },
  { "x", "c", '"_c' },
  { "x", "s", '"_s' },
}

for _, map in ipairs(delete_blackhole) do
  vim.keymap.set(map[1], map[2], map[3], {
    desc = "Delete without overwriting yank",
  })
end

-- System clipboard: explicit linewise paste
local function paste_linewise(reg, after)
  local text = vim.fn.getreg(reg)
  local lines = vim.split(text, "\n", { plain = true })

  -- Remove trailing empty element from clipboard text
  if lines[#lines] == "" then
    table.remove(lines)
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- Paste without following the inserted text
  vim.api.nvim_put(lines, "l", after, false)

  -- The pasted block starts:
  --   after  -> next line
  --   before -> current line
  local target_row = after and row + 1 or row

  local target_line = vim.api.nvim_buf_get_lines(
    0,
    target_row - 1,
    target_row,
    false
  )[1] or ""

  col = math.min(col, #target_line)

  vim.api.nvim_win_set_cursor(0, { target_row, col })
end

-- Paste clipboard below
vim.keymap.set("n", "<leader>p", function()
  paste_linewise("+", true)
end, { desc = "Paste clipboard below" })

-- Paste clipboard above
vim.keymap.set("n", "<leader>P", function()
  paste_linewise("+", false)
end, { desc = "Paste clipboard above" })

-- Toggle relative line numbers
vim.keymap.set("n", "<leader>r", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative numbers" })
