local function get_tmux_window()
	if not vim.env.TMUX then
		return nil
	end
	return vim.fn.trim(vim.fn.system({ "tmux", "display-message", "-p", "#I" }))
end

return {
	"szw/vim-maximizer",
	lazy = false,
	config = function()
		local zoomed_win = nil
		local zoomed_tmux_window = nil
		vim.keymap.set("n", "<leader>wz", function()
			local cur = vim.api.nvim_get_current_win()
			if zoomed_win then
				zoomed_win = nil
				zoomed_tmux_window = nil
			else
				zoomed_win = cur
				zoomed_tmux_window = get_tmux_window()
			end
			vim.cmd("MaximizerToggle!")
		end, { desc = "Toggle maximize split and record state" })

        -- Handle focus events to manage zoom state
		vim.api.nvim_create_autocmd("FocusLost", {
			callback = function()
				if not zoomed_win then
					return
				end

				local cur_win = get_tmux_window()
				if zoomed_tmux_window and cur_win == zoomed_tmux_window then
					vim.cmd("MaximizerToggle!")
					zoomed_win = nil
					zoomed_tmux_window = nil
				end
			end,
		})
		vim.api.nvim_create_autocmd("WinEnter", {
			callback = function()
				if zoomed_win and vim.api.nvim_get_current_win() ~= zoomed_win then
					zoomed_win = nil
					zoomed_tmux_window = nil
					if vim.env.TMUX then
						vim.fn.system({ "tmux", "resize-pane", "-Z" })
					end
					vim.cmd("MaximizerToggle!")
				end
			end,
		})

        -- Handle case when split commands are used
		local function unzoom_if_needed()
			if zoomed_win then
				zoomed_win = nil
				vim.cmd("MaximizerToggle!")
			end
		end
		vim.api.nvim_create_user_command("Split", function(opts)
			unzoom_if_needed()
			vim.cmd("split " .. opts.args)
		end, { nargs = "*" })

		vim.api.nvim_create_user_command("Vsplit", function(opts)
			unzoom_if_needed()
			vim.cmd("vsplit " .. opts.args)
		end, { nargs = "*" })
		vim.cmd([[
          cabbrev <expr> split v:lua.require'zoom'.cmd_split()
          cabbrev <expr> vsplit v:lua.require'zoom'.cmd_vsplit()
        ]])
	end,
}
