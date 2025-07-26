return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	config = function()
		color = color or "catppuccin-macchiato"
		vim.cmd.colorscheme(color)
	end,
}
