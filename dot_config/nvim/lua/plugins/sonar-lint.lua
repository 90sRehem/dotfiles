return {
  url = "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
  version = "*", -- ou um commit mais recente se quiser garantir
  enabled = false,
  config = function()
    require("sonarlint").setup({
      server = {
        cmd = {
          "sonarlint-language-server",
          "-stdio",
          "-analyzers",
          vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonarjs.jar"),
        },
      },
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "css" },
    })
  end,
}
