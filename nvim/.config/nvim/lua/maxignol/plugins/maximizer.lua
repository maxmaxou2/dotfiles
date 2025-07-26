return {
	"szw/vim-maximizer",
	lazy = false,
	config = function()
		local zoomed_win = nil
		vim.keymap.set("n", "<leader>wz", function()
			local cur = vim.api.nvim_get_current_win()
			if zoomed_win then
				zoomed_win = nil
			else
				zoomed_win = cur
			end
			vim.cmd("MaximizerToggle!")
		end, { desc = "Toggle maximize split and record state" })

		vim.api.nvim_create_autocmd("FocusLost", {
			callback = function()
				if zoomed_win then
					zoomed_win = nil
					vim.cmd("MaximizerToggle!")
				end
			end,
		})
		vim.api.nvim_create_autocmd("WinEnter", {
			callback = function()
				if zoomed_win and vim.api.nvim_get_current_win() ~= zoomed_win then
					zoomed_win = nil
					vim.cmd("MaximizerToggle!")
					if vim.env.TMUX then
						vim.fn.system({ "tmux", "resize-pane", "-Z" })
					end
				end
			end,
		})
	end,
}
