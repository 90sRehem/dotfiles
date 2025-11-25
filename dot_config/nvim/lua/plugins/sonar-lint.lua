return {
  "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
  dependencies = {
    "mason-org/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "python", "java", "php", "go" },
  config = function()
    local sonarlint_cmd = vim.fn.expand("~/.local/share/nvim/mason/bin/sonarlint-language-server")

    if vim.fn.executable(sonarlint_cmd) == 1 then
      require("sonarlint").setup({
        server = {
          cmd = {
            sonarlint_cmd,
            "-stdio",
            "-analyzers",
            vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonarjs.jar"),
            vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonarhtml.jar"),
            vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonarphp.jar"),
            vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonarpython.jar"),
            vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonarjava.jar"),
            vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonargo.jar"),
            vim.fn.expand("~/.local/share/nvim/mason/share/sonarlint-analyzers/sonartext.jar"),
          },
        },
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "html",
          "python",
          "java",
          "php",
          "go",
        },
      })
    end
  end,
}
