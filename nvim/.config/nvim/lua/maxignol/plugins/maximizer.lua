local function get_tmux_window()
	if not vim.env.TMUX then
		return nil
	end
	return vim.fn.trim(vim.fn.system({ "tmux", "display-message", "-p", "#I" }))
end

local function is_tmux_zoomed()
	if not vim.env.TMUX then
		return false
	end
	local status = vim.fn.system({ "tmux", "display-message", "-p", "#{window_zoomed_flag}" })
	return vim.fn.trim(status) == "1"
end

return {
	"szw/vim-maximizer",
	lazy = false,
	config = function()
		local zoomed_win = nil
		local zoomed_tmux_window = nil
        local fake_zoom = false
		local function toggle_nvim_zoom()
			if zoomed_win then
				zoomed_win = nil
				zoomed_tmux_window = nil
			else
				zoomed_win = vim.api.nvim_get_current_win()
				zoomed_tmux_window = get_tmux_window()
			end
			if #vim.api.nvim_tabpage_list_wins(0) <= 1 then
                fake_zoom = true
				return
            elseif fake_zoom then
                fake_zoom = false
                return
            end
			vim.cmd("MaximizerToggle")
		end
		vim.keymap.set("n", "<leader>wz", function()
			toggle_nvim_zoom()
		end, { desc = "Toggle maximize split and record state" })

		-- Handle focus events to manage zoom state
		vim.api.nvim_create_autocmd("FocusLost", {
			callback = function()
				if not zoomed_win then
					return
				end

				local cur_win = get_tmux_window()
				if zoomed_tmux_window and cur_win == zoomed_tmux_window and not is_tmux_zoomed() then
					toggle_nvim_zoom()
				end
			end,
		})
		vim.api.nvim_create_autocmd("WinEnter", {
			callback = function()
				if zoomed_win then
					if vim.env.TMUX and is_tmux_zoomed() then
						vim.fn.system({ "tmux", "resize-pane", "-Z" })
					end
					toggle_nvim_zoom()
				end
			end,
		})
	end,
}
