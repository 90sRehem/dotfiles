return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason.nvim",
    "mason-org/mason-lspconfig.nvim",
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
  opts = {
    -- Configurar diagnósticos com virtual text habilitado
    diagnostics = {
      virtual_text = true,
      signs = true,
      update_in_insert = false,
      underline = true,
      severity_sort = true,
    },
    servers = {
      vtsls = {
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
      },
      eslint = {
        root_dir = function(fname)
          local util = require("lspconfig.util")
          -- Só ativa ESLint se não houver biome.json
          local biome_root = util.root_pattern("biome.json", "biome.jsonc")(fname)
          if biome_root then return nil end
          return util.root_pattern(".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js")(fname)
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
        settings = {
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
      tailwindcss = {
        experimental = {
          classRegex = {
            { "(`.*?`)", "(\".*?\")", "('.*?')" }
          },
        },
      },
      marksman = {},
      dockerls = {},
      docker_compose_language_service = {},
      yamlls = {
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
      },
    },
    setup = {
      clangd = function(_, opts)
        opts.capabilities = opts.capabilities or {}
        opts.capabilities.offsetEncoding = { "utf-16" }
      end,
      yamlls = function()
        if vim.fn.has("nvim-0.10") == 0 then
          require("lazyvim.util").lsp.on_attach(function(client)
            if client.name == "yamlls" then
              client.server_capabilities.documentFormattingProvider = true
            end
          end)
        end
      end,
    },
  },
}