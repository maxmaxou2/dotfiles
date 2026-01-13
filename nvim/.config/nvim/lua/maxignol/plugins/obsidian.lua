return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
	--   -- refer to `:h file-pattern` for more examples
	--   "BufReadPre path/to/my-vault/*.md",
	--   "BufNewFile path/to/my-vault/*.md",
	-- },
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",

		-- see below for full list of optional dependencies 👇
	},
	opts = {
		workspaces = {
			{
				name = "perso",
				path = "/Users/maxence/Library/Mobile Documents/com~apple~CloudDocs/vaults/Perso",
			},
			{
				name = "Work",
				path = "/Users/maxence/Library/Mobile Documents/com~apple~CloudDocs/vaults/Work",
			},
		},

		-- 1. Force le nom du fichier à être le titre
		note_id_func = function(title)
			local suffix = ""
			if title ~= nil then
				-- Si un titre est passé (via un lien [[Titre]]), on l'utilise comme nom de fichier
				return title
			else
				-- Si aucun titre n'est donné, on génère un ID (cas rare)
				for _ = 1, 4 do
					suffix = suffix .. string.char(math.random(65, 90))
				end
				return tostring(os.time()) .. "-" .. suffix
			end
		end,

		-- 2. (Optionnel) Désactive l'ajout automatique de métadonnées (ID, aliases) en haut du fichier
		-- Mets 'false' si tu veux garder les métadonnées, 'true' si tu veux un fichier vide
		disable_frontmatter = true,
	},
}
