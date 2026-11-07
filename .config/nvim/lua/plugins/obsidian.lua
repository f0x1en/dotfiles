return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    workspaces = {
      { name = "Main", path = "~/vaults/Main" },
    },
    -- render-markdown draws the UI; avoid double rendering
    ui = { enable = false },
    legacy_commands = false,
  },
}
