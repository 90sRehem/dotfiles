return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  init = function()
    -- Define o caminho do Node.js usando variável de ambiente do mise
    local node_path = vim.env.NVIM_NODE_PATH or vim.fn.system("mise which node"):gsub("%s+", "")
    if node_path and node_path ~= "" then
      vim.g.node_host_prog = node_path

      -- Adiciona o diretório do Node.js ao PATH
      local node_bin_dir = vim.fn.fnamemodify(node_path, ":h")
      local env_path = vim.env.PATH
      if not string.find(env_path, node_bin_dir, 1, true) then
        vim.env.PATH = node_bin_dir .. ":" .. env_path
      end
    end
  end,
  config = function()
    -- Configurar diagnósticos
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      update_in_insert = false,
      underline = true,
      severity_sort = true,
    })

    local lspconfig = require("lspconfig")

    -- Configurar capabilities padrão
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if has_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Configurar keymaps de LSP
    local function on_attach(client, bufnr)
      local buf_set_keymap = vim.api.nvim_buf_set_keymap
      local opts = { noremap = true, silent = true }

      -- Keymaps essenciais do LSP (baseados no LazyVim)
      buf_set_keymap(
        bufnr,
        "n",
        "gd",
        "<cmd>lua vim.lsp.buf.definition()<CR>",
        vim.tbl_extend("force", opts, { desc = "Goto Definition" })
      )
      buf_set_keymap(
        bufnr,
        "n",
        "gr",
        "<cmd>lua vim.lsp.buf.references()<CR>",
        vim.tbl_extend("force", opts, { desc = "References" })
      )
      buf_set_keymap(
        bufnr,
        "n",
        "gI",
        "<cmd>lua vim.lsp.buf.implementation()<CR>",
        vim.tbl_extend("force", opts, { desc = "Goto Implementation" })
      )
      buf_set_keymap(
        bufnr,
        "n",
        "gy",
        "<cmd>lua vim.lsp.buf.type_definition()<CR>",
        vim.tbl_extend("force", opts, { desc = "Goto Type Definition" })
      )
      buf_set_keymap(
        bufnr,
        "n",
        "gD",
        "<cmd>lua vim.lsp.buf.declaration()<CR>",
        vim.tbl_extend("force", opts, { desc = "Goto Declaration" })
      )
      buf_set_keymap(
        bufnr,
        "n",
        "K",
        "<cmd>lua vim.lsp.buf.hover()<CR>",
        vim.tbl_extend("force", opts, { desc = "Hover" })
      )
      buf_set_keymap(
        bufnr,
        "n",
        "gK",
        "<cmd>lua vim.lsp.buf.signature_help()<CR>",
        vim.tbl_extend("force", opts, { desc = "Signature Help" })
      )

      -- Code Actions - O mais importante!
      buf_set_keymap(
        bufnr,
        "n",
        "<leader>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>",
        vim.tbl_extend("force", opts, { desc = "Code Action" })
      )
      buf_set_keymap(
        bufnr,
        "x",
        "<leader>ca",
        "<cmd>lua vim.lsp.buf.code_action()<CR>",
        vim.tbl_extend("force", opts, { desc = "Code Action" })
      )
      buf_set_keymap(
        bufnr,
        "n",
        "<leader>cr",
        "<cmd>lua vim.lsp.buf.rename()<CR>",
        vim.tbl_extend("force", opts, { desc = "Rename" })
      )
      buf_set_keymap(
        bufnr,
        "n",
        "<leader>cA",
        "<cmd>lua vim.lsp.buf.code_action({context = {only = {'source'}}})<CR>",
        vim.tbl_extend("force", opts, { desc = "Source Action" })
      )

      -- Formatação
      if client.server_capabilities.documentFormattingProvider then
        buf_set_keymap(
          bufnr,
          "n",
          "<leader>cf",
          "<cmd>lua vim.lsp.buf.format({ async = true })<CR>",
          vim.tbl_extend("force", opts, { desc = "Format Document" })
        )
      end
      if client.server_capabilities.documentRangeFormattingProvider then
        buf_set_keymap(
          bufnr,
          "x",
          "<leader>cf",
          "<cmd>lua vim.lsp.buf.format({ async = true })<CR>",
          vim.tbl_extend("force", opts, { desc = "Format Range" })
        )
      end
    end

    -- Função inline para detecção inteligente Biome vs ESLint
    local function find_nearest_config(file_path)
      local util = require("lspconfig.util")

      -- Find ESLint config (local priority)
      local eslint_root = util.root_pattern(
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "package.json" -- Fallback para projetos com eslint no package.json
      )(file_path)

      -- Verificar se é realmente um projeto ESLint quando package.json for encontrado
      if
        eslint_root
        and not util.root_pattern(
          ".eslintrc",
          ".eslintrc.js",
          ".eslintrc.json",
          ".eslintrc.yaml",
          ".eslintrc.yml",
          "eslint.config.js",
          "eslint.config.mjs",
          "eslint.config.cjs"
        )(file_path)
      then
        -- É package.json, verificar se tem eslint
        local package_json = eslint_root .. "/package.json"
        local f = io.open(package_json, "r")
        if f then
          local content = f:read("*all")
          f:close()
          if not content:match('"eslint"') then
            eslint_root = nil -- Não é um projeto ESLint
          end
        else
          eslint_root = nil
        end
      end

      -- Find Biome config (can be parent)
      local biome_root = util.root_pattern("biome.json", "biome.jsonc")(file_path)

      -- ESLint local beats Biome remote (migration-friendly)
      if eslint_root and biome_root then
        -- Calculate distances by counting path separators
        local file_dir = vim.fn.fnamemodify(file_path, ":h")
        local eslint_rel = string.gsub(file_dir, vim.fn.fnamemodify(eslint_root, ":p"), "")
        local biome_rel = string.gsub(file_dir, vim.fn.fnamemodify(biome_root, ":p"), "")

        local eslint_distance = select(2, string.gsub(eslint_rel, "/", ""))
        local biome_distance = select(2, string.gsub(biome_rel, "/", ""))

        -- ESLint wins if closer or equal distance (local preference)
        if eslint_distance <= biome_distance then
          return { use_biome = false, use_eslint = true, biome_root = biome_root, eslint_root = eslint_root }
        else
          return { use_biome = true, use_eslint = false, biome_root = biome_root, eslint_root = eslint_root }
        end
      elseif eslint_root then
        return { use_biome = false, use_eslint = true, eslint_root = eslint_root }
      elseif biome_root then
        return { use_biome = true, use_eslint = false, biome_root = biome_root }
      else
        return { use_biome = false, use_eslint = false }
      end
    end

    -- Configuração do Biome LSP
    lspconfig.biome.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        biome = {
          lspBin = "biome",
          enableMoveToFileCodeAction = true,
        },
      },
      root_dir = function(fname)
        local config = find_nearest_config(fname)
        return config.use_biome and config.biome_root or nil
      end,
    })

    -- Configuração do ESLint LSP
    lspconfig.eslint.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      root_dir = function(fname)
        local config = find_nearest_config(fname)
        return config.use_eslint and config.eslint_root or nil
      end,
      cmd = {
        vim.fn.expand("~/.local/share/nvim/mason/bin/vscode-eslint-language-server"),
        "--stdio",
      },
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
      single_file_support = true,
      settings = {
        eslint = {
          codeAction = {
            disableRuleComment = {
              enable = true,
              location = "separateLine",
            },
            showDocumentation = {
              enable = true,
            },
          },
          codeActionOnSave = {
            enable = false,
            mode = "all",
          },
          format = true,
          nodePath = "",
          onIgnoredFiles = "off",
          packageManager = "npm",
          quiet = false,
          rulesCustomizations = {},
          run = "onType",
          useESLintClass = false,
          validate = "on",
          workingDirectory = {
            mode = "location",
          },
        },
      },
    })

    -- Configuração do VTSLS (TypeScript)
    lspconfig.vtsls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        vtsls = {
          enableMoveToFileCodeAction = true,
        },
        typescript = {
          updateImportsOnFileMove = { enabled = "always" },
          suggest = {
            completeFunctionCalls = true,
          },
          inlayHints = {
            enumMemberValues = { enabled = true },
            functionLikeReturnTypes = { enabled = true },
            parameterNames = { enabled = "literals" },
            parameterTypes = { enabled = true },
            propertyDeclarationTypes = { enabled = true },
            variableTypes = { enabled = false },
          },
        },
      },
    })

    -- Configuração do TailwindCSS
    lspconfig.tailwindcss.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        tailwindCSS = {
          experimental = {
            classRegex = {
              { "(`.*?`)", '(".*?")', "('.*?')" },
            },
          },
        },
      },
    })

    -- Outros LSPs
    lspconfig.marksman.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })
    lspconfig.dockerls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })
    lspconfig.docker_compose_language_service.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- YamlLS com SchemaStore
    lspconfig.yamlls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      on_new_config = function(new_config)
        local ok, schemastore = pcall(require, "schemastore")
        if ok then
          new_config.settings = new_config.settings or {}
          new_config.settings.yaml = new_config.settings.yaml or {}
          new_config.settings.yaml.schemas =
            vim.tbl_deep_extend("force", new_config.settings.yaml.schemas or {}, schemastore.yaml.schemas())
        end
      end,
      settings = {
        redhat = { telemetry = { enabled = false } },
        yaml = {
          keyOrdering = false,
          format = { enable = true },
          validate = true,
          schemaStore = {
            enable = false,
            url = "",
          },
        },
      },
    })

    -- Clangd com offsetEncoding
    lspconfig.clangd.setup({
      capabilities = vim.tbl_extend("force", capabilities, {
        offsetEncoding = { "utf-16" },
      }),
      on_attach = on_attach,
    })
  end,
}
