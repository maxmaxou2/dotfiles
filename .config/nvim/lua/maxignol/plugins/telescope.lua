return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = {
        'nvim-lua/plenary.nvim',
    },
    extensions = {
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        }
    },
    config = function()
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
    end,
    defaults = {
        mappings = {
            i = {
                ["<CR>"] = require('telescope.actions').select_default,
                ["<S-CR>"] = function(prompt_bufnr)
                    local actions = require("telescope.actions")
                    local action_state = require("telescope.actions.state")
                    local entry = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    vim.cmd("edit " .. entry.filename)
                end,
            },
        },
    }
}
