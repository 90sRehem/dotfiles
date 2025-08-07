return {
  "neovim/nvim-lspconfig",
  init = function()
    -- Define o caminho do Node.js para todos os servidores LSP
    local node_path = "/home/rehem/.local/share/mise/installs/node/22.17.1/bin/node"
    vim.g.node_host_prog = node_path

    -- Adiciona o diretório do Node.js ao PATH
    local env_path = vim.env.PATH
    if not string.find(env_path, "/home/rehem/.local/share/mise/installs/node/22.17.1/bin") then
      vim.env.PATH = "/home/rehem/.local/share/mise/installs/node/22.17.1/bin:" .. env_path
    end
  end,
  opts = {
    eslint = {},
    servers = {
      tsserver = {},
      tailwindcss = {},
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
