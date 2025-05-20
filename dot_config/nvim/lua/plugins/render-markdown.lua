return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
  -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    code = {
      -- Turn on / off code block & inline code rendering.
      enabled = true,
      -- Additional modes to render code blocks.
      render_modes = false,
      -- Turn on / off any sign column related rendering.
      sign = true,
      -- Determines how code blocks & inline code are rendered.
      -- | none     | disables all rendering                                                    |
      -- | normal   | highlight group to code blocks & inline code, adds padding to code blocks |
      -- | language | language icon to sign column if enabled and icon + name above code blocks |
      -- | full     | normal + language                                                         |
      style = "full",
      -- Determines where language icon is rendered.
      -- | right | right side of code block |
      -- | left  | left side of code block  |
      position = "left",
      -- Amount of padding to add around the language.
      -- If a float < 1 is provided it is treated as a percentage of available window space.
      language_pad = 0,
      -- Whether to include the language icon above code blocks.
      language_icon = true,
      -- Whether to include the language name above code blocks.
      language_name = true,
      -- A list of language names for which background highlighting will be disabled.
      -- Likely because that language has background highlights itself.
      -- Use a boolean to make behavior apply to all languages.
      -- Borders above & below blocks will continue to be rendered.
      disable_background = { "diff" },
      -- Width of the code block background.
      -- | block | width of the code block  |
      -- | full  | full width of the window |
      width = "full",
      -- Amount of margin to add to the left of code blocks.
      -- If a float < 1 is provided it is treated as a percentage of available window space.
      -- Margin available space is computed after accounting for padding.
      left_margin = 0,
      -- Amount of padding to add to the left of code blocks.
      -- If a float < 1 is provided it is treated as a percentage of available window space.
      left_pad = 0,
      -- Amount of padding to add to the right of code blocks when width is 'block'.
      -- If a float < 1 is provided it is treated as a percentage of available window space.
      right_pad = 0,
      -- Minimum width to use for code blocks when width is 'block'.
      min_width = 0,
      -- Determines how the top / bottom of code block are rendered.
      -- | none  | do not render a border                               |
      -- | thick | use the same highlight as the code body              |
      -- | thin  | when lines are empty overlay the above & below icons |
      -- | hide  | conceal lines unless language name or icon is added  |
      border = "none",
      -- Used above code blocks for thin border.
      above = "▄",
      -- Used below code blocks for thin border.
      below = "▀",
      -- Padding to add to the left & right of inline code.
      inline_pad = 0,
      -- Highlight for code blocks.
      highlight = "RenderMarkdownCode",
      -- Highlight for language, overrides icon provider value.
      highlight_language = nil,
      -- Highlight for border, use false to add no highlight.
      highlight_border = "RenderMarkdownCodeBorder",
      -- Highlight for language, used if icon provider does not have a value.
      highlight_fallback = "RenderMarkdownCodeFallback",
      -- Highlight for inline code.
      highlight_inline = "RenderMarkdownCodeInline",
    },
    heading = {
      -- Turn on / off heading icon & background rendering.
      enabled = true,
      -- Additional modes to render headings.
      render_modes = false,
      -- Turn on / off atx heading rendering.
      atx = true,
      -- Turn on / off setext heading rendering.
      setext = true,
      -- Turn on / off any sign column related rendering.
      sign = true,
      -- Replaces '#+' of 'atx_h._marker'.
      -- Output is evaluated depending on the type.
      -- | function | `value(context)`              |
      -- | string[] | `cycle(value, context.level)` |
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      -- Determines how icons fill the available space.
      -- | right   | '#'s are concealed and icon is appended to right side                          |
      -- | inline  | '#'s are concealed and icon is inlined on left side                            |
      -- | overlay | icon is left padded with spaces and inserted on left hiding any additional '#' |
      position = "overlay",
      -- Added to the sign column if enabled.
      -- Output is evaluated by `cycle(value, context.level)`.
      signs = { "󰫎 " },
      -- Width of the heading background.
      -- | block | width of the heading text |
      -- | full  | full width of the window  |
      -- Can also be a list of the above values evaluated by `clamp(value, context.level)`.
      width = "full",
      -- Amount of margin to add to the left of headings.
      -- Margin available space is computed after accounting for padding.
      -- If a float < 1 is provided it is treated as a percentage of available window space.
      -- Can also be a list of numbers evaluated by `clamp(value, context.level)`.
      left_margin = 0,
      -- Amount of padding to add to the left of headings.
      -- Output is evaluated using the same logic as 'left_margin'.
      left_pad = 0,
      -- Amount of padding to add to the right of headings when width is 'block'.
      -- Output is evaluated using the same logic as 'left_margin'.
      right_pad = 0,
      -- Minimum width to use for headings when width is 'block'.
      -- Can also be a list of integers evaluated by `clamp(value, context.level)`.
      min_width = 0,
      -- Determines if a border is added above and below headings.
      -- Can also be a list of booleans evaluated by `clamp(value, context.level)`.
      border = false,
      -- Always use virtual lines for heading borders instead of attempting to use empty lines.
      border_virtual = false,
      -- Highlight the start of the border using the foreground highlight.
      border_prefix = false,
      -- Used above heading for border.
      above = "▄",
      -- Used below heading for border.
      below = "▀",
      -- Highlight for the heading icon and extends through the entire line.
      -- Output is evaluated by `clamp(value, context.level)`.
      backgrounds = {
        "RenderMarkdownH1Bg",
        "RenderMarkdownH2Bg",
        "RenderMarkdownH3Bg",
        "RenderMarkdownH4Bg",
        "RenderMarkdownH5Bg",
        "RenderMarkdownH6Bg",
      },
      -- Highlight for the heading and sign icons.
      -- Output is evaluated using the same logic as 'backgrounds'.
      foregrounds = {
        "RenderMarkdownH1",
        "RenderMarkdownH2",
        "RenderMarkdownH3",
        "RenderMarkdownH4",
        "RenderMarkdownH5",
        "RenderMarkdownH6",
      },
      -- Define custom heading patterns which allow you to override various properties based on
      -- the contents of a heading.
      -- The key is for healthcheck and to allow users to change its values, value type below.
      -- | pattern    | matched against the heading text @see :h lua-pattern |
      -- | icon       | optional override for the icon                       |
      -- | background | optional override for the background                 |
      -- | foreground | optional override for the foreground                 |
      custom = {},
    },
    checkbox = {
      -- Turn on / off checkbox state rendering.
      enabled = true,
      -- Additional modes to render checkboxes.
      render_modes = false,
      -- Padding to add to the right of checkboxes.
      right_pad = 1,
      unchecked = {
        -- Replaces '[ ]' of 'task_list_marker_unchecked'.
        icon = "󰄱 ",
        -- Highlight for the unchecked icon.
        highlight = "RenderMarkdownUnchecked",
        -- Highlight for item associated with unchecked checkbox.
        scope_highlight = nil,
      },
      checked = {
        -- Replaces '[x]' of 'task_list_marker_checked'.
        icon = "󰱒 ",
        -- Highlight for the checked icon.
        highlight = "RenderMarkdownChecked",
        -- Highlight for item associated with checked checkbox.
        scope_highlight = nil,
      },
      -- Define custom checkbox states, more involved, not part of the markdown grammar.
      -- As a result this requires neovim >= 0.10.0 since it relies on 'inline' extmarks.
      -- The key is for healthcheck and to allow users to change its values, value type below.
      -- | raw             | matched against the raw text of a 'shortcut_link'           |
      -- | rendered        | replaces the 'raw' value when rendering                     |
      -- | highlight       | highlight for the 'rendered' icon                           |
      -- | scope_highlight | optional highlight for item associated with custom checkbox |
      custom = {
        todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
      },
    },
    bullet = {
      -- Turn on / off list bullet rendering
      enabled = true,
      -- Additional modes to render list bullets
      render_modes = false,
      -- Replaces '-'|'+'|'*' of 'list_item'.
      -- If the item is a 'checkbox' a conceal is used to hide the bullet instead.
      -- Output is evaluated depending on the type.
      -- | function   | `value(context)`                                    |
      -- | string     | `value`                                             |
      -- | string[]   | `cycle(value, context.level)`                       |
      -- | string[][] | `clamp(cycle(value, context.level), context.index)` |
      icons = { "●", "○", "◆", "◇" },
      -- Replaces 'n.'|'n)' of 'list_item'.
      -- Output is evaluated using the same logic as 'icons'.
      ordered_icons = function(ctx)
        local value = vim.trim(ctx.value)
        local index = tonumber(value:sub(1, #value - 1))
        return string.format("%d.", index > 1 and index or ctx.index)
      end,
      -- Padding to add to the left of bullet point.
      -- Output is evaluated depending on the type.
      -- | function | `value(context)` |
      -- | integer  | `value`          |
      left_pad = 0,
      -- Padding to add to the right of bullet point.
      -- Output is evaluated using the same logic as 'left_pad'.
      right_pad = 0,
      -- Highlight for the bullet icon.
      -- Output is evaluated using the same logic as 'icons'.
      highlight = "RenderMarkdownBullet",
      -- Highlight for item associated with the bullet point.
      -- Output is evaluated using the same logic as 'icons'.
      scope_highlight = {},
    },
  },
}
