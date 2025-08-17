return {
  "https://gitlab.com/schrieveslaach/sonarlint.nvim.git",
  name = "sonarlint.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
  },
  ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "html", "python", "java", "php", "go" },
  config = function()
    require("sonarlint").setup({
      server = {
        cmd = {
          "sonarlint-language-server",
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
  end,
}
