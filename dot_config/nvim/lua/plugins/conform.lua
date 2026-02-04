return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      ["markdown-toc"] = {
        condition = function(_, ctx)
          if not ctx or not ctx.buf then
            return false
          end
          for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
            if line:find("<!%-%- toc %-%->") then
              return true
            end
          end
        end,
      },
      ["markdownlint-cli2"] = {
        condition = function(_, ctx)
          if not ctx or not ctx.buf then
            return false
          end
          local diag = vim.tbl_filter(function(d)
            return d.source == "markdownlint"
          end, vim.diagnostic.get(ctx.buf))
          return #diag > 0
        end,
      },
      ["sql_formatter"] = {
        args = { "-c", "/home/rehem/.config/nvim/.sql-formatter.json" },
      },
      ["biome"] = {
        require_cwd = true,
        condition = function(_, ctx)
          return vim.fs.find({ "biome.json", "biome.jsonc" }, {
            path = ctx.filename,
            upward = true
          })[1] ~= nil
        end,
      },
    },
    formatters_by_ft = {
      lua = { "stylua" },
      yaml = { "yamlfix" },
      markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
      ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
      sql = { "sql_formatter" },
      mysql = { "sql_formatter" },
      plsql = { "sql_formatter" },
      postgres = { "sql_formatter" },
      javascript = { "biome" },
      javascriptreact = { "biome" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
      json = { "biome" },
      jsonc = { "biome" },
    },
  },
}
