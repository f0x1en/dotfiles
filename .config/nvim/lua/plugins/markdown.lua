return {
  {
    "delphinus/md-render.nvim",
    version = "3.10.3",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    keys = {
      {
        "<leader>mt",
        "<cmd>MdRender toggle<cr>",
        desc = "Markdown render",
      },
    },
  },
}
