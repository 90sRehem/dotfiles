return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local extension = {
        servers = {
          eslint = {},
          biome = {},
          vtsls = {
            keys = {
              {
                "<leader>cu",
                function()
                  LazyVim.lsp.action["source.removeUnusedImports.ts"]()
                end,
                desc = "Remove Unused Imports",
              },
            },
          },
        },
        setup = {
          eslint = function()
            require("snacks.util").lsp.on(function(_, client)
              if client.name == "eslint" then
                client.server_capabilities.documentFormattingProvider = true
              elseif client.name == "tsserver" then
                client.server_capabilities.documentFormattingProvider = false
              end
            end)
          end,
        },
      }

      return vim.tbl_deep_extend("force", opts or {}, extension)
    end,
  },
}
