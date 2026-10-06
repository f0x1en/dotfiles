-- absolute current line
vim.opt.number = true
-- default other lines relative
vim.opt.relativenumber = true
-- use system clipboard
vim.opt.clipboard = "unnamedplus"
-- wrap around lines
vim.opt.whichwrap = "b,s,<,>,[,]"
-- disable auto prefix on new line
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})
