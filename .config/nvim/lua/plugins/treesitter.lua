return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,

    build = ":TSUpdate",

    config = function()
      require("nvim-treesitter").install({
        "lua",
        "vim",
        "vimdoc",
        "markdown",
        "markdown_inline",
        "html",
        "python",
        "c",
      })
    end,
  },
}
