return {
  "NickvanDyke/opencode.nvim",
  dependencies = { "folke/snacks.nvim", "folke/which-key.nvim" },
  ---@type opencode.Config
  opts = {
    -- Your configuration, if any
  },
  -- stylua: ignore
  keys = {
    { '<leader>at', function() require('opencode').toggle() end, desc = 'Toggle embedded opencode', },
    { '<leader>aa', function() require('opencode').ask() end, desc = 'Ask opencode', mode = 'n', },
    { '<leader>aa', function() require('opencode').ask('@selection: ') end, desc = 'Ask opencode about selection', mode = 'v', },
    { '<leader>ap', function() require('opencode').select_prompt() end, desc = 'Select prompt', mode = { 'n', 'v', }, },
    { '<leader>an', function() require('opencode').command('session_new') end, desc = 'New session', },
    { '<leader>ay', function() require('opencode').command('messages_copy') end, desc = 'Copy last message', },
    { '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, desc = 'Scroll messages up', },
    { '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, desc = 'Scroll messages down', },
  },
  config = function(_, opts)
    require("opencode").setup(opts)
    local wk = require("which-key")
    wk.add({
      { "<leader>a", group = "AI" },
      { "<leader>at", desc = "Toggle OpenCode" },
      { "<leader>aa", desc = "Ask OpenCode" },
      { "<leader>ap", desc = "Select Prompt" },
      { "<leader>an", desc = "New Session" },
      { "<leader>ay", desc = "Copy Last Message" },
    })
  end,
}
