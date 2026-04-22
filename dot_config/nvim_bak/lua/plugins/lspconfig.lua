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

      -- Keymaps de navegação LSP (gd, gr, gI, gy, gD, K) são definidos pelo Snacks.picker
      -- Aqui mantemos apenas os que não estão no snacks.lua

      -- Signature Help
      buf_set_keymap(
        bufnr,
        "n",
        "gK",
        "<cmd>lua vim.lsp.buf.signature_help()<CR>",
        vim.tbl_extend("force", opts, { desc = "Signature Help" })
      )

      -- Code Actions
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

      -- Organize Imports (TypeScript/JavaScript)
      vim.keymap.set("n", "<leader>co", function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.organizeImports" },
            diagnostics = {},
          },
        })
      end, { buffer = bufnr, desc = "Organize Imports" })

      -- Remove Unused Imports (TypeScript/JavaScript)
      vim.keymap.set("n", "<leader>cu", function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.removeUnused.ts" },
            diagnostics = {},
          },
        })
      end, { buffer = bufnr, desc = "Remove Unused Imports" })

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

    -- Usar utilitário centralizado para detecção de linters
    local linter_detection = require("config.linter-detection")

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
        return linter_detection.get_biome_root(fname)
      end,
    })

    -- Configuração do ESLint LSP (apenas quando explicitamente configurado)
    local eslint_config = {
      capabilities = capabilities,
      on_attach = on_attach,
      -- Desabilitar completamente se não houver configuração ESLint
      root_dir = function(fname)
        local should_use_eslint = linter_detection.should_use_eslint(fname)
        if not should_use_eslint then
          return nil
        end
        return linter_detection.get_eslint_root(fname)
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
      single_file_support = false, -- Desabilitar single file para forçar root_dir
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
    }
    
    -- Só aplicar configuração ESLint se Mason tiver o servidor instalado
    local eslint_server_path = vim.fn.expand("~/.local/share/nvim/mason/bin/vscode-eslint-language-server")
    if vim.fn.executable(eslint_server_path) == 1 then
      lspconfig.eslint.setup(eslint_config)
    end

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
