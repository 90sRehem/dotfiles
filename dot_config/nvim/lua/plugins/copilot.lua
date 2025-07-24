return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      auto_trigger = true,
    },
    server_opts_overrides = {
      cmd = { "/home/rehem/.local/share/mise/installs/node/22.17.1/bin/node", "/home/rehem/.local/share/nvim/lazy/copilot.lua/copilot/js/language-server.js", "--stdio" },
    },
  },
}
