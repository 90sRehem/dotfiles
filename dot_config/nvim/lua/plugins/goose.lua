return {
  "azorng/goose.nvim",
  config = function()
    require("goose").setup({
      default_global_keymaps = false,
      keymap = {
        global = {
          toggle = "<leader>agg", -- Abrir/Fechar Goose
          open_input = "<leader>agi", -- Input
          open_input_new_session = "<leader>agI", -- Nova sessão + input
          open_output = "<leader>ago", -- Output
          toggle_focus = "<leader>agt", -- Alternar foco
          close = "<leader>agq", -- Fechar UI
          toggle_fullscreen = "<leader>agf", -- Fullscreen
          select_session = "<leader>ags", -- Selecionar sessão
          goose_mode_chat = "<leader>agmc", -- Modo chat
          goose_mode_auto = "<leader>agma", -- Modo auto
          configure_provider = "<leader>agp", -- Provider/Model
          diff_open = "<leader>agd", -- Diff
          diff_next = "<leader>ag]", -- Próximo diff
          diff_prev = "<leader>ag[", -- Diff anterior
          diff_close = "<leader>agc", -- Fechar diff
          diff_revert_all = "<leader>agra", -- Reverter todos
          diff_revert_this = "<leader>agrt", -- Reverter atual
        },
      },
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        anti_conceal = { enabled = false },
      },
    },
  },
}
