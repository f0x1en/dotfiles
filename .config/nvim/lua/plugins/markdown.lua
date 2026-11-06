return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {},
    keys = {
      {
        "<leader>mt",
        "<cmd>RenderMarkdown toggle<cr>",
        desc = "Markdown render toggle",
      },
    },
  },
  {
    "yousefhadder/markdown-plus.nvim",
    ft = "markdown",
    opts = {},
  },
}
