return {
	"mason-org/mason-lspconfig.nvim",
	opts = {},
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
	config = function()
		require("mason-lspconfig").setup({
			-- FIX: Workaround for mason-lspconfig errors with
			--      the new `vue_ls` config in nvim-lspconfig.
			-- - https://github.com/neovim/nvim-lspconfig/commit/85379d02d3bac8dc68129a4b81d7dbd00c8b0f77
			automatic_enable = { exclude = { "vue_ls" } },
			ensure_installed = {
				-- Python --
				-- "mypy",
				"pylsp",
				"ruff",
				-- Lua --
				"lua_ls",
				-- "stylua",
				-- Front --
				"tailwindcss",
				"vtsls",
				"vue_ls",
				-- JSON --
				-- "jq",
				"jsonls",
				-- XML --
				"lemminx",
				-- SQL --
				-- "pgformatter",
				-- "postgrestools",
				-- General --
				-- "eslint_d",
				-- "xmlformatter",
				-- "prettier",
				-- "prettierd",
			},
		})
	end,
}
