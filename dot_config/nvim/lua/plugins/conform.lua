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
          if not ctx.filename then
            return false
          end

          -- Função inline de detecção (mesma lógica do lspconfig)
          local function should_use_biome(filename)
            local util = require("lspconfig.util")

            local eslint_root = util.root_pattern(
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              "eslint.config.js",
              "eslint.config.mjs",
              "eslint.config.cjs"
            )(filename)

            local biome_root = util.root_pattern("biome.json", "biome.jsonc")(filename)

            if eslint_root and biome_root then
              local file_dir = vim.fn.fnamemodify(filename, ":h")
              local eslint_rel = string.gsub(file_dir, vim.fn.fnamemodify(eslint_root, ":p"), "")
              local biome_rel = string.gsub(file_dir, vim.fn.fnamemodify(biome_root, ":p"), "")

              local eslint_distance = select(2, string.gsub(eslint_rel, "/", ""))
              local biome_distance = select(2, string.gsub(biome_rel, "/", ""))

              -- ESLint wins if closer or equal (local preference)
              return biome_distance < eslint_distance
            elseif biome_root then
              return true
            else
              return false
            end
          end

          return should_use_biome(ctx.filename)
        end,
      },
      ["prettier"] = {
        condition = function(_, ctx)
          if not ctx.filename then
            return false
          end

          -- Função inline de detecção (complementar ao Biome)
          local function should_use_prettier(filename)
            local util = require("lspconfig.util")

            local eslint_root = util.root_pattern(
              ".eslintrc",
              ".eslintrc.js",
              ".eslintrc.json",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              "eslint.config.js",
              "eslint.config.mjs",
              "eslint.config.cjs"
            )(filename)

            local biome_root = util.root_pattern("biome.json", "biome.jsonc")(filename)

            if eslint_root and biome_root then
              local file_dir = vim.fn.fnamemodify(filename, ":h")
              local eslint_rel = string.gsub(file_dir, vim.fn.fnamemodify(eslint_root, ":p"), "")
              local biome_rel = string.gsub(file_dir, vim.fn.fnamemodify(biome_root, ":p"), "")

              local eslint_distance = select(2, string.gsub(eslint_rel, "/", ""))
              local biome_distance = select(2, string.gsub(biome_rel, "/", ""))

              -- Prettier wins if ESLint is closer or equal
              return eslint_distance <= biome_distance
            elseif eslint_root then
              return true
            else
              return false
            end
          end

          return should_use_prettier(ctx.filename)
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
      javascript = { "biome", "prettier" },
      javascriptreact = { "biome", "prettier" },
      typescript = { "biome", "prettier" },
      typescriptreact = { "biome", "prettier" },
      json = { "biome", "prettier" },
      jsonc = { "biome", "prettier" },
    },
  },
}
