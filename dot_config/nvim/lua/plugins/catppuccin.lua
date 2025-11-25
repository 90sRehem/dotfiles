return {
  {
    "catppuccin/nvim",
    lazy = true, -- Desabilitado para usar tema dinâmico do Omarchy
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },
}
