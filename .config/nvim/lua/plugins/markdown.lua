return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {
      -- hide <sup>/<br> tags; no real superscript in a terminal, so dim the text
      html = {
        tag = {
          sup = { scope_highlight = "Comment" },
          br = { icon = " ⏎ ", highlight = "Comment" },
        },
      },
    },
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
