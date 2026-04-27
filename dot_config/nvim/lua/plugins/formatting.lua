-- Formatting: Biome (via lang.typescript.biome extra, if biome.json present) → Prettier fallback
-- Biome LSP provides diagnostics natively when biome.json is found at project root
-- Prettier only formats when a project config file is found
vim.g.lazyvim_prettier_needs_config = true

-- Filetypes NOT covered by the biome extra (biome doesn't support less/html/yaml)
local prettier_only_filetypes = {
  "less",
  "html",
  "yaml",
}

return {
  -- conform.nvim: add Prettier for filetypes Biome doesn't support
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      for _, ft in ipairs(prettier_only_filetypes) do
        opts.formatters_by_ft[ft] = { "prettier" }
      end

      return opts
    end,
  },

  -- Mason: ensure formatters/linters are installed
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "prettier",
        "biome",
        "eslint_d",
      })
    end,
  },
}
