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
					accept = "<Tab>", -- Accept suggestion
					accept_word = "<C-j>", -- Accept word
					accept_line = "<C-l>", -- Accept line
					next = "<C-n>", -- Next suggestion
					prev = "<C-p>", -- Previous suggestion
					dismiss = "<C-e>", -- Dismiss suggestion
				},
			},
		})
	end,
}
