return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    defaults = {},
    spec = {
      {
        mode = { "n", "v" },
        { "<leader>o", group = "Obsidian" },
        { "<leader>oo", "<cmd>ObsidianOpen<CR>", desc = "Abrir nota atual no Obsidian" },
        { "<leader>on", "<cmd>ObsidianNew<CR>", desc = "Criar nova nota" },
        { "<leader>os", "<cmd>ObsidianSearch<CR>", desc = "Buscar notas" },
        { "<leader>oq", "<cmd>ObsidianQuickSwitch<CR>", desc = "Alternar notas" },
        { "<leader>of", "<cmd>ObsidianFollowLink<CR>", desc = "Seguir link" },
        { "<leader>ob", "<cmd>ObsidianBacklinks<CR>", desc = "Ver backlinks" },
        { "<leader>ot", "<cmd>ObsidianTags<CR>", desc = "Buscar por tags" },
        { "<leader>od", "<cmd>ObsidianToday<CR>", desc = "Abrir nota diária" },
        { "<leader>oy", "<cmd>ObsidianYesterday<CR>", desc = "Abrir nota de ontem" },
        { "<leader>om", "<cmd>ObsidianTomorrow<CR>", desc = "Abrir nota de amanhã" },
        { "<leader>ol", "<cmd>ObsidianLinks<CR>", desc = "Listar links da nota" },
        { "<leader>op", "<cmd>ObsidianPasteImg<CR>", desc = "Colar imagem" },
        { "<leader>or", "<cmd>ObsidianRename<CR>", desc = "Renomear nota" },
        { "<leader>ox", "<cmd>ObsidianExtractNote<CR>", desc = "Extrair texto para nova nota" },
        { "<leader>orc", "<cmd>ObsidianRename <C-r><C-w><CR>", desc = "Renomear referência sob o cursor" },
        { "<leader>ord", "<cmd>ObsidianRename <C-r><C-w> --dry-run<CR>", desc = "Simular renomeação de referência" },
        { "<leader>oc", "<cmd>ObsidianToggleCheckbox<CR>", desc = "Alternar checkbox" },
        { "<leader>oT", "<cmd>ObsidianNewFromTemplate<CR>", desc = "Criar nova nota a partir de um template" },
        { "<leader>otc", "<cmd>ObsidianTOC<CR>", desc = "Gerar tabela de conteúdos" },
        { "<leader>ow", "<cmd>ObsidianWorkspace<CR>", desc = "Alternar workspace" },
      },
    },
    window = {
      position = "top", -- mantém a posição da janela como na configuração original
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
  end,
}
