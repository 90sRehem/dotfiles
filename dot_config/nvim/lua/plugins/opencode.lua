return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    "folke/which-key.nvim",
  },
  keys = {
    -- Toggle
    {
      "<leader>at",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle OpenCode",
      mode = { "n", "t" },
    },

    -- Ask (com comportamento moderno)
    {
      "<leader>aa",
      function()
        require("opencode").ask("@this: ", { submit = true })
      end,
      desc = "Ask OpenCode",
      mode = "n",
    },
    {
      "<leader>aa",
      function()
        require("opencode").ask("@selection: ", { submit = true })
      end,
      desc = "Ask OpenCode about selection",
      mode = "v",
    },

    -- Select/Prompt (API nova)
    {
      "<leader>ap",
      function()
        require("opencode").select()
      end,
      desc = "Select OpenCode action",
      mode = { "n", "v" },
    },
    {
      "<leader>ad",
      function()
        require("opencode").prompt("@this")
      end,
      desc = "Add to OpenCode context",
      mode = { "n", "v" },
    },

    -- Commands (API nova com notação .)
    {
      "<leader>an",
      function()
        require("opencode").command("session.new")
      end,
      desc = "New OpenCode session",
    },
    {
      "<leader>ay",
      function()
        require("opencode").command("messages.copy")
      end,
      desc = "Copy last message",
    },

    -- Scroll (mantém atalhos globais)
    {
      "<S-C-u>",
      function()
        require("opencode").command("session.half.page.up")
      end,
      desc = "OpenCode scroll up",
    },
    {
      "<S-C-d>",
      function()
        require("opencode").command("session.half.page.down")
      end,
      desc = "OpenCode scroll down",
    },
  },
  config = function()
    vim.g.opencode_opts = {}
    vim.o.autoread = true

    -- Which-key groups
    local wk_ok, wk = pcall(require, "which-key")
    if wk_ok then
      wk.add({
        { "<leader>a", group = "AI" },
      })
    end
  end,
}
