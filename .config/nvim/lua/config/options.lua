vim.opt.tabstop = 4        -- Width of an existing tab character
vim.opt.shiftwidth = 4     -- Indentation width for >>, <<, and autoindent
vim.opt.softtabstop = 4    -- Spaces inserted/deleted when pressing Tab/Backspace
vim.opt.expandtab = true   -- Use spaces instead of tab characters
-- absolute current line
vim.opt.number = true
-- default other lines relative
vim.opt.relativenumber = true
-- use system clipboard
vim.opt.clipboard = "unnamedplus"
-- wrap around lines
vim.opt.wrap = false
vim.opt.whichwrap = "b,s,<,>,[,],h,l"
-- disable auto prefix on new line
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})
