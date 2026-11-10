return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  -- obsidian.nvim errors ("Invalid configuration") when the vault folder is missing
  cond = function() return vim.uv.fs_stat(vim.fn.expand("~/vaults/Main")) ~= nil end,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      { name = "Main", path = "~/vaults/Main" },
    },
    -- render-markdown draws the UI; avoid double rendering
    ui = { enable = false },
    legacy_commands = false,
    -- do not add id/aliases/tags to notes on save
    frontmatter = { enabled = false },
  },
}
