return {
  "snacks.nvim",
  opts = {
    dashboard = {
      width = 40,
      sections = function()
        local header = [[
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]]
        local function greeting()
          local hour = tonumber(vim.fn.strftime("%H"))
          -- [02:00, 10:00) - morning, [10:00, 18:00) - day, [18:00, 02:00) - evening
          local part_id = math.floor((hour + 6) / 8) + 1
          local day_part = ({ "evening", "morning", "afternoon", "evening" })[part_id]
          local username = os.getenv("USER") or os.getenv("USERNAME") or "user"
          return ("Good %s, %s"):format(day_part, username:gsub("^%l", string.upper))
        end

        -- Função para listar projetos
        local function list_projects()
          local projects = {
            "~/projeto1",
            "~/projeto2",
            "~/projeto3",
          }
          local items = {}
          for _, project in ipairs(projects) do
            table.insert(items, {
              icon = " ",
              desc = project,
              action = ":cd " .. project .. " | :Telescope find_files",
            })
          end
          return items
        end

        -- Verificação de diretório Git
        local function git_status()
          if vim.fn.isdirectory(".git") == 1 then
            return {
              icon = " ",
              title = "Git Status",
              action = ":!hub diff --stat -B -M -C",
            }
          end
        end

          -- stylua: ignore
          return {
            { padding = 0, align = "center", text = { header, hl = "header" } },
            { padding = 2, align = "center", text = { greeting(), hl = "header" } },
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            { padding = 1 },
            { section = "recent_files", icon = " ", title = "Recent Files", indent = 3, padding = 2 },
            { section = "projects", icon = " ", title = "Projects", indent = 3, padding = 2 },
            {
              section = "terminal",
              icon = " ",
              title = "Git Status",
              enabled = vim.fn.isdirectory('.git') == 1,
              cmd = "hub diff --stat -B -M -C",
              height = 8,
              padding = 2,
              indent = 0
            },
            { section = "startup" },
          }
      end,
    },
  },
}
-- return {
--   "snacks.nvim",
--   opts = {
--     dashboard = {
--       preset = {
--         pick = function(cmd, opts)
--           return LazyVim.pick(cmd, opts)()
--         end,
--         header = [[
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
--         -- stylua: ignore
--         ---@type snacks.dashboard.Item[]
--         keys = {
--           { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
--           { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
--           { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
--           { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
--           { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
--           { icon = " ", key = "s", desc = "Restore Session", section = "session" },
--           { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
--           { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
--           { icon = " ", key = "q", desc = "Quit", action = ":qa" },
--         },
--       },
--     },
--   },
-- }
--
