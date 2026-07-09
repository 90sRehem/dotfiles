return {
	{ "tahayvr/matteblack.nvim" },
	{ "catppuccin/nvim" },
	{ "sainnhe/everforest" },
	{ "kepano/flexoki-neovim" },
	{ "ellisonleao/gruvbox.nvim" },
	{ "bjarneo/hackerman.nvim" },
	{ "rebelot/kanagawa.nvim" },
	{ "omacom-io/lumon.nvim" },
	{ "OldJobobo/miasma.nvim" },
	{ "shaunsingh/nord.nvim" },
	{ "rose-pine/neovim", name = "rose-pine" },
	{ "OldJobobo/retro-82.nvim" },
	{ "loctvl842/monokai-pro.nvim" },
	{ "bjarneo/ethereal.nvim" },
	{ "bjarneo/vantablack.nvim" },
	{ "bjarneo/white.nvim" },
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = function()
				vim.defer_fn(function()
					local f = io.open(
						vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua"),
						"r"
					)
					if f then
						local content = f:read("*a")
						f:close()
						local colorscheme = content:match("opts%s*=%s*{[^}]*colorscheme%s*=%s*\"([^\"]+)\"")
							or content:match("colorscheme%s*=%s*\"([^\"]+)\"")
						if colorscheme then
							pcall(vim.cmd.colorscheme, colorscheme)
							return
						end
					end
					pcall(vim.cmd.colorscheme, "tokyonight")
				end, 0)
			end,
		},
	},
}