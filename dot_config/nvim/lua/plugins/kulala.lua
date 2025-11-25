return {
  "mistweaverco/kulala.nvim",
  opts = {
    curl_path = "curl",
    display_mode = "float",
    q_to_close_float = false,
    split_direction = "vertical",
    default_view = "body",
    default_env = "dev",
    debug = false,
    winbar = true,
    vscode_rest_client_environmentvars = false,
    disable_script_print_output = false,
    environment_scope = "b",
    urlencode = "always",
    show_variable_info_text = false,

    contenttypes = {
      ["application/json"] = {
        ft = "json",
        formatter = { "jq", "." },
        pathresolver = require("kulala.parser.jsonpath").parse,
      },
      ["application/xml"] = {
        ft = "xml",
        formatter = { "xmllint", "--format", "-" },
        pathresolver = { "xmllint", "--xpath", "{{path}}", "-" },
      },
      ["text/html"] = {
        ft = "html",
        formatter = { "xmllint", "--format", "--html", "-" },
        pathresolver = {},
      },
    },

    show_icons = "on_request",
    icons = {
      inlay = {
        loading = "⏳",
        done = "✅",
        error = "❌",
      },
      lualine = "🐼",
    },

    additional_curl_options = {},
    scratchpad_default_contents = {
      "@MY_TOKEN_NAME=my_token_value",
      "",
      "# @name scratchpad",
      "POST https://httpbin.org/post HTTP/1.1",
      "accept: application/json",
      "content-type: application/json",
      "",
      "{",
      '  "foo": "bar"',
      "}",
    },

    default_winbar_panes = { "body", "headers", "headers_body", "verbose" },
    certificates = {},

    -- ⬇️ coloca aqui dentro os keymaps também
    global_keymaps = false,
    kulala_keymaps = true,
  },

  keys = {
    {
      "<leader>Re",
      function()
        require("kulala").set_selected_env()
      end,
      desc = "Selecionar Ambiente",
      mode = "n",
      ft = "http",
    },
  },
}
