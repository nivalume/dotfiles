return {
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,
		opts = {
			style = "vivid",
			transparent = true,
		},
	},
	{ "Mofiqul/vscode.nvim", lazy = true, priority = 1000 },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 1000 },
	{ "ellisonleao/gruvbox.nvim", lazy = true, priority = 1000 },
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "solarized-osaka",
		},
	},
}
