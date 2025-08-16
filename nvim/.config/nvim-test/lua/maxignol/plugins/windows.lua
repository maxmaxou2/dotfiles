return { "anuvyklack/windows.nvim",
   dependencies = {"anuvyklack/middleclass"},
   config = function()
		require("windows").setup({
			autowidth = {
				enable = false,
			},
			animation = {
				enable = false,
			},
		})
   end
}
