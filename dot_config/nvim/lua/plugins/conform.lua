return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      ["yaml"] = { "yamlfix" },
      ["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
      ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
      ["sql"] = { "sqlfluff" },
      ["mysql"] = { "sqlfluff" },
      ["plsql"] = { "sqlfluff" },
      ["postgres"] = { "sqlfluff" },
      -- adicione outros filetypes de SQL se necessário
    },
    formatters = {
      ["markdown-toc"] = {
        condition = function(_, ctx)
          for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
            if line:find("<!%-%- toc %-%->") then
              return true
            end
          end
        end,
      },
      ["markdownlint-cli2"] = {
        condition = function(_, ctx)
          local diag = vim.tbl_filter(function(d)
            return d.source == "markdownlint"
          end, vim.diagnostic.get(ctx.buf))
          return #diag > 0
        end,
      },
      ["sqlfluff"] = {
        args = { "format", "--dialect=ansi", "-" }, -- altere o dialect conforme seu banco (ansi, postgres, etc)
      },
    },
  },
}
