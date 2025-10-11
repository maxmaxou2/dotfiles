return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		require("copilot").setup({
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = true,
				debounce = 75,
				trigger_on_accept = true,
				keymap = {
					accept_word = "<C-j>", -- Accept word
					accept_line = "<C-k>", -- Accept line
					accept = "<C-l>", -- Accept suggestion
					next = "<C-n>", -- Next suggestion
					prev = "<C-p>", -- Previous suggestion
					dismiss = "<C-e>", -- Dismiss suggestion
				},
			},
			filetypes = {
				markdown = true,
				help = true,
				sh = function()
					if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
						-- disable for .env files
						return false
					end
					return true
				end,
			},
		})
	end,
}
