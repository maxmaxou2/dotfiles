return {
	-- "maxmaxou2/zoom-sync.nvim",
    dir = "~/src/zoom-sync.nvim",
    name = "zoom-sync",
	-- dependencies = {
	-- 	"anuvyklack/windows.nvim",
	-- 	-- "anuvyklack/middleclass", -- required by windows.nvim
	-- 	-- uncomment if you want animations (configurable in windows.nvim)
	-- 	-- "anuvyklack/animation.nvim",
	-- },
	config = function()
		-- vim.o.winwidth = 1
		-- vim.o.winminwidth = 1
		-- vim.o.equalalways = false
		-- require("zoomsync").setup({
		-- 	sync_tmux_on = {
		-- 		win_enter = true, -- sync Tmux zoom on Neovim window enter
		-- 		focus_lost = true, -- sync Tmux zoom on Neovim focus lost
		-- 	},
		--           equalalways = true,
		-- })
		-- -- The bang version syncs Nvim to Tmux zoom state
		-- vim.keymap.set("n", "<leader>zs", "<cmd>ZoomToggle!<CR>", { desc = "Toggle and sync Neovim and Tmux zoom" })
		-- vim.keymap.set("n", "<leader>zz", "<cmd>ZoomToggle<CR>", { desc = "Toggle Neovim zoom" })
	end,
}
