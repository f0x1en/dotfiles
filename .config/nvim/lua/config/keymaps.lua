vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape" })

-- System clipboard: explicit linewise paste
local function paste_linewise(reg, after)
  local text = vim.fn.getreg(reg)
  local lines = vim.split(text, "\n", { plain = true })

  -- Remove trailing empty element from clipboard text
  if lines[#lines] == "" then
    table.remove(lines)
  end

  vim.api.nvim_put(lines, "l", after, true)
end

-- Explicit linewise paste
vim.keymap.set("n", "<leader>p", function()
  paste_linewise("+", true)
end, { desc = "Paste clipboard below" })

vim.keymap.set("n", "<leader>P", function()
  paste_linewise("+", false)
end, { desc = "Paste clipboard above" })

-- Toggle relative line numbers
vim.keymap.set("n", "<leader>r", function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end, { desc = "Toggle relative numbers" })
