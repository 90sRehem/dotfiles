return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.vtsls = opts.servers.vtsls or {}
      opts.servers.vtsls.keys = opts.servers.vtsls.keys or {}
      table.insert(opts.servers.vtsls.keys, {
        "<leader>cu",
        function()
          LazyVim.lsp.action["source.removeUnusedImports.ts"]()
        end,
        desc = "Remove Unused Imports",
      })
      return opts
    end,
  },
}
