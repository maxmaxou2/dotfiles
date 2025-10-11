return {
	"vim-test/vim-test",
	dependencies = { "samharju/yeet.nvim" },
	config = function()
		-- Define a custom strategy using yeet
		vim.g["test#custom_strategies"] = {
			yeet_tmux = function(cmd)
				local yeet = require("yeet")
				yeet.execute(cmd)
			end,
			yeet_tmux_snapshot = function(cmd)
				local yeet = require("yeet")
				yeet.execute(cmd .. " --snapshot")
			end,
		}
		vim.g["test#strategy"] = "yeet_tmux"

		-- Add remaps
		vim.keymap.set("n", "<leader>t", ":TestNearest<CR>")
		vim.keymap.set("n", "<leader>T", ":TestFile<CR>")
		-- vim.keymap.set("n", '<leader>a', ':TestSuite<CR>')
		vim.keymap.set("n", "<leader>l", ":TestLast<CR>")
		vim.keymap.set("n", "<leader>g", ":TestVisit<CR>")

		-- Add a remap for running tests with --snapshot
		vim.keymap.set("n", "<leader>s", function()
			local test_strategy = vim.g["test#strategy"]
			vim.g["test#strategy"] = "yeet_tmux_snapshot"
			vim.cmd("TestNearest")
			vim.g["test#strategy"] = test_strategy -- Restore the original strategy
		end)
		vim.keymap.set("n", "<leader>r", function()
			local ft = vim.bo.filetype
			local file = vim.fn.expand("%:p")
			local output = vim.fn.expand("%:r")
			local cmd

			if ft == "python" then
				cmd = "python3 " .. file
			elseif ft == "cpp" then
				cmd = "clang++ -std=c++20 -Wall -Wextra -o " .. output .. " " .. file .. " && " .. output
			elseif ft == "c" then
				cmd = "clang -Wall -Wextra -o " .. output .. " " .. file .. " && " .. output
			elseif ft == "rust" then
				cmd = "cargo run"
			elseif ft == "typescript" or ft == "javascript" then
				cmd = "node " .. file
			else
				print("No run command configured for filetype: " .. ft)
				return
			end

			-- Use yeet.nvim to execute in tmux (same style as your tests)
			local yeet = require("yeet")
			yeet.execute(cmd)
		end, { desc = "Run current file/project" })
	end,
}
