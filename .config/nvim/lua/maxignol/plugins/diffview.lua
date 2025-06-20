return {
    'sindrets/diffview.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
        {
            "<leader>dv",
            function()
                -- Check if Diffview is already open
                local view = require("diffview.lib").get_current_view()
                if view then
                    vim.cmd("DiffviewClose")
                else
                    require('telescope.builtin').git_branches({
                        prompt_title = "Diff with branch",
                        attach_mappings = function(_, map)
                            local actions = require('telescope.actions')
                            local state = require('telescope.actions.state')

                            local select_and_diff = function(prompt_bufnr)
                                local selection = state.get_selected_entry()
                                actions.close(prompt_bufnr)

                                if selection and selection.value then
                                    vim.cmd("DiffviewOpen " .. selection.value)
                                else
                                    vim.notify("No branch selected", vim.log.levels.WARN)
                                end
                            end

                            map('i', '<CR>', select_and_diff)
                            map('n', '<CR>', select_and_diff)
                            return true
                        end,
                    })
                end
            end,
            desc = "Toggle Diffview",
        }, { "<leader>df", ":DiffviewToggleFiles<CR>", desc = "Toggle File Panel" },
        {
            "<leader>dd",
            function()
                local file = vim.fn.expand("%")
                vim.cmd("DiffviewFileHistory " .. file)
            end,
            desc = "Diff current file with history"
        },
    },
    config = function()
        require("diffview").setup({
            file_panel = {
                enable = false,
            },
            view = {
                merge_tool = {
                    layout = "diff3_mixed",
                    disable_diagnostics = true,
                },
            },
        })
    end
}
