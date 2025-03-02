return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.8',
	dependencies = {
		'nvim-lua/plenary.nvim',
	},
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		}
	},
	config = function()
		local builtin = require("telescope.builtin")
		vim.keymap.set('n', '<C-p>', builtin.find_files, {})
		-- Using only find files instead of git
		-- vim.keymap.set('n', '<C-p>', builtin.git_files, {})
		vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string{ search = vim.fn.input("Grep > ") }
		end)
		vim.keymap.set('n', '<leader>pf', builtin.live_grep, {})
	end
}
