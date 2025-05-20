return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "hrsh7th/nvim-cmp",
    "nvim-lua/plenary.nvim",
    -- see below for full list of optional dependencies 👇
  },
  event = {
    "BufReadPre *.md",
    "BufNewFile *.md",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Documentos/obsidian",
      },
      {
        name = "work",
        path = "~/Documentos/hyperlocal/obsidian",
      },
    },
    notes_subdir = "notes",
    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = "notes/dailies",
      -- Optional, default tags to add to each new daily note created.
      default_tags = { "daily-notes" },
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = "daily-tasks.md",
    },

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,

    -- Optional, customize how note file names are generated given the ID, target directory, and title.
    ---@param spec { id: string, dir: obsidian.Path, title: string|? }
    ---@return string|obsidian.Path The full path to the new note.
    note_path_func = function(spec)
      -- This is equivalent to the default behavior.
      local path = spec.dir / tostring(spec.id)
      return path:with_suffix(".md")
    end,

    completion = {
      -- Set to false to disable completion.
      nvim_cmp = false,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },
    -- see below for full list of options 👇
    templates = {
      folder = "~/Documentos/obsidian/templates", -- Pasta onde estão seus templates
      date_format = "%Y-%m-%d", -- Formato de data padrão
      time_format = "%H:%M", -- Formato de hora padrão
      substitutions = {
        date = function()
          return os.date("%d-%m-%Y")
        end,
        time = function()
          return os.date("%H:%M")
        end,
        date_plus_7 = function()
          -- Implementar função para retornar data+7 dias
          local timestamp = os.time() + 7 * 24 * 60 * 60
          return os.date("%d/%m/%Y", timestamp)
        end,
        -- Outras variáveis personalizadas
        week_num = function()
          return os.date("%Y-W%W")
        end,
        title = function()
          return vim.fn.input("Title: ")
        end,
      },
    },
    ui = {
      enable = true,
      checkboxes = {
        [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
        ["x"] = { char = "", hl_group = "ObsidianDone" },
        [">"] = { char = "", hl_group = "ObsidianRightArrow" },
        ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        ["!"] = { char = "", hl_group = "ObsidianImportant" },
      },
      bullets = { char = "•", hl_group = "ObsidianBullet" },
    },
  },
}
