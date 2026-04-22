return {
  "saghen/blink.cmp",
  dependencies = {
    "supermaven-inc/supermaven-nvim",
  },
  version = "*",
  opts = {
    keymap = { preset = "default" },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        draw = {
          treesitter = { "lsp" },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = {
        enabled = true,
      },
    },
  },
  config = function(_, opts)
    -- Setup supermaven with inline suggestions (not through blink.cmp)
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-y>",
      },
      ignore_filetypes = { cpp = true },
      color = {
        suggestion_color = "#ffffff",
        cterm = 244,
      },
      log_level = "info",
      disable_inline_completion = false,
      disable_keymaps = false,
    })

    require("blink.cmp").setup(opts)
  end,
}
