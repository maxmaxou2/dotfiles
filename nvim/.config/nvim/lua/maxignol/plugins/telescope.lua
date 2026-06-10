return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    config = function()
        -- nvim-treesitter `main` branch removed the legacy `ft_to_lang`/`configs`
        -- API that telescope's previewer relies on, causing:
        --   attempt to call field 'ft_to_lang' (a nil value)
        -- Override telescope's ts highlighter with the native vim.treesitter API.
        local ts_utils = require("telescope.previewers.utils")
        ts_utils.ts_highlighter = function(bufnr, ft)
            local lang = vim.treesitter.language.get_lang(ft) or ft
            if not pcall(vim.treesitter.language.add, lang) then
                return false
            end
            local ok = pcall(vim.treesitter.start, bufnr, lang)
            return ok
        end

        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<CR>"] = actions.select_default,
                        ["<S-CR>"] = function(prompt_bufnr)
                            local entry = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)
                            vim.cmd("edit " .. entry.filename)
                        end,
                    },
                },
            },
            extensions = {
                fzf = {
                    fuzzy = true,                   -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true,    -- override the file sorter
                    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
                },
            },
        })

        local builtin = require("telescope.builtin")
        vim.keymap.set('n', '<C-p>', function()
            local ok = pcall(require('telescope.builtin').git_files, { show_untracked = true })
            if not ok then
                require('telescope.builtin').find_files()
            end
        end, { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string { search = vim.fn.input("Grep > ") }
        end)
        vim.keymap.set('n', '<leader>pf', builtin.live_grep, { noremap = true, silent = true })
        vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', 'gd', builtin.lsp_definitions, { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>w', builtin.current_buffer_fuzzy_find, { noremap = true, silent = true })
        vim.keymap.set("n", "<leader>sd", "<cmd>Telescope diagnostics<CR>", { desc = "Show Diagnostics (Telescope)" })
    end,
}
