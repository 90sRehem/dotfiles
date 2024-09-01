-- change some telescope options and a keymap to browse plugin files
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "jvgrootveld/telescope-zoxide" },
  keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    {
      "<leader>fj",
      function()
        require("telescope.builtin").lsp_references()
      end,
      desc = "Find Funcion References",
    },
  },
  -- change some options
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
    },
    config = function(_, opts)
      require("telescope").setup(opts)
      -- Carrega a extensão do zoxide
      require("telescope").load_extension("zoxide")
    end,
  },
}
